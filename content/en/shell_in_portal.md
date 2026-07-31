---
title: Shell in Portal
type: docs
weight: 5
---

### What can I do with the shell

The shell is a kubectl/helm-equipped terminal that runs with your own identity, so you can operate the cluster using the full power of the command line. Reach for the shell when:

- The portal UI doesn't cover what you need. The portal is convenient, but the kubectl CLI can do everything the portal does and more.
- You want to run kubectl/helm commands directly, with the same permissions as your own account.
- You need to debug or inspect cluster resources, including cilium, and want to run cilium commands.

### Requirements

- A working node is required for the shell to land on as a pod. Without a node, the shell pod will be stuck in pending and you cannot use this feature.

### About temp files

- Any temp file created in the shell is volatile and can be lost at any time. Don't rely on it for anything important.
- In the future, we may configure a Longhorn PV so temp files can be persisted.

### What's different between shell and "Exec" on pod tab.
- shell pass your identity, and have kubectl/helm in it, so you can operate cluster with all kubectl command.
- pod exec is just a terminal to the pod, no special treat, you use it to trouble that pod.
