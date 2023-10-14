#!/bin/bash

# Elasticsearch URL and repository name
ES_URL="http://192.168.29.8:9200"
REPO_NAME="my_backup_repo"  # Replace "my_backup_repo" with your desired repository name

# Check if the repository exists; if not, create it
repository_check=$(curl -s -X GET "$ES_URL/_snapshot/$REPO_NAME")
if [[ $repository_check == *"missing"* ]]; then
  echo "Repository not found. Creating repository..."
  curl -X PUT "$ES_URL/_snapshot/$REPO_NAME" -H 'Content-Type: application/json' -d '{
    "type": "fs",
    "settings": {
      "location": "/var/lib/elasticsearch/snapshots"  # Replace with the actual path on your local server
    }
  }'
  echo "Repository created."
else
  echo "Repository already exists."
fi

# Create a snapshot with a timestamp-based name
SNAPSHOT_NAME="snapshot_$(date +'%Y%m%d%H%M%S')"

# Specify the index name here (Replace "my_index" with the desired index name)
INDEX_NAME="user"

# Execute the snapshot creation request
curl -X PUT "$ES_URL/_snapshot/$REPO_NAME/$SNAPSHOT_NAME" -H 'Content-Type: application/json' -d '{
  "indices": "'"$INDEX_NAME"'",
  "ignore_unavailable": true,
  "include_global_state": false
}'
