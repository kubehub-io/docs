---
title: How to Expose Apps
type: docs
weight: 4
---

Making your app available to other people can feel complicated, but we have two easy ways to do it for you. You don't need to touch your router or DNS at all.

## The easy way: let Kubehub handle it

### Public mode

Your app is available to anyone on the internet. People just need a link to reach it. We route the traffic to your app through our own proxy, so you don't have to open any ports or set up DNS.

### Local mode

Your app is only reachable from your own home/local network (for example, your phone or laptop at home). It's perfect for personal things you don't want the whole world to see, like a media server or a smart home dashboard.

- You get an address like `your-app.local.mykube.app`.
- We point that address to your home network automatically.
- We also handle the secure connection (SSL/TLS) for you, so you won't see scary "not secure" warnings.

## ⚠️ A note about who can access your app

We take care of the address and the secure connection for both modes. But it's up to you to decide who can actually use your app. If your app has its own login, great. If not, anyone who has the link can open it, so think about whether that's OK before you expose it publicly.

## For advanced users: set it up yourself

If you want full control, you can expose your app on your own. This only works if your internet connection gives you a public IP address (many home connections do). This route involves more technical setup, so only try it if you're comfortable with:

- Installing an ingress/gateway provider (e.g. Traefik, nginx-ingress, project-contour, cilium, envoy-gateway)
- Installing cert-manager and configuring a Let's Encrypt ClusterIssuer
- Setting up HTTP01/DNS01 challenges (we recommend DNS01 so you don't have to open port 80)
- Exposing your service as NodePort
- Configuring your router to forward port 443 to your nodePort

If this sounds like a lot, don't worry — the easy way above covers most people's needs.
