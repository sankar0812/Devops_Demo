repo_url="https://dev.azure.com/your_organization/your_project/_git/your_repo"
repo_dir="/opt/backup"

if [ -d "$repo_dir" ]; then
    echo "Repository directory already exists. Updating..."
    cd "$repo_dir"
    git pull
else
    echo "Cloning the repository..."
    git clone "$repo_url" "$repo_dir"
    cd "$repo_dir"
fi
# Set the start date and end date
START_DATE=$(date +%Y-%m-%d -d "1 day ago")
END_DATE=$(date +%Y-%m-%d)

# Set the report file name
OUTPUT_FILE="/ops/Jenkins-Build-Report/report/jenkins_build_report_${START_DATE}_${END_DATE}.csv"
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
SMTP_TO=""
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
