#!/bin/bash
# Bash script to monitor server load and notify via slack
servername=$(hostname)
cpu_threads=$(nproc)
threads_per_core=2
cpu_cores=`expr $cpu_threads / $threads_per_core`
percentage=1.5 # if the server load is 150% of the server total CPU cores then it will send the notification
webhook_URL="Slack Webhook URL"

min_load=$(echo "$cpu_cores * $percentage" | bc)

current_load=$(awk '{print $1}' /proc/loadavg)

# Use bc for floating-point comparison
if (( $(echo "$current_load > $min_load" | bc -l) )); then
    notification="Currently, the load on ${servername} is ${current_load} with ${cpu_cores} CPU. Please look into it."

#create JSON
payload="{\"text\": \"$notification\"}"

#send notification to Slack
curl -X POST -H 'Content-type: application/json' --data "$payload" $webhook_URL

fi