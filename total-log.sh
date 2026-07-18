#!/bin/bash

# Nginx access log file path
LOG_FILE="/var/log/nginx/access.log"

# Output file path for Prometheus Node Exporter
OUTPUT_FILE="/var/lib/node_exporter/nginx_request_count.prom"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: $LOG_FILE does not exist."
    exit 1
fi

# Dynamically extract the last timestamp from the log (from recent lines for speed)
LAST_TIMESTAMP=$(tail -n 5000 "$LOG_FILE" | grep -o '\[[0-9]\{2\}/[A-Za-z]\{3\}/[0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} +0330\]' | tail -n 1 | tr -d '[]')

# If no timestamp found (empty log or wrong format)
if [ -z "$LAST_TIMESTAMP" ]; then
    echo "Warning: No valid timestamp found in log."
    REQUEST_COUNT=0
    LAST_TIMESTAMP="none"
else
    # Count requests exactly in that last second
    REQUEST_COUNT=$(grep "\[${LAST_TIMESTAMP}\]" "$LOG_FILE" | wc -l)
fi

# Default to 0 if empty
REQUEST_COUNT=${REQUEST_COUNT:-0}

# Write metric to file in Prometheus format (with timestamp label)
cat > "$OUTPUT_FILE" << EOF
# HELP nginx_requests_last_second Number of requests in the most recent logged second
# TYPE nginx_requests_last_second gauge
nginx_total_request_count $REQUEST_COUNT
EOF

# Optional: print to console for debugging
echo "Last second in log: [$LAST_TIMESTAMP]"
echo "Requests in this second: $REQUEST_COUNT"
echo "Metric written to: $OUTPUT_FILE"
~


