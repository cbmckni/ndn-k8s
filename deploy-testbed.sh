#!/bin/bash

# Usage: ./deploy-testbed.sh <node-list-file> <testbed-name> <pvc-name>

if [ $# -lt 3 ]; then
    echo "Usage: ./deploy-testbed.sh <node-list-file> <testbed-name> <pvc-name>"
    exit 1
fi
YAML="ndn-nfd-${2}.yaml"
cat <<EOF > "$YAML"
EOF
I=0
while read node; do
  echo "Node: $node"
  NODE=${node}
  N="ndn-nfd-${node}-${2}-${I}"
  NAME="${N//./-}"
  cat <<EOF >> "$YAML"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${NAME}-p
  labels:
    app: ${NAME}-p
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${NAME}-p
  template:
    metadata:
      labels:
        app: ${NAME}-p
    spec:
      containers:               
      - name: ${NAME}-p
        image: cbmckni/ndn-tools
        command: [ "/bin/bash", "-c", "--" ]
        args: [ "tail -f /dev/null" ]
        resources:
          requests:
            cpu: 1
            memory: 4Gi
          limits:
            cpu: 1
            memory: 4Gi
        volumeMounts:
        - name: vol-1
          mountPath: /workspace
        ports:
        - containerPort: 6363
      nodeSelector:
          kubernetes.io/hostname: ${node}
      restartPolicy: Always
      volumes:
        - name: vol-1
          persistentVolumeClaim:
            claimName: ${3}
EOF
  cat <<EOF >> "$YAML"
---
EOF
I=$((I+1))
done < $1
cat <<EOF >> "$YAML"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${NAME}-r
  labels:
    app: ${NAME}-r
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${NAME}-r
  template:
    metadata:
      labels:
        app: ${NAME}-r
    spec:
      containers:               
      - name: ${NAME}-r
        image: cbmckni/ndn-tools
        command: [ "/bin/bash", "-c", "--" ]
        args: [ "tail -f /dev/null" ]
        resources:
          requests:
            cpu: 1
            memory: 4Gi
          limits:
            cpu: 1
            memory: 4Gi
        volumeMounts:
        - name: vol-1
          mountPath: /workspace
        ports:
        - containerPort: 6363
      nodeSelector:
          kubernetes.io/hostname: ${NODE}
      restartPolicy: Always
      volumes:
        - name: vol-1
          persistentVolumeClaim:
            claimName: ${3}

EOF



