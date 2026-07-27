## Deploying Redisinsight on Kubernetes with Helm
1-chart:
```bash
redisinsight-chart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    └── service.yaml
```
2- create chart:
```bash
helm create redisinsight-chart
```
3-chart.yml  file:
```bash
apiVersion: v2
name: redisinsight
description: RedisInsight Helm Chart
type: application
version: 1.0.0
appVersion: "3.8"
```
4-value.yml  file:
```
replicaCount: 1

image:
  repository: redislabs/redisinsight
  tag: 3.8
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 5540
  nodePort: 30540

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```
5-deployment.yml file:
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "redisinsight.fullname" . }}
  labels:
    app: redisinsight

spec:
  replicas: {{ .Values.replicaCount }}

  selector:
    matchLabels:
      app: redisinsight

  template:
    metadata:
      labels:
        app: redisinsight

    spec:
      containers:
      - name: redisinsight
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}

        ports:
        - containerPort: 5540

        resources:
          {{- toYaml .Values.resources | nindent 10 }}

        volumeMounts:
        - name: data
          mountPath: /data

      volumes:
      - name: data
        emptyDir: {}
```
6-service.yml file:
```bash
apiVersion: v1
kind: Service

metadata:
  name: {{ include "redisinsight.fullname" . }}

spec:
  type: {{ .Values.service.type }}

  selector:
    app: redisinsight

  ports:
  - name: http
    port: {{ .Values.service.port }}
    targetPort: 5540
    nodePort: {{ .Values.service.nodePort }}
```
7- install chart
```bash
helm install redisinsight ./redisinsight-chart \
  -n tools \
  --create-namespace
```
