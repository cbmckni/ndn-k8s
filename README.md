# Named Data Networking on Kubernetes

This is a collection of tools for orchestrating Named-Data Networking(NDN) comtainers on Kubernetes. 

Instructions for creating a StorageClass and PVC are included.

## Installation

First, install dependencies:
 - kubectl
 - Helm(optional)

Make sure kubectl is configured properly with the Kubernetes cluster of your choosing.

### Install Helm(optional)

Install Helm:

`cd PATH`

`wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz`

`tar -xvf helm-v3.6.0-linux-amd64.tar.gz`

`sudo cp linux-amd64/helm /usr/local/bin`

Add the `stable` repo:

`helm repo add stable https://charts.helm.sh/stable`

Update Helm's repositories(similar to `apt-get update)`:

`helm repo update`

The K8s cluster MUST have either a valid PVC or storage class. If a valid PVC does not exist, here are some example instructions to set up a NFS storage class:

### Create NFS StorageClass and PVC (optional)

Install [Helm](https://helm.sh/docs/intro/install/)

Add the "stable" repository:

`helm repo add stable https://kubernetes-charts.storage.googleapis.com`

Update Helm's repositories(similar to `apt-get update)`:

`helm repo update`

Next, install a NFS provisioner onto the K8s cluster to permit dynamic provisoning for **50Gb**(example) of persistent data:

`helm install kf stable/nfs-server-provisioner \`

`--set=persistence.enabled=true,persistence.storageClass=standard,persistence.size=50Gi`

Check that the `nfs` storage class exists:

`kubectl get sc`

To deploy the PVC(if needed), run `kubectl create -f pvc.yaml`

### Copy Execution Scripts to PVC

The standard deployment types use predefined [scripts](https://github.com/cbmckni/ndn-k8s/tree/master/genomics/scripts). These scripts need to be moved to the PVC so the deployed containers can execute them. To do so:

`./kube-load.sh <PVC_NAME> genomics/scripts /workspace/ndn`

# Method 1: kubectl 

Using Helm is recommended, but here are instructions to deploy an NDN consumer using `kubectl`.

## Configuration

Edit the .yaml files. Make sure that the names and resource requests are correct and compatible. 

**Make sure the PVC defined in deployment.yaml is valid.**

## Deployment

To deploy NDN, run `kubectl create -f endpoint.yaml`

## Delete

To delete the deployment/pvc, simply run `kubectl delete -f endpoint.yaml` and `kubectl delete -f pvc.yaml`

# Method 2: Helm(recommended)

Using the included Helm chart is recommended because of the configurability and versatility of the various deployment types.

4 basic deployments exist currently: 

 - Manual(do anything interactively)
 - Producer(publish files)
 - Consumer(pull files from a producer)
 - Ingress(multi-container producer service) *Work in progress*

## Configuration

Edit `helm/values.yaml`. Make sure that the names and resource requests are correct and compatible. There are example arguments in the default file, and preconfigured examples named `helm/values.yaml.<TYPE>`

**Make sure the PVC is valid.**

**Also make sure any files used in arguments exist on the PVC.**

*The 1GB and 5GB example files can be downloaded [here](https://ftp.ncbi.nlm.nih.gov/).*

## Deployment

To deploy NDN, run `helm install <DEPLOYMENT_NAME> helm/`

## Delete

To delete the deployment, run `helm uninstall <DEPLOYMENT_NAME>`

# Usage

Use `kubectl get pods` to be sure your container is running properly.

To get an interactive terminal as root, use `kubectl exec -it <POD_NAME> -- /bin/bash`

## Publish

Example instructions to publish a file:

Download the file to persistent storage:

`wget -O /workspace/1GB https://ftp.ncbi.nlm.nih.gov/1GB`

Publish the file under the path of your choosing:

`ndnputchunks /k8s/1GB < /workspace/1GB`

It will be published within the cluster with the hostname `<DEPLOYMENT_NAME>`, which is configured in `helm/values.yaml`.

**For larger files, the cache size must be increased in nfd.conf and NFD must be restarted**

## Pull Published Files

Example instructions to pull a file:

Add the face: `nfdc face create tcp4://<PUBLISHER_HOST>`

Add the route: `nfdc route add /k8s tcp4://<PUBLISHER_HOST>`

Pull the file: `ndncatchuncks /k8s/1GB > /tmp/1GB.tmp`

This example uses TCP to pull the published file `1GB` with path `/k8s/1GB`.

## Restart NFD

To apply new NFD configurations, you must restart NFD, which is running within the container by default:

`killall nfd` or `pkill nfd`

**This will interrupt any NDN services on the container.**

After edits are made, start NFD again with `/usr/local/bin/nfd -c $CONFIG > $LOG_FILE 2>&1`

**The files at $CONFIG and $LOG_FILE are not persistent. Moving custom config files to peristent storage is advised.**










