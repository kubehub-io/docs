---
title: How to Onboard a Node
type: docs
weight: 3
---

A node is one of your machines that joins your cluster and runs your apps. This page walks you through getting that machine ready and joining it to your cluster.

## Step 1: Pick a machine

You need at least one node. Almost any machine works:

- an old laptop
- a mini PC
- a desktop machine
- a Virtual Machine (note: an app running on a VM will only be reachable from that host machine, unless you do extra network setup)

## Step 2: Prepare the machine

- **Install Linux on it** (Ubuntu, Fedora, or Debian). If you're comfortable, install a server version — but a normal desktop version works fine too.
- **Keep it running 24/7.** Once it becomes part of your cluster, it acts like a real server. If you turn it off, the apps on it go down. (The setup will also help you configure the laptop to keep running when you close the lid.)
- **Make sure you can SSH into it.** On the machine, add your GitHub key so you can log in from anywhere:

  ```bash
  curl https://github.com/{your github handle}.keys > /home/{your linux username}/.ssh/authorized_keys
  ```

## Step 3: Join the node to your cluster

The portal will show you the exact installation instructions. From a computer that can reach your machine:

SSH into the node and run:
```
CLUSTER=<clusterName>
ARCH="$(uname -m | sed 's/aarch64/arm64/')"
sudo curl -o /usr/bin/kubehubcli -L https://github.com/kubehub-io/cli/releases/download/latest/cli_Linux_$(ARCH)

sudo chmod +x /usr/bin/kubehubcli

sudo kubehubcli node join --cluster $CLUSTER
```

### Tip: sign in from your own machine

During the process you'll be asked to do a device login. This is easiest when you SSH into the new node from your own computer, because your browser is already logged in — you just copy-paste the code. What you want to avoid is being on the new machine with no browser set up, and having to log in to GitHub/Google/Microsoft all over again.

## Step 4: Follow the prompts

The installer will walk you through a few things:

- whether to set your IP to a static address (recommended — it keeps the node reachable over time)
- whether to configure this as a laptop that keeps running after the lid is closed
- whether to set this machine up as a Kubernetes node (this installs the underlying software like containerd and kubelet)

## Step 5: Verify

After the setup completes, refresh the portal page and you'll see your new node appear in the list. You're ready to go.
