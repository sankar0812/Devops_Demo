# CreatedBy     : Harish Raj
# CreatedTime   : 21 Feb 2023

#JENKINS_URL="http://techops.alitasys.com:8080/bbos"
						#USERNAME="techops-jenkins"
						#PASSWORD="OpsTech#01"
						#PIPELINE_NAME=$(curl -sSL --user "$USERNAME:$PASSWORD" "$JENKINS_URL/api/json?tree=jobs[name]&pretty=true" | jq -r '.jobs[].name')
						#BUILD_NUMBER=$(curl -s --user $USERNAME:$PASSWORD $JENKINS_URL/job/$JOB_NAME/job/$JOB_NAME/api/json | jq -r '.lastBuild.number')
						# Set job name and build number
						#JOB_NAME= ${PIPELINE_NAME}

						# Set output file name and path
						#OUTPUT_FILE="PLATFORM-REST-DATA-ACCESS-CONSOLE-OUTPUT.txt"
						#OUTPUT_PATH="/ops/Jenkins-Build-Report/pipeline-console-output/$OUTPUT_FILE"

						# Get console output using Jenkins Remote Access API
						#curl --user $USERNAME:$PASSWORD "$JENKINS_URL/job/$JOB_NAME/job/$JOB_NAME/$BUILD_NUMBER/consoleText" -o $OUTPUT_PATH
						
						# SMTP server settings
SMTP_SERVER="smtp.office365.com"
SMTP_PORT="587"
SMTP_USERNAME="it.support@gove.co"
SMTP_PASSWORD="SolWer@345"
SMTP_FROM="it.support@gove.co"
SMTP_TO="harish_raj@gove.co,sankara.subramanian@gove.co,thanga.mariappan@gove.co,dineshpandian@gove.co,arumugam.petchikumar@gove.co,ayerathammal.paramasivan@gove.co,uma.kohila@gove.co,pradeepa.sekar@gove.co,diviya.rathinamoorthi@gove.co,senthilkumar@alitasys.com"
SMTP_SUBJECT="[TEST] - [DEPLOYMENT ENDS] : "${JOB_NAME}_${BUILD_NUMBER}
SMTP_BODY="Automated Deployment is completed, latest code has been deployed and we have attached the CONSOLE OUTPUT log for your reference. Happy coding!!"
#SMTP_ATTACHMENT="/ops/Jenkins-Build-Report/pipeline-console-output/PLATFORM-REST-DATA-ACCESS-CONSOLE-OUTPUT.txt"

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
      --body "$message_with_signature"
      

