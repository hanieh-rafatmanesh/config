Telegraf is designed to collect metrics from **Nginx, Docker, and many other services** using its **input plugins**. It can then send this data to **InfluxDB** for storage and visualization in **Grafana**



## **Install InfluxDB in Grafana Server**

### **influxDB docker compose**:

```
version: '2'
services:
  influxdb:
    image: influxdb
    container_name: influxdb
    restart: always
    ports:
      - 8086:8086
    networks:
      - monitoring
    volumes:
      - influxdb-volume:/var/lib/influxdb
    environment :
      - INFLUXDB_DATA_MAX_VALUES_PER_TAG=0
      - INFLUXDB_DATA_MAX_SERIES_PER_DATABASE=1500000000
networks:
  monitoring:
      ipam:
          driver: default
          config:
              - subnet: 172.10.0.0/16
volumes:
  grafana-volume:
    external: true
  influxdb-volume:
    external: true

```

**Access the InfluxDB UI:**

- Open a browser and go to `http://<INFLUXDB_SERVER_IP>:8086`.
- Complete the setup wizard to create:
  - Admin username and password
  - Organization name. e.g. ,mbt
  - Bucket name . e.g. ,mbt
  - API token (save this token for later).

### **Install Telegraf**

1. **install `telegraf` as a service to scrape containers metrics**

   ```
   dpkg -i telegraf_1.25.3-1_amd64.deb  
   ```

2. **add telegraf user to docker group:**

   ```
   sudo usermod -aG docker telegraf
   sudo systemctl restart telegraf
   ```

### **Configure Telegraf**

1. **Edit the configuration file:**

   ```
   sudo vim /etc/telegraf/telegraf.conf
   ```

2. **Update the `[outputs.influxdb]` section:** Add the InfluxDB server address and credentials:

   ```
   [[outputs.influxdb]]
     urls = ["http://<INFLUXDB_SERVER_IP>:8086"]
     token = "<INFLUXDB_TOKEN>" # in section of installation INFLUXDB
     organization = "<ORG_NAME>" e.g., mbt
     bucket = "<BUCKET_NAME>" e.g., mbt
   ```

## **Connect InfluxDB to Grafana as a Data Source**

1. **Login to Grafana:** Navigate to `http://<GRAFANA_SERVER_IP>:3000` and log in.
2. **Add InfluxDB as a data source:**
   - Go to **Configuration** > **Data Sources** > **Add Data Source**.
   - Select **InfluxDB**.
   - Fill in the following details:
     - **Query Language:** Flux
     - **URL:** `http://<INFLUXDB_SERVER_IP>:8086`
     - **Organization:** The organization name you created in InfluxDB.
     - **Token:** The API token you saved earlier.
   - Click **Save & Test**.
