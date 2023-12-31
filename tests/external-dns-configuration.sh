#!/usr/bin/env bash
# This is a manual deployment instructions for external-dns

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source $parent_path/variables.sh

# See: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#static-credentials

export EXTERNALDNS_NS=external-dns

kubectl create ns ${EXTERNALDNS_NS}

cat <<EOF > credentials
[default]
aws_access_key_id = $(echo $AWS_ACCESS_KEY_ID)
aws_secret_access_key = $(echo $AWS_SECRET_ACCESS_KEY)
EOF

kubectl create secret generic external-dns --namespace ${EXTERNALDNS_NS:-"default"} --from-file credentials
rm credentials

# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#deploy-externaldns

cat <<EOF > externaldns-with-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-dns
  labels:
    app.kubernetes.io/name: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
  labels:
    app.kubernetes.io/name: external-dns
rules:
  - apiGroups: [""]
    resources: ["services","endpoints","pods","nodes"]
    verbs: ["get","watch","list"]
  - apiGroups: ["extensions","networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get","watch","list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
  labels:
    app.kubernetes.io/name: external-dns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin # external-dns
subjects:
  - kind: ServiceAccount
    name: external-dns
    namespace: ${EXTERNALDNS_NS} # change to desired namespace: externaldns, kube-addons
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  labels:
    app.kubernetes.io/name: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app.kubernetes.io/name: external-dns
  template:
    metadata:
      labels:
        app.kubernetes.io/name: external-dns
    spec:
      serviceAccountName: external-dns
      containers:
        - name: external-dns
          image: registry.k8s.io/external-dns/external-dns:v0.13.5
          args:
            - --source=service
            - --source=ingress
            - --domain-filter=${DOMAIN_NAME} # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
            - --provider=aws
            #- --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
            - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
            - --registry=txt
            - --txt-owner-id=external-dns
          env:
            - name: AWS_DEFAULT_REGION
              value: ${AWS_DEFAULT_REGION}
            - name: AWS_SHARED_CREDENTIALS_FILE
              value: /.aws/credentials
          volumeMounts:
            - name: aws-credentials
              mountPath: /.aws
              readOnly: true
      volumes:
        - name: aws-credentials
          secret:
            secretName: external-dns
EOF

kubectl create --filename externaldns-with-rbac.yaml --namespace ${EXTERNALDNS_NS:-"default"}
rm externaldns-with-rbac.yaml
