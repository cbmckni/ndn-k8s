#!/bin/bash
# Load input data to a Persistent Volume on a Kubernetes cluster.

# parse command-line arguments
if [[ $# != 2 ]]; then
	echo "usage: $0 <pvc-name> <local-path> <pvc-path>"
	exit -1
fi

PVC_NAME="$1"
PVC_PATH="$2"
POD_FILE="pod.yaml"
POD_NAME="${USER}-load-$(printf %04x ${RANDOM})"
LOCAL_PATH="$(realpath $2)"

# create pod config file
cat > ${POD_FILE} <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ${POD_NAME}
spec:
  containers:
  - name: ${POD_NAME}
    image: ubuntu
    args: ["sleep", "infinity"]
    volumeMounts:
    - mountPath: /workspace
      name: ${PVC_NAME}
  restartPolicy: Never
  volumes:
    - name: ${PVC_NAME}
      persistentVolumeClaim:
        claimName: ${PVC_NAME}
EOF

# create pod
kubectl create -f ${POD_FILE}

# wait for pod to initialize
POD_STATUS=""

while [[ ${POD_STATUS} != "Running" ]]; do
	sleep 2
	POD_STATUS="$(kubectl get pod --no-headers --output jsonpath={.status.phase} ${POD_NAME})"
done

# copy input data to pod
echo "copying data..."

kubectl exec ${POD_NAME} -- bash -c "mkdir -p ${PVC_PATH}"
kubectl cp "${LOCAL_PATH}" "${POD_NAME}:${PVC_PATH}/$(basename ${LOCAL_PATH})"

# delete pod
kubectl delete -f ${POD_FILE}
rm -f ${POD_FILE}
