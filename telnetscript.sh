#!/bin/bash

# Define the list of destination IP addresses, ports, and service names
DESTINATIONS=(
 "192.168.60.83 1475 ibmmq"
 "192.168.56.13 18006 estelam-ghobouz"
 "10.39.15.26 8760 keyhan"
 "10.39.41.141 80 keycloak"
 "10.39.41.141 8081 keycloak"
 "10.39.41.141 8080 keycloak"
 "192.168.54.68 25 smtp-1"
 "192.168.54.69 25 smtp-2"
 "10.39.15.135 80 kahkeshan"
 "192.168.73.101 9100 media-proxy"
 "192.168.73.101 8020 media-proxy"
 "192.168.73.101 7800 media-proxy"
 "192.168.70.252 80 push"
 #"172.25.241.241 443 orm"
 "10.40.193.13 5672 pichak"
 "192.168.37.10 22131 shetab1"
 "192.168.37.10 22231 shetab2"
 "192.168.37.10 22331 shetab3"
 "192.168.37.10 22431 shetab4"
 "192.168.37.10 22531 shetab5"
 "192.168.50.66 8040 rahyab"
 "192.168.50.66 8020 rahyab"
 "10.39.15.42 7800 sms"
 "10.40.194.59  8082 harim"
 "192.168.70.5 6061 harim"
 "192.168.53.10 22 sftp"
 "192.168.56.30 80 charge"
 "192.168.56.40 80 charge-HA"
 "192.168.77.156 53 dns1"
 "192.168.77.158 53 dns2"
 "172.40.40.57 80 dibarayan"
 "172.40.40.57 443 dibarayan"
 "192.168.60.101 1521 db"
 "192.168.60.102 1521 db"
 "192.168.60.103 1521 db"
 "192.168.60.104 1521 db"
 "192.168.60.105 1521 db"
 "192.168.60.106 1521 db"
 "192.168.60.107 1521 db"
 "192.168.60.115 1521 db"
 "192.168.60.116 1521 db"
 "192.168.60.117 1521 db"
 "192.168.60.119 1521 db"
 "192.168.60.101 6200 db"
 "192.168.60.102 6200 db"
 "192.168.60.103 6200 db"
 "192.168.60.104 6200 db"
 "192.168.60.105 6200 db"
 "192.168.60.106 6200 db"
 "192.168.60.115 6200 db"
 "192.168.60.116 6200 db"
 "192.168.60.119 6200 db"
 "192.168.60.84 6379 redis-ph"
 "192.168.56.45 6379 redis-cluster1-ph"
 "192.168.56.46 6379 redis-cluster2-ph"
 "192.168.56.10 6379 redis-cluster1-ir"
 "192.168.56.11 6379 redis-cluster2-ir"
 "192.168.56.12 6379 redis-cluster3-ir" 
 "192.168.60.92 80 hb-help"
 "192.168.60.92 443 hb-help"
 "10.39.15.199 80 TATA Gateway"
 "10.39.15.199 5001 TATA Gateway"
 "10.39.15.199 3128 TATA Gateway"
 "10.39.15.199 54663 TATA Gateway"
 "10.39.15.199 5003 TATA Gateway"
 "10.39.15.199 5005 TATA Gateway"
 "10.39.15.15 10050 zabbix"
 "10.39.15.15 10051 zabbix"
 "192.168.56.17 9092 ELK"
 "192.168.56.18 9092 ELK"
 "10.39.15.150 8200 APM"

)

# nc -uv 192.168.50.42 123   (ntp connection)
# Loop through each destination and perform telnet connection
for destination in "${DESTINATIONS[@]}"; do
    ip=$(echo "$destination" | awk '{print $1}')
    port=$(echo "$destination" | awk '{print $2}')
    name=$(echo "$destination" | awk '{print $3}')

    # Perform telnet connection with timeout
    result=$(timeout 5 telnet "$ip" "$port" 2>&1)

    # Determine result
    if echo "$result" | grep -q "Connected"; then
        status="Connected"
    elif echo "$result" | grep -q "Connection refused"; then
        status="Connection refused"
    else
        status="Unknown error"
    fi

    # Print result with name
    printf "Connection to %-15s:%-5s %-20s - %s\n" "$ip" "$port" "($name)" "$status"
done




