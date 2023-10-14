#!/bin/bash

# Flag to track if email has been sent
email_sent=false

# Infinite loop to check MongoDB status every 5 minutes
while true; do
    # Check if the mongod service is running
    ping -c30 -i3 192.168.29.106
#    nping -p 80 localhost
    if [ $? -eq 0 ]; then
        echo "express service is running."
    exit 0
    else
        echo "Express service not running”

        if ! $email_sent; then
            SMTP_SERVER="smtp.office365.com"
            SMTP_PORT="587"
            SMTP_USERNAME="it.support@gove.co"
            SMTP_PASSWORD="SolWer@345"
            SMTP_FROM="it.support@gove.co"
            SMTP_TO="sankara.subramanian@gove.co"
            SMTP_SUBJECT="express is stopped"
            SMTP_BODY="express is stopped in prod"

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

            echo "Email notification sent."

            # Set the flag to true to indicate that an email has been sent
            email_sent=true
        else
            echo "Email already sent"
        fi
    fi

    # Delay for 5 minutes
    sleep 10
done
