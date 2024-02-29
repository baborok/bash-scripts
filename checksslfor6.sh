#!/bin/bash

output_file="/var/log/ssl_expiry.prom"

# Original function to check SSL expiry with domain, IP, and label
check_ssl_expiry() {
    domain=$1
    ip=$2
    label=$3
    metric_name="ssl_certificate_expiry_days"

    expire_date=$(curl https://${domain} --resolve "${domain}:443:${ip}" -vI --stderr - 2>/dev/null | grep "expire date" | cut -d':' -f2- | xargs)
    expiry_timestamp=$(date -ud "$expire_date" +%s)
    current_timestamp=$(date +%s)
    expiry_days=$(( (expiry_timestamp - current_timestamp) / 86400 ))

    echo "${metric_name}{domain=\"$domain\", ip=\"$ip\", label=\"$label\"} $expiry_days" >> ${output_file}
}

# New function to check SSL expiry without specifying an IP
check_ssl_expiry_url() {
    url=$1
    label=$2
    metric_name="ssl_certificate_expiry_days_url"

    expire_date=$(curl --location "${url}" -vI --stderr - 2>/dev/null | grep "expire date" | cut -d':' -f2- | xargs)
    expiry_timestamp=$(date -ud "$expire_date" +%s)
    current_timestamp=$(date +%s)
    expiry_days=$(( (expiry_timestamp - current_timestamp) / 86400 ))

    # Assuming you want to extract the domain from the URL for labeling
    domain=$(echo $url | awk -F/ '{print $3}')

    echo "${metric_name}{url=\"$url\", domain=\"$domain\", label=\"$label\"} $expiry_days" >> ${output_file}
}

> ${output_file} # Clear the output file before writing

# Call the original function with specified domains, IPs, and labels
check_ssl_expiry "domain" "ip" "label"


# Call the new function for the URL without IP resolution
check_ssl_expiry_url "url" "labels"
