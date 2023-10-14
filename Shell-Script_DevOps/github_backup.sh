#!/bin/bash

# GitHub Details
github_username="thangamtm"

# Local Backup Path
backup_path="/opt"

# GitHub Personal Access Token (PAT) with "repo" scope for private repositories
pat="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"

# Date for the backup file name
backup_date=$(date +"%Y-%m-%d")

# Get a list of all your repositories (public and private)
repositories=$(curl -s -H "Authorization: token $pat" "https://api.github.com/user/repos?per_page=100" | jq -r '.[].full_name')

# Loop through each repository and perform the backup
for repo_name in $repositories; do
  # Clone the repository if it doesn't exist
  if [ ! -d "$backup_path/$repo_name" ]; then
    git clone --mirror "https://github.com/$repo_name" "$backup_path/$repo_name"
  fi

  # Update the backup for the repository
  cd "$backup_path/$repo_name"
  git remote update --prune

  echo "Backup completed for repository: $repo_name"
done
