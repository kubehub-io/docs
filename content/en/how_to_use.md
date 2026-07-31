---
title: How to Use Kubehub
type: docs
weight: 2
---

Kubehub turns your old laptops, mini PCs, or spare desktops into your own personal cloud. Think of it like a home-grown version of AWS or Google Cloud — but the hardware is yours and everything runs on your own machines.

Here's the whole journey in plain words:

## 1. Log in with your account

Just sign in with any of these:

- GitHub
- Google
- Microsoft

No extra sign-up needed — your existing account is your Kubehub account.

## 2. Create a cluster

A cluster is like a small "data center" made out of your own machines. Create one in the portal and give it a name. It starts empty — the next step is adding machines to it.

## 3. Onboard your nodes

A node is one of your machines that joins your cluster and runs your apps. You can use almost anything as a node: an old laptop, a mini PC, a desktop, or even a VM.

See [How to Onboard a Node](/how_to_onboard_node/) for the full step-by-step. The short version: you install Linux on a machine, plug in your SSH key, and run one command on it. The machine then becomes part of your cluster and starts running your apps.

## 4. Ready to use

Once your node is onboarded, your cluster is alive. Now you can:

- **Manage everything through the portal UI** — the easy way. Create apps, check status, and see what's running without touching a command line.
- **Use the shell for advanced stuff** — the portal covers the common functions, but the built-in shell gives you full `kubectl`/`helm` power when you need to tweak something the UI doesn't expose. See [Shell in Portal](/shell_in_portal/).
- **Download your kubeconfig** — if you're comfortable with Kubernetes tools, grab the config and use your own favorite tooling against your cluster.

## 5. Expose your apps

Got an app you want to share? We handle the tricky parts (addresses and secure connections) for you — either to the public internet or just your home network. See [How to Expose Apps](/how_to_expose_apps/).

That's it. From an old laptop to your own personal cloud in a few steps.
