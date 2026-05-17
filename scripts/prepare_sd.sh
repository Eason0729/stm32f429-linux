#!/bin/bash
# Prepare TF card at /dev/mmcblk0 for STM32F429I-DISC1 SPI MMC boot
# WARNING: This DESTROYS all data on /dev/mmcblk0!
# No root required - creates rootfs.ext2 as a regular user, then dd's it.
# Relies on udev granting write access to /dev/mmcblk0.

set -euo pipefail

ROOT_DIR="$(dirname "$(dirname "$0")")"
TARGET_DIR="${ROOT_DIR}/buildroot-2026.02/output/target"
IMAGE="${ROOT_DIR}/rootfs.ext2"
DEV="/dev/mmcblk0"

if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Buildroot target directory not found at $TARGET_DIR"
    echo "Run 'make build' first."
    exit 1
fi

# Remove buildroot marker file
rm -f "$TARGET_DIR/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM"

echo "============================================"
echo "  Creating rootfs.ext2 for TF card at $DEV"
echo "  ALL DATA ON $DEV WILL BE DESTROYED!"
echo "============================================"

# Calculate image size: data + 50% overhead + 4MB base for ext2 metadata
SIZE_MB=$(du -sm "$TARGET_DIR" | cut -f1)
SIZE_MB=$((SIZE_MB + SIZE_MB / 2 + 4))
echo "Target directory: ${SIZE_MB}MB (computed)"

# Remove stale image
rm -f "$IMAGE"

# Create sparse image file
echo "Creating ${SIZE_MB}MiB ext2 image..."
truncate -s "${SIZE_MB}M" "$IMAGE"

# Format and populate in one step
echo "Populating filesystem..."
mkfs.ext2 -q -F -d "$TARGET_DIR" "$IMAGE"

# Fix ownership: all files must be owned by root (uid=0, gid=0)
# The ext2 image is a regular file; debugfs writes to it directly (no mount).
echo "Fixing ownership to root..."
{
    echo "sif / uid 0"
    echo "sif / gid 0"
    find "$TARGET_DIR" -mindepth 1 -print0 | while IFS= read -r -d '' f; do
        rel="${f#$TARGET_DIR}"
        echo "sif $rel uid 0"
        echo "sif $rel gid 0"
    done
} | debugfs -w "$IMAGE" >/dev/null 2>&1

sync

echo ""
echo "============================================"
echo "  Writing rootfs.ext2 to $DEV..."
echo "============================================"
dd if="$IMAGE" of="$DEV" bs=1M status=progress conv=fsync

echo ""
echo "============================================"
echo "  TF card is ready!"
echo "============================================"
