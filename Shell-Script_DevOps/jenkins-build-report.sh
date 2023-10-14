#!/bin/bash

# Jenkins credentials
USERNAME="techops-jenkins"
PASSWORD="OpsTech#01"

# Jenkins URL
JENKINS_URL="http://techops.alitasys.com:8080"

# Set the start date and end date
START_DATE=$(date +%Y-%m-%d -d "1 day ago")
END_DATE=$(date +%Y-%m-%d)

# Set the report file name
OUTPUT_FILE="/ops/Jenkins-Build-Report/report/jenkins_build_report_${START_DATE}_${END_DATE}.csv"

# Get list of pipelines
pipelines=$(curl -sSL --user "$USERNAME:$PASSWORD" "$JENKINS_URL/api/json?tree=jobs[name]&pretty=true" | jq -r '.jobs[].name')

# Write CSV header
echo "Pipeline, Total Build Count, Last Build Status, Last Build Time" > "$OUTPUT_FILE"

# Loop through pipelines
for pipeline in $pipelines
do
  # Get build count
  total_build_count=$(curl -sSL --user "$USERNAME:$PASSWORD" "$JENKINS_URL/job/$pipeline/job/$pipeline/api/json?tree=builds[number]&pretty=true" | jq '.builds | length')
  # Get last build status
  last_build_status=$(curl -sSL --user "$USERNAME:$PASSWORD" "$JENKINS_URL/job/$pipeline/job/$pipeline/lastBuild/api/json?tree=result&pretty=true" | jq -r '.result')

  last_build_time=$(curl -sSL --user "$USERNAME:$PASSWORD" "$JENKINS_URL/job/$pipeline/job/$pipeline/lastBuild/api/json?tree=timestamp&pretty=true" | jq -r '.timestamp' | awk '{print strftime("%Y-%m-%d %H:%M:%S", $1/1000)}')
  # Write pipeline info to CSV
  echo "$pipeline, $total_build_count, $last_build_status, $last_build_time">> "$OUTPUT_FILE"
done

echo "Build report generated: $OUTPUT_FILE"

# Set the folder path
folder_path="/ops/Jenkins-Build-Report/report/"

# Get a random file from the folder
file=$(ls $folder_path | shuf -n 1)

# SMTP server settings
SMTP_SERVER="smtp.office365.com"
SMTP_PORT="587"
SMTP_USERNAME="it.support@gove.co"
SMTP_PASSWORD="SolWer@345"
SMTP_FROM="it.support@gove.co"
SMTP_TO="thanga.mariappan@gove.co,harish_raj@gove.co"
SMTP_SUBJECT="Jenkins Build Report - $START_DATE to $END_DATE"
SMTP_BODY="Please find the attached Jenkins automated build report."
SMTP_ATTACHMENT="$folder_path/$file"

# Combine the message body and signature
message_with_signature="$SMTP_BODY\n\n Tech Ops\n Gove Enterprises"

# Send email with attachment using swaks
swaks --from $SMTP_FROM \
      --to $SMTP_TO \
      --server $SMTP_SERVER:$SMTP_PORT \
      --auth-user $SMTP_USERNAME \
      --auth-password $SMTP_PASSWORD \
      --tls \
      --header "Subject: $SMTP_SUBJECT" \
      --body "$message_with_signature" \
      --attach "$SMTP_ATTACHMENT"

# Delete the file once send the email
rm -rf /ops/Jenkins-Build-Report/report//jenkins_build_report_${START_DATE}_${END_DATE}.csv
