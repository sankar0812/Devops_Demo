#!/bin/bash

# Define backup directory
backup_dir="/opt/backup"

#set -x
# Check if running on Windows
#if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
#    docker_command="winpty docker"
#else
 #   docker_command="docker"
#fi

# Get a list of all Docker volumes
#volume_list=$($docker_command volume ls --quiet)

# Create backup directory if it doesn't exist
mkdir -p $backup_dir

# Loop through each volume and create a backup
#for volume in $volume_list; do
 #   volume_name=$($docker_command volume inspect --format '{{.Name}}' $volume)

    # Create a backup filename based on volume name and timestamp
  #  backup_filename="${backup_dir}/${volume_name}_$(date +%Y%m%d%H%M%S).tar.gz"

    # Create a temporary container to mount the volume and create a backup
#    if $docker_command run --rm -v $volume_name:/data -v $backup_dir:/backup alpine tar -czvf $backup_filename -C /data . 2>> "$backup_dir/backup2"; then
    docker volume ls -q | xargs -I {} docker run --rm -v {}:/source -v $backup_dir:/backup alpine tar -czvf /backup/{}.tar.gz -C /source .
    # Check if the backup was successful
    if [ $? -eq 0 ]; then
        echo "Backup of $volume_name completed successfully."
    else
        echo "Backup of $volume_name failed."
    fi
#done

# Optional: Clean up old backups (e.g., keep the last 7 backups)
backup_files=("$backup_dir"/*.tar.gz)
num_backups_to_keep=7

if [ ${#backup_files[@]} -gt $num_backups_to_keep ]; then
    IFS=$'\n' sorted_backups=($(ls -t "$backup_dir"/*.tar.gz))
    for ((i = $num_backups_to_keep; i < ${#sorted_backups[@]}; i++)); do
        rm "${sorted_backups[$i]}"
    done
fi
