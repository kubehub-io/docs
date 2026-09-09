---
title: How to Expose Apps
type: docs
weight: 4
---

You've got an app running in your cluster. Now you want to share it with others — or at least reach it from your own devices. Kubehub gives you two ways to do this, both of which handle the tricky parts (DNS and TLS) for you.

## The easy way: let Kubehub handle it

In the Kubehub portal, go to your cluster's **Settings** page, then open the **AppIngress** tab and enable managed AppIngress.

From there, you choose between two modes.

### Public mode

Your app is reachable from anywhere on the internet at `your-app.xxx.mykube.app`.

- No port forwarding. No DNS configuration. No exposed home IP.
- Kubehub proxies the traffic through our infrastructure, so your home network stays private.
- TLS is handled for you — visitors see a padlock, not a warning.

Anyone with the link can access your app, so make sure your app has authentication if you need it.

### Local mode

Your app is only reachable from your home or local network — your phone, your laptop, your smart TV.

- You get an address like `your-app.xxx.localkube.app`.
- The address resolves to your node's local IP automatically.
- TLS is handled for you, so there are no browser warnings.

This is ideal for personal services you don't want on the public internet: media servers, dashboards, home automation, and similar tools.

## A note about access control

Kubehub takes care of the address and the secure connection for both modes. But who can actually *use* your app is up to you. If your app has a login page, you're covered. If it doesn't, anyone with the link can open it — think about whether that's okay before you expose it publicly.

## How it works under the hood

Even though we call it "AppIngress," the underlying technology is the Kubernetes Gateway API, implemented by Cilium.

### Local AppIngress

1. Kubehub creates a Gateway resource (`name=default`, `namespace=kube-system`) that shares the same Cilium CNI Helm release.
2. Cilium's Envoy gateway listens on **host port 443**.
3. A wildcard DNS record (e.g. `*.fubya8.localkube.app`) is assigned to your cluster. It resolves to all node IPs via round-robin — but only to private IP ranges (`10.x`, `172.16–31.x`, `192.168.x`), so it's only accessible from your local network.
4. A wildcard TLS certificate is issued, and an HTTPS listener is created on the Gateway under `sectionName=kubehub-local-wildcard`.
5. cert-manager is installed as part of the dependency chain. It works with Let's Encrypt to issue trusted certificates. You can reuse this cert-manager instance for your own workloads too.

### Public AppIngress

1. Kubehub dispatches the DNS record from our servers.
2. Traffic is routed to your cluster through a Konnectivity tunnel — the same mechanism Kubernetes uses when the API server and nodes are on different networks.
3. Your home IP is never exposed to the outside world. There is a performance cost since traffic goes through our proxy, and we may introduce traffic limits in the future to protect the platform.

Want to use your own domain? See [Bring Your Own Domain](./bring_your_own_domain.md).

## Roll your own: bring your own ingress setup

If you want full control over how your app is exposed, you can set up your own ingress stack. This only works if your internet connection gives you a public IP address (most home connections do).

This route requires more work, so only go here if you're comfortable with:

- Installing an ingress or gateway provider (Traefik, nginx-ingress, Contour, Cilium, Envoy Gateway, etc.)
- Installing cert-manager and configuring a Let's Encrypt ClusterIssuer
- Setting up HTTP-01 or DNS-01 challenges (DNS-01 is easier since you don't need to open port 80)
- Exposing your service as a NodePort, Ingress, or HTTPRoute
- Configuring your router to forward port 443 to the appropriate service

If that sounds like a lot, the managed AppIngress above covers most use cases.

Want to use your own domain? See [Bring Your Own Domain](./bring_your_own_domain.md).
