## WAF_Connection_Graph

Script:

```yaml
#!/bin/bash
netstat443=`netstat -an | grep 443 | wc -l`
echo -e "#current_waf_connection_to_nginx\ncurrent_waf_connection_to_nginx $netstat443" > /var/lib/node_exporter/wafconnection.prom
```

concurrent metric output in `/var/lib/node_exporter/wafconnection.prom`:

```bash
current_waf_connection_to_nginx 8244
```

Script scheduler(every 5 seconds):

~~~bash
sudo nano  /etc/crontab
~~~

~~~bash
*  *    * * *   root    bash  /home/opr/connection.sh
*  *    * * *   root    sleep 5; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 10; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 15; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 20; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 25; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 30; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 35; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 40; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 45; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 50; bash  /home/opr/connection.sh
*  *    * * *   root    sleep 55; bash  /home/opr/connection.sh
~~~




