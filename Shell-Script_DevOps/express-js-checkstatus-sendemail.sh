#!/bin/bash

# Flag to track if email has been sent
email_sent=false

# Infinite loop to check Express status every 5 minutes
while true; do
    # Check if the Express.js service is running
    telnet 192.168.29.106 3000

    if []; then
        echo "Express service is running."

    else
        echo "Express service not running"

        if ! $email_sent; then
            SMTP_SERVER="smtp.office365.com"
            SMTP_PORT="587"
            SMTP_USERNAME="it.support@gove.co"
            SMTP_PASSWORD="SolWer@345"
            SMTP_FROM="it.support@gove.co"
            SMTP_TO="sankara.subramanian@gove.co"
            SMTP_SUBJECT="Express is stopped"
            SMTP_BODY="Express is stopped in prod"

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
            echo "Email already sent. Not sending again."
        fi
    fi

    # Delay for 5 minutes
    sleep 10
done
