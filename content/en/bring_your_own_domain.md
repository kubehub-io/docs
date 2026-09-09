---
title: Bring Your Own Domain
type: docs
weight: 5
---

Your app is live at `your-app.xxx.mykube.app` and working great. But you'd rather use your own domain — something like `app.yourdomain.com` or `dashboard.yourdomain.io`.

This guide shows you how to point your own domain to your Kubehub app using a cloud DNS or CDN provider. The general idea is the same everywhere: create a DNS record that points to your app's Kubehub URL, then configure TLS (the secure connection) so visitors see a padlock, not a warning.

## Cloudflare

If you already use Cloudflare for DNS, this is the quickest path.

1. In the Cloudflare dashboard, go to **DNS > Records** and add a new record:
   - **Type:** `CNAME`
   - **Name:** the domain you want (e.g. `app` for `app.yourdomain.com`)
   - **Target:** `your-app.xxx.mykube.app`
   - **Proxy status:** Proxied (orange cloud ON)
2. In the Kubehub portal, open your app's **AppIngress** page, edit the ingress, and add your custom domain (e.g. `app.yourdomain.com`).

That's it. Cloudflare handles TLS automatically when the proxy is on.

## AWS CloudFront

The CloudFront free tier (1 TB of data transfer per month) is more than enough for most scenarios.

1. In the CloudFront console, create a new distribution.
2. Under **Origin domain**, enter `your-app.xxx.mykube.app`.
   - **Protocol:** HTTPS only
3. Under **Settings**, add your custom domain to **Alternate domain name (CNAME)** — for example `app.yourdomain.com`.
4. Under **Custom SSL certificate**, select or request an ACM certificate for your domain. (You must validate domain ownership in ACM first.)
5. Create the distribution.
6. In your DNS provider (Route 53 or elsewhere), create a `CNAME` record pointing `app.yourdomain.com` to the CloudFront distribution domain name (e.g. `d1234abcdef.cloudfront.net`).
7. In the Kubehub portal, open your app's **AppIngress** page, edit the ingress, and add your custom domain.

CloudFront terminates TLS for your visitors and forwards traffic to your Kubehub app over HTTPS.

## Azure Front Door

1. In the Azure portal, create a new **Front Door and CDN profile** (or add to an existing one).
2. Create an **origin group**:
   - Add an origin with:
     - **Origin type:** Custom
     - **Host name:** `your-app.xxx.mykube.app`
     - **Protocol:** HTTPS only
3. Create a **routing rule**:
   - Match all traffic (or the specific path/host you need).
   - Forward to the origin group you just created.
   - Use HTTPS for the frontend.
4. Under **Custom domains**, add your domain (e.g. `app.yourdomain.com`). Front Door requires you to validate ownership — follow the DNS TXT record steps Azure shows you.
5. Under **TLS/SSL settings**, select the certificate Azure provisioned for your custom domain.
6. In your DNS provider, create a `CNAME` record pointing `app.yourdomain.com` to the Front Door endpoint (e.g. `your-profile.azurefd.net`).
7. In the Kubehub portal, open your app's **AppIngress** page, edit the ingress, and add your custom domain.

Azure Front Door terminates TLS and routes traffic to your Kubehub app.

## GCP Cloud CDN

1. In the GCP console, go to **Network services > Load balancing** and create a new **HTTP(S) Load Balancer**.
2. Create a **backend bucket** (or backend service) pointing to a URL map that has `your-app.xxx.mykube.app` as the backend:
   - **Protocol to backend:** HTTPS
3. Create a **URL map** and add a host rule for your custom domain (e.g. `app.yourdomain.com`) pointing to the backend bucket/service.
4. Create a **target HTTP(S) proxy** using that URL map.
5. Create a **forwarding rule** with a global static IP address.
6. Under **Custom domains**, add `app.yourdomain.com` and attach the managed SSL certificate (GCP can provision one for you if you own the domain in Cloud DNS).
7. In Cloud DNS (or your DNS provider), create an `A` record pointing `app.yourdomain.com` to the static IP from step 5.
8. In the Kubehub portal, open your app's **AppIngress** page, edit the ingress, and add your custom domain.

GCP handles TLS termination and load balancing. Traffic reaches your Kubehub app over HTTPS.

## Verify

After DNS propagation (usually a few minutes, sometimes up to an hour), open your custom domain in a browser. You should see your app with a valid TLS certificate — no warnings.

If something isn't working:

- Double-check the CNAME or A record with `dig` or an online DNS checker.
- Make sure the custom domain matches exactly what you entered in the Kubehub portal.
- Check that your cloud provider's TLS certificate is active and not in a pending state.
