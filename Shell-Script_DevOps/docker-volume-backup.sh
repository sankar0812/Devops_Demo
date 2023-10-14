#!/bin/bash

# Define backup directory
backup_dir="/opt/backuped"

# Define target IP addresses and usernames
windows_target="admin@192.168.29.122:C:\\devops"
Linux_target="goveadmin@192.168.29.140:/ops"
# Check if running on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    docker_command="winpty docker"
    copy_command="pscp"
else
   docker_command="docker"
   copy_command="scp"
fi

# Create backup directory if it doesn't exist
mkdir -p $backup_dir

# Backup all Docker volumes
docker volume ls -q | xargs -I {} docker run --rm -v {}:/source -v $backup_dir:/backup alpine tar -czvf /backup/{}.tar.gz -C /source .

# Optional: Clean up old backups (e.g., keep the last 7 backups)
num_backups_to_keep=3

backup_files=("$backup_dir"/*.tar.gz)
# Create tar file with all backups
tar -czvf "$backup_dir/docker_volume_backups-`(date +%Y%m%d)`.tar.gz" -C "$backup_dir" .
# Copy the tar file to the target system
$copy_command "$backup_dir/docker_volume_backups-`(date +%Y%m%d)`.tar.gz" "$Linux_target"
# Copy the tar file to the target systems
$copy_command "$backup_dir/docker_volume_backups-`(date +%Y%m%d)`.tar.gz" "$windows_target"
# The same command works on both Windows and Linux

if [ ${#backup_files[@]} -gt $num_backups_to_keep ]; then
    IFS=$'\n' sorted_backups=($(ls -t "$backup_dir"/*.tar.gz))
    for ((i = $num_backups_to_keep; i < ${#sorted_backups[@]}; i++)); do
        rm "${sorted_backups[$i]}"
    done
fi
