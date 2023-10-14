#!/bin/bash

# Define variables
volume_name="1b814bdc87dd99b24019f0e1adc5f303a234a21ae6a28e7ad75291293f2d4e51"
backup_dir="/opt/backup"
backup_filename="backup_$(date +%Y%m%d%H%M%S).tar.gz"

# Check if the volume exists
if docker volume inspect $volume_name >/dev/null 2>&1; then
    # Create a temporary container to mount the volume and create a backup
    docker run --rm -v $volume_name:/data -v $backup_dir:/backup alpine tar -czvf /backup/$backup_filename -C /data .

    # Check if the backup was successful
    if [ $? -eq 0 ]; then
        echo "Backup completed successfully."
    else
        echo "Backup failed."
    fi
else
    echo "Error: Volume '$volume_name' does not exist."
fi

# Optional: Clean up old backups (e.g., keep the last 7 backups)
backup_files=("$backup_dir"/*)
num_backups_to_keep=7

if [ ${#backup_files[@]} -gt $num_backups_to_keep ]; then
    IFS=$'\n' sorted_backups=($(ls -t "$backup_dir"))
    for ((i = $num_backups_to_keep; i < ${#sorted_backups[@]}; i++)); do
        rm "$backup_dir/${sorted_backups[$i]}"
    done
fi
