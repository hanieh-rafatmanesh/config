برای نصب Kubernetes در این روش از Kubespray ورژن 2.26  استفاده شده.

لینک GitHub جهت بررسی نسخه Kubespray و نصب ماژول های مربوط به کوبرنتیز که در این ورژن نصب خواهد شد:
https://github.com/kubernetes-sigs/kubespray/releases/tag/v2.26.0

نکته مهم: در این روش درصورت نیاز به دانلود ماژول ها به صورت دستی، میبایست ماژول ها مطابق با ورژن های اعلامی توسط این نسخه دانلود گردد.



ورژن Clone گرفته شده از GitHub در سرور VCS(Bitbucket) لوکال:

http://vcs.tiddev.com/projects/OUARCH/repos/sre-manifests/browse/k8s-provision/kubespray-2.26/kubespray-release-2.26

  

✅ پیش‌نیازها
1. سرورها (Nodeها):
به تعداد عدد فرد سرور Master (حداقل 3 ) + حداقل 2 Worker

Ubuntu 22.04 یا CentOS 7/8

دسترسی SSH از یک نود کنترل به همه نودها

 1. نصب پیش‌نیازها در   Control Node و انتقال کلید ssh به سرورهای دیگر:
در سرور مستر 1 از ورژن Kubespray کلون میگیریم

نکته: کاربر root در همه سرورها میبایست فعال باشد.

sudo passwd  root
sudo vim /etc/ssh/sshd_config    ---> PermitRootLogin yes


sudo apt update && sudo apt install -y python3 python3-venv python3-pip  sshpass
ssh-keygen
ssh-copy-id user@remote_host
 ایجاد ریپازیتوری pip
cd /root
mkdir .pip
cd .pip
vim pip.conf 
[global]
index-url = http://lib2.tiddev.com/api/pypi/pip/simple
trusted-host = lib2.tiddev.com
2. ساخت محیط مجازی Python (venv)
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
4.نصب پیش نیازها ( فایل reqirement شامل لیست کتابخانه‌هایی هست که برای اجرای Ansible و Kubespray نیاز داریم)
cd kubespray-2.25.0
pip install -r requirements.txt
 or
pip install -r requirements.txt --trusted-host lib2.tiddev.com
3. آماده‌سازی فایل‌های inventory
cp -rfp inventory/sample inventory/mycluster
vim inventory/mycluster/hosts.yaml       #اضافه کردن نودهای مستر و ورکر
 
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
4. تعریف نودها در فایل inventory/mycluster/hosts.yaml
5. در مسیر زیر موارد زیر رعایت شود ( به دلیل نصب ingress از طریق helm)
$ vi inventory/mycluster/group_vars/k8s_cluster/addons.yml
-----------
dashboard_enabled: true
ingress_nginx_enabled: false
ingress_nginx_host_network: false
metrics_server_enabled: true


5. اجرای playbook  در محیط venv
ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml -Kk
نکته: در صورت دریافت ارور fatal: [master1]: FAILED! => {"msg": "module (kube) is missing interpreter line"}

cp plugins/modules/kube.py library/kube.py
chmod +x library/kube.py


6. بررسی نودها:
kubectl get nodes
6. در صورت نیاز برای داشتن دستور Kubectl از other user (برای مثال k8s):
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown -R k8s:k8s ~/.kube/config
kubectl get nodes
-----------------------------------------

نصب Helm
دانلود پکیج helm موردنظر و انتقال فایل helm اجرایی به مسیر    /usr/local/bin/

mv helm /usr/local/bin/
تست helm: 

helm version

نصب Ingress-nginx از طریق helm:
1-پکیج ingress-nginx را از lib2.tiddev.com دانلود کرده 

2-ریپوی موردنظر را به helm معرفی میکنیم، و namespace مجزا تعریف کرده (کار نمیکند)

helm repo add ingress-nginx   http://lib2.tiddev.com:80/helm
helm repo update
kubectl create ns ingress-nginx  (new namespace)
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx
#تست
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
نصب دستی
 نصب دستی از طریق پکیج tgz (شامل Helm chart برای ingress-nginx هست):

ابتدا فایل ingress-nginx ingress-nginx-4.11.1.tgz  را از روی سرور 10.39.102.26  دانلود کرده آن را extract  کرده  و مقادیر digest در فایل  values.yaml را حذف کرده و به جای آن ""  قرار میدهیم

سپس فایل دانلود شده ingress-nginx ingress-nginx-4.11.1.tgz را حذف کرده و سپس دستور  helm package ingress-nginx   را میزنیم 



values-baharestan-prod.yaml

kubectl create ns ingress-nginx  (new namespace)
helm install ingress-nginx ingress-nginx-4.11.1.tgz   --namespace ingress-nginx
 
 
 
 
 #تست
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
