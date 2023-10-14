#!/bin/bash

# Define variables
azureDevOpsUsername="thanga.mariappan@gove.co"
azureDevOpsPAT="pzjhxcdodwp5r77vkqabmomzjavaf3kyswf4uohatgddkvx7caiq" # Replace with your PAT or use the SSH key method for authentication.
azureDevOpsOrganization="https://dev.azure.com/goveindia/"
projectName="Application Support"
localServerBackupPath="/opt/backup"

# Function to clone a repository
function CloneRepository {
    repoUrl="$1"
    localPath="$2"
    repoName="$3"

    git clone "$repoUrl" "$localPath"
    if [ $? -eq 0 ]; then
        echo "Cloned repository: $repoName"
    else
        echo "Failed to clone repository: $repoName"
    fi
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq to proceed."
    exit 1
fi

# Authenticate with Azure DevOps
base64AuthInfo=$(echo -n "$azureDevOpsUsername:$azureDevOpsPAT" | base64)
headers="Authorization: Basic $base64AuthInfo"

# Get the list of repositories in the project
projectUrl="$azureDevOpsOrganization$projectName/_apis/git/repositories?api-version=6.0"

# Debug statement to print the API URL
echo "Fetching repository list from: $projectUrl"

reposResponse=$(curl -s --header "$headers" "$projectUrl")

# Debug statement to print the response
echo "Response:"
echo "$reposResponse"

# Check if API request was successful
if [ $? -ne 0 ]; then
    echo "Failed to fetch repository list from Azure DevOps."
    exit 1
fi

repositories=$(echo "$reposResponse" | jq -r '.value[]')

# Check if any repositories found
if [ -z "$repositories" ]; then
    echo "No repositories found in the project: $projectName"
    exit 0
fi

# Loop through each repository and clone it to the local server
for repo in $repositories; do
    repoName=$(echo "$repo" | jq -r '.name')
    repoUrl=$(echo "$repo" | jq -r '.remoteUrl')

    # Construct the local backup path for the repository
    localRepoPath="$localServerBackupPath/$repoName"

    # Echo messages for each repository being cloned
    echo "Cloning repository: $repoName..."

    # Clone the repository
    CloneRepository "$repoUrl" "$localRepoPath" "$repoName"
done

# Optionally, you can add more logic here to handle any other tasks related to the backup.
