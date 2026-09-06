---
title: "Image Volume in Practice: os/arch Makes No Sense for Content Images"
date: 2026-08-15
type: blog
description: "What happened when we tried to use Kubernetes Image Volumes for static content, and why we ended up publishing content images as unknown/unknown."
---

# Image Volume in Practice: os/arch Makes No Sense for Content Images

Kubernetes Image Volumes let you put files into an OCI image and mount that image into a Pod as a volume — separate from the application container. The feature graduated to stable in Kubernetes 1.36.

The use case: **separating runtime images from application content**. For example:

- Nginx + HTML/CSS/JS
- Java + JAR
- Node.js + .js files
- Python + .py files

This sounds simple. It exposed a surprisingly annoying problem.

## The goal

Take a traditional Nginx site:

```dockerfile
FROM nginx:latest
COPY ./site /usr/share/nginx/html
```

The Nginx runtime and website are one image. A security update to Nginx forces a rebuild of the website, and vice versa. Neither has anything to do with the other.

Instead, define two independent images:

```text
runtimeImage: nginx:latest
siteContentImage: xyzSite:x.y.z
```

Mount `xyzSite` as an Image Volume. Now the runtime and content have independent lifecycles.

## The problem: architecture metadata

Content images don't contain executables. They contain HTML, CSS, and JS. But OCI images require platform metadata (`linux/amd64`, `linux/arm64`), and that causes issues at build, publish, and deploy.

### Build

If you don't specify a platform, the build environment picks the default — usually the OS/arch of the build machine. That's fine for application images. It's meaningless for content images.

### Publish

A multi-arch manifest works but duplicates content:

```text
amd64 → HTML / CSS / JS / images
arm64 → HTML / CSS / JS / images
```

For a 5 MB website, that's fine. For a 100 GB AI model, it's not.

### Deploy

A mixed-architecture cluster fails. An `amd64`-only content image won't mount on an `arm64` node — kubelet checks the platform metadata, even though the content is platform-independent. The result: `ImagePullBackOff`.

## The two bad options

1. **Build multi-arch content images.** Solves deployment, but stores `N` copies of the same content for `N` architectures.
2. **Pick one architecture.** Works until you add a node with a different architecture.

## The fix: `unknown/unknown`

OCI images carry platform metadata in their config:

```json
{
  "architecture": "amd64",
  "os": "linux"
}
```

The [OCI spec](https://github.com/opencontainers/image-spec/blob/main/config.md#properties) requires these to be valid `GOOS/GOARCH` values — there's no built-in way to express a platform-neutral image.

Setting them to `unknown` works:

```json
{
  "architecture": "unknown",
  "os": "unknown"
}
```

The image loads as a data volume on both `amd64` and `arm64` nodes. Docker rejects `unknown/unknown`, but Kubernetes Image Volumes accept it.

## The converter

Repacking images manually is tedious. [image-volume-converter](https://github.com/kubehub-io/image-volume) is a Go utility that automates it. It reads an existing image, sets `os` and `architecture` to `unknown`, and writes the result. It does **not** rebuild the application or filesystem layers — it only changes metadata.

### GitHub Actions

Use it in a pipeline:

```yaml
- name: Build image
  uses: docker/build-push-action@v4
  with:
    context: .
    file: ./Dockerfile
    load: true
    tags: ghcr.io/${{ github.repository }}:main-latest

- name: Create no-arch content image
  uses: kubehub-io/image-volume
  with:
    imageTag: ghcr.io/${{ github.repository }}:main-latest
    outputImageTag: ghcr.io/${{ github.repository }}:main-noarch
```

Or export as an OCI archive:

```yaml
- name: Export OCI archive
  uses: kubehub-io/image-volume
  with:
    imageTag: ghcr.io/${{ github.repository }}:main-latest
    publishTo: OCIArchive:/tmp/site-no-arch.tar
```

**Note:** SBOMs, provenance, and attestations are currently ignored by the converter.

## Usage

Mount the converted image in a Pod spec:

```yaml
containers:
- name: staticweb
  image: nginx:alpine
  volumeMounts:
  - name: site-content
    mountPath: /usr/share/nginx/html
    subPath: site
    readOnly: true
volumes:
- name: site-content
  image:
    reference: mycr.io/myimage:mytag
    pullPolicy: IfNotPresent
```

No `ImagePullBackOff`. No duplicate content. Independent lifecycles for runtime and content.

Source: [kubehub-io/image-volume](https://github.com/kubehub-io/image-volume)
