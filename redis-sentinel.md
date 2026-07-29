### deploy Redis-Sentinel on kubernetes cluster with 1 master and 2 replica
1-redis-master-pv.yml
```bash
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-master-pv
spec:
  capacity:
    storage: 5Gi

  accessModes:
    - ReadWriteMany

  persistentVolumeReclaimPolicy: Retain

  storageClassName: nfs-storage

  nfs:
    server: 192.168.10.103
    path: /srv/redis/master
```
2-redis-replica0-pv.yml
```bash
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-replica0-pv
spec:
  capacity:
    storage: 5Gi

  accessModes:
    - ReadWriteMany

  persistentVolumeReclaimPolicy: Retain

  storageClassName: nfs-storage

  nfs:
    server: 192.168.10.103
    path: /srv/redis/replica0
```
3-redis-replica1.yml
```bash
apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-replica1-pv
spec:
  capacity:
    storage: 5Gi

  accessModes:
    - ReadWriteMany

  persistentVolumeReclaimPolicy: Retain

  storageClassName: nfs-storage

  nfs:
    server: 192.168.10.103
    path: /srv/redis/replica1
```
4-valus.yml
```bash
architecture: replication

auth:
  enabled: true
  password: Redis@123
  sentinel: true

master:
  persistence:
    enabled: true
    storageClass: nfs-storage
    accessModes:
      - ReadWriteMany
    size: 5Gi

replica:
  replicaCount: 3

  persistence:
    enabled: true
    storageClass: nfs-storage
    accessModes:
      - ReadWriteMany
    size: 5Gi

sentinel:    #install sentinel
  enabled: true
  quorum: 2

commonConfiguration: |-
  appendonly yes
  save ""

metrics:
  enabled: false
```
`as recommended helm chart we dont need PVC and is better it create automatically PVC`

5- helm install
```bash
helm install redis bitnami-legacy/redis -f values.yml
```
