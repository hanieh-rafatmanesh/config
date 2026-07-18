error=$(awk -v d="$(LC_TIME=fa_IR.UTF-8 date +"[%d/%b/%Y:%H:%M" --date="-15 seconds")" \
'$4 >= d && $9 ~ /^5[0-9][0-9]$/ && $0 !~ /hb\.tejaratbank\.ir/' /var/log/nginx/upstream_failed.log | wc -l)

echo -e "# HELP nginx_500_count Number of HTTP 5xx errors in the last minute (excluding hb.tejaratbank.ir)\n# TYPE nginx_500_count gauge\nnginx_500_count $error" \
> /var/lib/node_exporter/nginx_500_count.prom
