#!/bin/bash

# Define the directory to check
MOUNT_POINT="$HOME/SAPPNAS"

# Check if the directory is a mount point
if mountpoint -q "$MOUNT_POINT"; then
    echo "Directory '$MOUNT_POINT' is mounted. Attempting to unmount..."
    sudo umount "$MOUNT_POINT"

    # Verify if unmount was successful
    if ! mountpoint -q "$MOUNT_POINT"; then
        echo "Successfully unmounted '$MOUNT_POINT'."
    else
        echo "Failed to unmount '$MOUNT_POINT'. Forcefully unmounting."
        # Optional: Attempt a force unmount if absolutely necessary and understood risks
        sudo umount -f "$MOUNT_POINT"
    fi
fi
