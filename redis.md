## Deploying Redis on Kubernetes with Helm

### pv and pvc creation
1-create NFS directory in path `/srv/`
```bash
chown -R youruser:youruser redis
chmod 777 redis
```
2-add this line to `/etc/exports` 

`/srv/redis   192.168.10.0/24(rw,sync,no_subtree_check,no_root_squash)`

3- pv.yml  file:
```bash
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv
  labels:
    type: local
spec:
  storageClassName: nfs-storage
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 192.168.10.103
    path: "/srv/redis"
```
4- pvc.yml  file:
```bash
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
  namespace: default
spec:
  storageClassName: nfs-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```
5- value.yml
```bash
architecture: standalone

auth:
  enabled: true
  password: "Redis@123"

master:
  service:
    type: ClusterIP
    port: 6379

  persistence:
    enabled: true
    existingClaim: redis-pvc

replica:
  replicaCount: 0

metrics:
  enabled: false
```
6- add helm repo
```bash
helm repo add bitnami-legacy https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami
helm repo update
```

7- install chart 
```bash
helm install redis bitnami-legacy/redis -f redis-value.yml
```
8- check statefulset
```bash
kubectl get statefulset -A
```


