نصب کالستر Kubernetes
برای نصبKubernetesدر این روش ازKubesprayورژن2.26استفاده شده.
لینکGitHubجهت بررسی نسخهKubesprayو نصب ماژول های مربوط به کوبرنتیز که در این ورژن نصب خواهد
شد:
sigs/kubespray/releases/tag/v2.26.0-https://github.com/kubernetes
نکته مهم: در این روش درصورت نیاز به دانلود ماژول ها به صورت دستی، میبایست ماژول ها مطابق با ورژن های
اعالمی توسط این نسخه دانلود گردد.
ورژنCloneگرفته شده ازGitHubدر سرورVCS(Bitbucket)لوکال:
-provision/kubespray-manifests/browse/k8s-http://vcs.tiddev.com/projects/OUARCH/repos/sre
2.26-release-2.26/kubespray
پیشنیازها
1. سرورها (Nodeها):
•به تعداد عدد فرد سرورMaster(حداقل3) + حداقل2Worker
•Ubuntu 22.04یاCentOS 7/8
•دسترسیSSHاز یک نود کنترل به همه نودها
1. نصب پیشنیازها درControl Nodeو انتقال کلیدsshبه سرورهای دیگر:
در سرور مستر1از ورژنKubesprayکلون میگیریم
نکته: کاربرrootدر همه سرورها میبایست فعال باشد.
sudo passwd root
sudo vim /etc/ssh/sshd_config ---> PermitRootLogin yes
sudo apt update && sudo apt install -y python3 python3-venv python3-pip
sshpass
ssh-keygen
ssh-copy-id user@remote_host
•ایجاد ریپازیتوریpip
cd /root
mkdir .pip
cd .pip
vim pip.conf
[global]
index-url = http://lib2.tiddev.com/api/pypi/pip/simple
trusted-host = lib2.tiddev.com
2. ساخت محیط مجازیPython (venv)
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
4.نصب پیش نیازها ( فایلreqirementشامل لیست کتابخانههایی هست که برای اجرایAnsibleو
Kubesprayنیاز داریم)
cd kubespray-2.25.0
pip install -r requirements.txt
or
pip install -r requirements.txt --trusted-host lib2.tiddev.com
3. آمادهسازی فایلهایinventory
cp -rfp inventory/sample inventory/mycluster
vim inventory/mycluster/hosts.yaml #ورکر و مستر نودهای کردن اضافه
all:
hosts:
lon-k8s-m1:
ansible_host: 10.39.102.204
ip: 10.39.102.204
access_ip: 10.39.102.204
lon-k8s-m2:
ansible_host: 10.39.102.213
ip: 10.39.102.213
access_ip: 10.39.102.213
lon-k8s-m3:
ansible_host: 10.39.102.212
ip: 10.39.102.212
access_ip: 10.39.102.212
lon-k8s-w1:
ansible_host: 10.39.102.211
ip: 10.39.102.211
access_ip: 10.39.102.211
lon-k8s-w2:
ansible_host: 10.39.102.202
ip: 10.39.102.202
access_ip: 10.39.102.202
lon-k8s-w3:
ansible_host: 10.39.102.210
ip: 10.39.102.210
access_ip: 10.39.102.210
lon-k8s-w4:
ansible_host: 10.39.102.203
ip: 10.39.102.203
access_ip: 10.39.102.203
children:
kube_control_plane:
hosts:
lon-k8s-m1:
lon-k8s-m2:
lon-k8s-m3:
kube_node:
hosts:
lon-k8s-w1:
lon-k8s-w2:
lon-k8s-w3:
lon-k8s-w4:
etcd:
hosts:
lon-k8s-m1:
lon-k8s-m2:
lon-k8s-m3:
k8s_cluster:
children:
kube_control_plane:
kube_node:
calico_rr:
hosts: {}
4. تعریف نودها در فایلinventory/mycluster/hosts.yaml
5. در مسیر زیر موارد زیر رعایت شود ( به دلیل نصبingressاز طریقhelm)
$ vi inventory/mycluster/group_vars/k8s_cluster/addons.yml
-----------
dashboard_enabled: true
ingress_nginx_enabled: false
ingress_nginx_host_network: false
metrics_server_enabled: true
5. اجرایplaybookدر محیطvenv
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-
user=root cluster.yml -Kk
نکته: در صورت دریافت ارورfatal: [master1]: FAILED"{ >= !msg": "module (kube) is missing
interpreter line}"
cp plugins/modules/kube.py library/kube.py
chmod +x library/kube.py
6. بررسی نودها:
kubectl get nodes
6. در صورت نیاز برای داشتن دستورKubectlازother user(برای مثالk8s:)
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown -R k8s:k8s ~/.kube/config
kubectl get nodes
-----------------------------------------
نصبHelm
دانلود پکیجhelmموردنظر و انتقال فایلhelmاجرایی به مسیر/usr/local/bin/
mv helm /usr/local/bin/
تستhelm:
helm version
نصبIngress-nginxاز طریقhelm:
1-پکیجingress-nginxرا ازlib2.tiddev.comدانلود کرده
2-ریپوی موردنظر را بهhelmمعرفی میکنیم، وnamespaceمجزا تعریف کرده (
کار نمیکند)
helm repo add ingress-nginx http://lib2.tiddev.com:80/helm
helm repo update
kubectl create ns ingress-nginx (new namespace)
helm install ingress-nginx ingress-nginx/ingress-nginx \
--namespace ingress-nginx
# تست
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
نصب دستی
نصب دستی از طریق پکیجtgz(شاملHelm chartبرایingress-nginxهست):
ابتدا فایلingress-nginx ingress-nginx-4.11.1.tgzرا از روی سرور10.39.102.26دانلود کرده آن را
extractکردهو مقادیرdigestدر فایلvalues.yamlرا حذف کرده و به جای آن ""قرار میدهیم
سپس فایل دانلود شدهingress-nginx ingress-nginx-4.11.1.tgzرا حذف کرده و سپس دستورhelm package
ingress-nginxرا میزنیم
prod.yaml-baharestan-values
kubectl create ns ingress-nginx (new namespace)
helm install ingress-nginx ingress-nginx-4.11.1.tgz --namespace ingress-
nginx
# تست
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
