#!/bin/bash

INPUT=$1
URL=$2
ROUTE=$3
DEST=$4

cat > ndn-parallel.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ndn-k8s-parallel
  labels:
    app: ndn-k8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ndn-k8s
  template:
    metadata:
      labels:
        app: ndn-k8s
    spec:
      containers:               
EOF

COUNTER=1

while read line; do
  echo $line
  cat >> ndn-parallel.yaml <<EOF
      - name: ndn-k8s-${COUNTER}
        image: dereddick/ndn-docker
        command: [ "/bin/bash", "-c", "--" ]
        args: [ "nfd && nfdc face create ${URL} && nfdc route add ${ROUTE} ${URL} && ndncatchunks ${line} > $(basename -- ${line})" ]
        resources:
          requests:
            cpu: 1
            memory: 4Gi
          limits:
            cpu: 1
            memory: 4Gi
        volumeMounts:
        - name: vol-1
          mountPath: ${DEST}
EOF
COUNTER=$((COUNTER+1))
done < $INPUT

cat >> ndn-parallel.yaml <<EOF
      restartPolicy: Always
      volumes:
        - name: vol-1
          persistentVolumeClaim:
            claimName: deepgtex-prp # Enter valid PVC    
EOF

cat ndn-parallel.yaml
