#!/bin/zsh

# Raspberry Lite ARM 64
IMAGE_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2025-12-04/2025-12-04-raspios-trixie-arm64-lite.img.xz"

DOWNLOAD_URL="https://downloads.raspberrypi.org/imager/"
TEMP_DMG="/tmp/rpi-imager.dmg"

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_DATA="${CURRENT_DIR}/user-data"
NET_DATA="${CURRENT_DIR}/network-configa"

echo "Searching for external SSD/USB drive..."
DISKS=(${(f)"$(diskutil list external physical | grep '/dev/disk' | awk '{print $1}')"})

if (( ${#DISKS} == 0)) ; then
    echo "Error: No external drive found."
    exit 1
fi

for i in {1..${#DISKS[@]}}; do
    DISK=$DISKS[$i]
    INFO=$(diskutil info "$DISK" | awk -F: '/Device \/ Media Name/ {print $2}' | sed 's/^ *//')
    SIZE=$(diskutil info "$DISK" | awk -F: '/Disk Size/ {print $2}' | sed 's/^ *//' | awk '{print $1, $2}')
    echo "[$i] $DISK - $SIZE ($INFO)"
done

echo -n "Please select drive number as target."
read SELECTION

if [[ ! "$SELECTION" =~ ^[0-9]+$ ]] || (( SELECTION < 1 || SELECTION > ${#DISKS[@]} )); then
    echo "Invalid input"
    exit 1
fi

TARGET_DISK="${DISKS[$SELECTION]}"
RAW_DISK="${TARGET_DISK/disk/rdisk}"
echo "Target: $TARGET_DISK ($RAW_DISK)"

echo "Downloading for the latest rpi-imager..."

# IDENTIFY THE LATEST IMAGE
LATEST_VERSION=$(curl -s $DOWNLOAD_URL | grep -o 'imager_[0-9.]*.dmg' | tail -n 1)
DMG_URL="$DOWNLOAD_URL$LATEST_VERSION"

if [[ -z "$LATEST_VERSION" ]]; then
    echo "Failed to identify latest verion, please check url"
    exit 1
fi

echo "Downloading: $LATEST_VERSION"
#curl -L "$DMG_URL" -o "$TEMP_DMG"

MOUNT_INFO=$(hdiutil attach "$TEMP_DMG" -nobrowse -plist)
MOUNT_DEV=$(echo "$MOUNT_INFO" | grep -A 1 "dev-entry" | grep "string" | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | head -n 1)
MOUNT_PATH=$(echo "$MOUNT_INFO" | grep -A 1 "mount-point" | grep "string" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

if [[ -z "$MOUNT_PATH" ]]; then
    echo "Failed to mount DMG image."
    exit 1
fi

IMAGER_BIN="${MOUNT_PATH}/Raspberry Pi Imager.app/Contents/MacOS/rpi-imager"

# NEED UNMOUNTING DISK BEFORE WRITING.
echo "Unmounting $TARGET_DISK..."
diskutil unmountDisk "$TARGET_DISK"

# IMAGE WRITING
echo "Writing image to $TARGET_DISK... (Sudo password may be required)"
sudo "$IMAGER_BIN" --cli \
    --cloudinit-userdata "$USER_DATA" \
    --cloudinit-networkconfig "$NET_CONFIG" \
    "$IMAGE_URL" "$TARGET_DISK"

# CLEAN UP
#echo "Cleaning up..."
hdiutil detach "$MOUNT_DEV"
#rm "$TEMP_DMG"

echo "Done! SSD is ready."
