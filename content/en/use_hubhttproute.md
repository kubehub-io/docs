---
title: Expose an App with HubHttpRoute
type: docs
weight: 4
---

Expose an HTTP service to the public internet without configuring an ingress controller, DNS records, or TLS certificates yourself. Kubehub assigns the route a trusted HTTPS URL in the form `https://<name>-<random>.mykube.app`.

## Before you begin

Make sure you have:

- A Kubernetes cluster on Kubehub.
- at least 1 node connected to the cluster.

The `Service` and `HubHttpRoute` must be in the same namespace.

## Create the application and route

The following manifest creates a sample NGINX application, exposes it through a `Service`, and creates a public `HubHttpRoute` for the service.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: samplewebapp
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: samplewebapp
  template:
    metadata:
      labels:
        app: samplewebapp
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: samplewebapp
  namespace: default
spec:
  ports:
    - port: 80
      targetPort: 80
  selector:
    app: samplewebapp
---
apiVersion: gateway.kubehub.io/v1alpha1
kind: HubHttpRoute
metadata:
  name: samplewebapp
  namespace: default
spec:
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: samplewebapp
          port: 80
```

Save the manifest as `samplewebapp.yaml`, then apply it (portal or kubectl):

```kubectl
kubectl apply -f samplewebapp.yaml
```

Expected output:

```text
deployment.apps/samplewebapp created
service/samplewebapp created
hubhttproute.gateway.kubehub.io/samplewebapp created
```

## Find the public URL

Kubehub publishes the assigned hostname in the `HubHttpRoute` status after it accepts the resource. Check it with:

```console
kubectl get hubhttproute samplewebapp -o wide
```

Expected output includes a hostname similar to:

```text
NAME          HOSTNAME                         DNSREADY
samplewebapp  samplewebapp-fusz98.mykube.app   True
```

Open `https://samplewebapp-fusz98.mykube.app` in a browser. The exact hostname is generated for your route, so use the value shown by your cluster rather than the example above.

You can also inspect the complete status:

```console
kubectl get hubhttproute samplewebapp -o yaml
```

When the route is ready, the status contains a hostname and a `DNSReady` condition:

```yaml
status:
  conditions:
    - message: the public hostname is allocated
      reason: Allocated
      status: "True"
      type: DNSReady
  hostname: samplewebapp-fusz98.mykube.app
```

## Configure a different path

By default, the example sends every request under `/` to the service. To route only requests under another path, change the `value` in the `matches` section. For example, use `/api` to route `/api` and all paths below it:

```yaml
matches:
  - path:
      type: PathPrefix
      value: /api
```

Expected behavior: requests to `/api` and `/api/...` are sent to the referenced service; other paths do not match this rule.

## How HubHttpRoute works

`HubHttpRoute` is similar to a Kubernetes Gateway API `HTTPRoute`, with two differences:

- You do not specify a `parentRef`. Kubehub manages the parent for you.
- You do not specify a hostname. Kubehub allocates one from the `mykube.app` domain.

The `backendRefs` section identifies the service and port that receive matching requests. Kubehub handles public DNS and a trusted TLS certificate for the generated hostname.

## Troubleshoot a route

If the route does not receive a hostname, inspect its events and status:

```console
kubectl describe hubhttproute samplewebapp
```

Expected output includes the route status and any events explaining why allocation or backend discovery is pending.

Also verify that the service has ready endpoints:

```console
kubectl get endpoints samplewebapp
```

Expected output lists at least one pod IP and port. If no endpoints are listed, check that the service selector matches the labels on your application pods and that the pods are ready.
