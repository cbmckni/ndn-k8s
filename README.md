# Data Transfer Pod

**WORK IN PROGRESS**

*Better documentation coming soon.*

This is a simple Kubernetes deployment of a Name-Defined Networking(NDN) container.

Instructions for creating a StorageClass and PVC are included.

## Installation

First, install dependencies:
 - kubectl
 

Make sure kubectl is configured properly with the Kubernetes cluster of your choosing.

The K8s cluster MUST have either a valid PVC or storage class. If a valid PVC does not exist, here are some example instructions to set up a NFS storage class:

### Create NFS StorageClass (optional)

Install [Helm](https://helm.sh/docs/intro/install/)

Update Helm's repositories(similar to `apt-get update)`:

`helm repo update`

Next, install a NFS provisioner onto the K8s cluster to permit dynamic provisoning for **50Gb**(example) of persistent data:

`helm install kf stable/nfs-server-provisioner \`

`--set=persistence.enabled=true,persistence.storageClass=standard,persistence.size=50Gi`

Check that the `nfs` storage class exists:

`kubectl get sc`

## Configuration

Edit the .yaml files. Make sure that the names and resource requests are correct and compatible. 

## Usage

Use 'kubectl get pods' to be sure your container is running properly.

To get an interactive terminal as root, use 'kubectl exec -it ${POD} -- /bin/bash'

## Delete

To delete the deployment/pvc, simply run `kubectl delete -f deployment.yaml` and `kubectl delete -f pvc.yaml`

That's it for now!




