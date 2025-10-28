#!/bin/bash

# Define the directory to check
MOUNT_POINT="$HOME/SAPPNAS"

# Check if the directory is a mount point
if ! mountpoint -q "$MOUNT_POINT"; then
    echo "Directory '$MOUNT_POINT' is not mounted. Attempting to mount..."
    sudo mount //sappnas/backup ~/SAPPNAS -o gid=$USER,uid=$USER,credentials=/home/tpsapp/.sappnas_creds

    # Verify if unmount was successful
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Successfully mounted '$MOUNT_POINT'."
    fi
fi
