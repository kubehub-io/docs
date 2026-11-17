---
title: Expose Apps with HubGatewayProfile
type: docs
weight: 4
---

[Gateway API](https://gateway-api.sigs.k8s.io/) defines how Kubernetes applications receive network traffic. Kubehub uses Cilium to implement Gateway API and provides a `HubGatewayProfile` to configure the network endpoint, DNS, and TLS for your cluster.

Use a `HubGatewayProfile` when you want to expose apps through your own network instead of Kubehub's public proxy. It is separate from `HubHttpRoute`, which is the simple public-proxy option; a `HubHttpRoute` cannot attach to a `HubGatewayProfile`. For a profile, configure your apps with the appropriate Gateway API route for the gateway.

## Choose an endpoint

Choose the endpoint that matches your network:

| Endpoint | Exposure | Use it when |
| --- | --- | --- |
| `HostPort` | `Local` | You want to expose apps on your home or local network only. |
| `L2Announcement` | `Local` | Your LAN supports a Kubernetes service claiming an additional IP address. |
| `PublicIP` | `Internet` | You have a public IP and can forward port 443 to your nodes. |

The `Local` profiles use a `*.localkube.app` hostname. The `Internet` profile uses a `*.mykube.app` hostname. Kubehub assigns the wildcard DNS record and requests a trusted wildcard certificate with Let's Encrypt.

Create at most one profile for each exposure type in a cluster.

## Expose apps on a local network with HostPort

Use `HostPort` when a node is reachable from your LAN and port 443 on the node is available. If you have multiple nodes, the hostname can resolve to multiple node IPs.

```yaml
apiVersion: gateway.kubehub.io/v1alpha1
kind: HubGatewayProfile
metadata:
  name: local
spec:
  # The hostname resolves to the private IP address of your nodes.
  endpoint:
    type: HostPort
  exposure: Local
  letsEncrypt:
    email: you@example.com
```

## Expose apps on a local network with L2Announcement

Use `L2Announcement` when your network allows a Kubernetes service to claim a second IP address. Cilium announces the address on the LAN and can fail over between nodes.

```yaml
apiVersion: gateway.kubehub.io/v1alpha1
kind: HubGatewayProfile
metadata:
  name: local
spec:
  # Choose an unused, reserved address on your LAN.
  endpoint:
    type: L2Announcement
    address: 192.168.1.168
  exposure: Local
  letsEncrypt:
    email: you@example.com
```

## Expose apps to the internet with PublicIP

Use `PublicIP` when your router or cloud network has a public IP. Set the address to the public IP that receives traffic for the cluster, and forward port 443 to the node or load balancer that serves the gateway.

```yaml
apiVersion: gateway.kubehub.io/v1alpha1
kind: HubGatewayProfile
metadata:
  name: public
spec:
  endpoint:
    type: PublicIP
    address: 203.0.113.10
  exposure: Internet
  letsEncrypt:
    email: you@example.com
```

## Apply and verify the profile

Save a profile as `gateway-profile.yaml`, then apply it:

```console
kubectl apply -f gateway-profile.yaml
```

Check the profile and its events while Kubehub creates the gateway and certificate:

```console
kubectl get hubgatewayprofile
kubectl describe hubgatewayprofile <name>
```

When the profile is ready, its status reports that the endpoint, gateway, and certificate are configured.

When the profile is ready, configure a standard Gateway API route, such as an `HTTPRoute` or `TLSRoute`, for each application. Set the route's `parentRefs` to the gateway created for the profile.

## What Kubehub manages

- A default Gateway API gateway is created for the cluster.
- The profile connects the gateway to the selected endpoint.
- Kubehub assigns a wildcard hostname for the exposure type.
- Let's Encrypt issues a trusted wildcard TLS certificate.
- You can attach multiple application routes to the gateway.

Kubehub does not provide application authentication. If an app is reachable through an `Internet` profile, protect the app with its own authentication or authorization.

## Use your own domain

Unlike `HubHttpRoute`, a `HubGatewayProfile` does not configure a custom-domain listener for you. To use your own domain, configure the certificate and Gateway listener yourself:

1. Configure a cert-manager `ClusterIssuer`.
   - Kubehub provides `kubehub-letsencrypt-prod`, which you can use unless you need a different issuer.
   - Follow the [cert-manager DNS-01 provider documentation](https://cert-manager.io/docs/configuration/acme/dns01/) to choose a DNS provider.
   - Create a secret containing the credentials for your DNS provider.
   - Configure a DNS-01 solver with those credentials. DNS-01 is recommended because HTTP-01 requires port 80 to be reachable.

   For example, the following solver configuration supports Route 53 and Cloudflare:

```yaml
spec:
  acme:
    solvers:
    - dns01:
        route53:
          accessKeyIDSecretRef:
            key: access-key-id
            name: route53-cred
          region: us-west-2
          secretAccessKeySecretRef:
            key: secret-access-key
            name: route53-cred
      selector:
        dnsZones:
        - myaws.domain.com
    - dns01:
        cloudflare:
          apiTokenSecretRef:
            key: api-token
            name: cloudflare-api-token-secret
      selector:
        dnsZones:
        - mycloudflare.domain.com
```

2. Configure a Gateway listener or `ListenerSet` for your domain and certificate.
3. Attach an `HTTPRoute` or `TLSRoute` to the listener by setting its `parentRefs`.

## Troubleshoot

- If the profile has no ready status, run `kubectl describe hubgatewayprofile <name>` and inspect its events.
- For a `HostPort` profile, verify that port 443 is reachable on the node from the local network.
- For a `PublicIP` profile, verify that the public address is correct and that the router forwards port 443 to the gateway endpoint.
- For an `L2Announcement` profile, verify that the address is unused and that the LAN permits ARP or neighbor announcements.

## Reference

CRD defined here: https://github.com/kubehub-io/cluster-artifacts/blob/main/crds/hubgatewayprofile.gateway.kubehub.io.yaml
