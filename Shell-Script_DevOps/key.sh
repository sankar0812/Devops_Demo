]#!/bin/bash

# Load configuration
source config.sh

# Generate a timestamp for the backup directory
backupDate=$(date +'%Y-%m-%d_%H-%M-%S')

# Set the start date and end date
START_DATE=$(date +%Y-%m-%d -d "1 day ago")
END_DATE=$(date +%Y-%m-%d)

# Function to clone a repository and generate report
function CloneRepository {
    local repoUrl="$1"
    local localPath="$2"
    local repoName="$3"

    git clone --recurse-submodules -b develop "$repoUrl" "$localPath" 2>&1
    if [ $? -eq 0 ]; then
        echo "Cloned repository: $repoName"
        cd "$localPath"
        npm install
        npm run generate-report -- --configFile=config/repo.info.json
        cd -
    else
        echo "Failed to clone repository: $repoName"
        exit 1
    fi
}

# Clone the repository and generate report
repoUrl="https://dev.azure.com/goveindia/Baas-360/_git/BAAS-DEV-REPORTS"
localPath="$backupBasePath/$backupDate/BAAS-DEV-REPORTS"
CloneRepository "$repoUrl" "$localPath" "BAAS-DEV-REPORTS"

# SMTP server settings
SMTP_SERVER="smtp.office365.com"
SMTP_PORT="587"
SMTP_USERNAME="it.support@gove.co"
SMTP_PASSWORD="SolWer@345"
SMTP_FROM="it.support@gove.co"
SMTP_TO="sankara.subramanian@gove.co"
SMTP_SUBJECT="Azure Repo Status - $START_DATE to $END_DATE"

# Combine the message body and signature
message_with_signature="Hello Sir/Mam,

Hereby we have attached Azure Repo Status Report on $END_DATE for your kind perusal.

Tech Ops
Gove Enterprises"

# Send email with attachment using swaks
swaks --from $SMTP_FROM \
      --to "$SMTP_TO" \
      --server "$SMTP_SERVER:$SMTP_PORT" \
      --auth-user "$SMTP_USERNAME" \
      --auth-password "$SMTP_PASSWORD" \
      --tls \
      --header "Subject: $SMTP_SUBJECT" \
      --body "$message_with_signature" \
      --attach "$SMTP_ATTACHMENT" \
      --add-header "Cc: thanga.mariappan@gove.co"
