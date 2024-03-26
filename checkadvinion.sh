#!/bin/bash

output_file="/etc/prometheus/googlePlayMetrics/textfile/ssl_expiry.prom"

check_ssl_expiry_url() {
    url=$1
    label=$2
    metric_name="ssl_certificate_expiry_days_url"

    # Get the expiration date from the curl response
    expire_date=$(curl -sS "${url}" | jq -r '.expiration')

    # Reformat expiration date from MM.DD.YYYY to YYYY-MM-DD
    formatted_expire_date=$(echo $expire_date | awk -F. '{print $3"-"$1"-"$2}')

    # Convert expiration date to timestamp
    expiry_timestamp=$(date -d "$formatted_expire_date" +%s)
    current_timestamp=$(date +%s)
    expiry_days=$(( (expiry_timestamp - current_timestamp) / 86400 ))

    # Extract domain from the URL for labeling
    domain=$(echo $url | awk -F/ '{print $3}')

    # Write the metric to the output file
    echo "${metric_name}{url=\"$url\", domain=\"$domain\", label=\"$label\"} $expiry_days" >> ${output_file}
}


# Clear the output file before writing
> ${output_file}

# Call the function for the URL
check_ssl_expiry_url "url" "label"
