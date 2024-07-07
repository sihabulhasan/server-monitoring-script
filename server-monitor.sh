#!/bin/bash
# Bash script to monitor server load & disk usage and notify via slack
servername=$(hostname)
cpu_threads=$(nproc)
threads_per_core=2
cpu_cores=`expr $cpu_threads / $threads_per_core`
percentage=1.5 # if the server load is 150% of the server total CPU cores then it will send the notification
disk_threshold=25

# Set Incoming Webhook URL
WEBHOOK_URL="Slack Webhook URL"

# Start script for server load

min_load=$(echo "$cpu_cores * $percentage" | bc)

current_load=$(awk '{print $1}' /proc/loadavg)

# Use bc for floating-point comparison
if (( $(echo "$current_load > $min_load" | bc -l) )); then
    load_notification="Current load on ${servername} is ${current_load} with ${cpu_cores} CPU. Please look into it."
fi
# End script for server load

# Start script for Disk usage
# Get the disk usage percentage for the root partition
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

# Check if the usage exceeds
if [ $USAGE -gt $disk_threshold ]; then
	disk_notification="Current Disk Usage on $servername is $USAGE%. Please look into it."

fi

# create JSON
payload="{\"text\": \"${load_notification}\n${disk_notification}\"}"
# End script for Disk usage

# send notification
curl -X POST -H 'Content-type: application/json' --data "$payload" $WEBHOOK_URL