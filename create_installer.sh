#!/bin/bash
# create_installer.sh
# A script to automate creating a macOS installer USB

# --- Greeting ---
echo "========================================"
echo "Welcome to the macOS Installer USB Creator!"
echo "This script will help you create a bootable macOS installer USB."
echo "Created By Charlie Hardin - https://charliehardin.github.io"
echo "========================================"
echo ""

# --- Installer Selection ---
read -rp "Would you like to automatically scan for a macOS installer in /Applications? (y/n): " auto_choice

if [[ "$auto_choice" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Scanning for macOS installers in /Applications..."
    # Create an empty array for installer candidates
    installer_candidates=()
    # Read each line from find into the array
    while IFS= read -r line; do
        installer_candidates+=("$line")
    done < <(find /Applications -maxdepth 1 -type d -name "Install macOS*" 2>/dev/null)
    
    if [ ${#installer_candidates[@]} -eq 0 ]; then
        echo "No macOS installers found in /Applications."
        read -rp "Enter the full path to your macOS Installer.app: " installer_path
    elif [ ${#installer_candidates[@]} -eq 1 ]; then
        installer_path="${installer_candidates[0]}"
        echo "Found one macOS installer: $installer_path"
        read -rp "Do you want to use this installer? (y/n): " confirm_installer
        if [[ ! "$confirm_installer" =~ ^[Yy]$ ]]; then
            read -rp "Enter the full path to your macOS Installer.app: " installer_path
        fi
    else
        echo "Found multiple macOS installers:"
        for i in "${!installer_candidates[@]}"; do
            echo "$((i+1)). ${installer_candidates[$i]}"
        done
        read -rp "Enter the number of the installer you want to use: " installer_choice
        installer_index=$((installer_choice - 1))
        installer_path="${installer_candidates[$installer_index]}"
        echo "You selected: $installer_path"
        read -rp "Do you want to use this installer? (y/n): " confirm_installer
        if [[ ! "$confirm_installer" =~ ^[Yy]$ ]]; then
            read -rp "Enter the full path to your macOS Installer.app: " installer_path
        fi
    fi
else
    read -rp "Enter the full path to your macOS Installer.app: " installer_path
fi

# Validate installer path
if [ ! -d "$installer_path" ]; then
    echo "Error: Installer app not found at '$installer_path'"
    exit 1
fi

# --- List Available Volumes ---
echo ""
echo "Available Volumes:"
df -h | grep '/Volumes/'
echo ""
echo "Mounted volumes (from /Volumes directory):"
ls -1 /Volumes
echo ""

# --- Get USB Volume Name ---
read -rp "Enter the volume name (as it appears in /Volumes) of the USB drive to use: " volume_name

if [ ! -d "/Volumes/$volume_name" ]; then
    echo "Error: USB drive not found at /Volumes/$volume_name"
    exit 1
fi

# --- Confirm the Choices ---
echo ""
echo "About to create the installer on:"
echo "    Volume: /Volumes/$volume_name   WARNING: THIS VOLUME WILL BE WIPED!"
echo "    Using Installer: $installer_path"
echo ""
read -rp "Press [Enter] to continue or Ctrl+C to abort..."

# --- Spinner Function ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\rProgress: ${spinstr:$i:1}"
            sleep $delay
        done
    done
    printf "\r"
}

# --- Run createinstallmedia Command ---
echo ""
echo "Starting the installer creation process..."
echo "You may be prompted for your administrator password."
echo ""

# Run the createinstallmedia command in a subshell
(
  sudo "$installer_path/Contents/Resources/createinstallmedia" --volume "/Volumes/$volume_name" --nointeraction 2>&1 | tee /tmp/createinstallmedia.log
) &
cmd_pid=$!

# Start the spinner in the background.
spinner $cmd_pid &
spinner_pid=$!

# Wait for the installer command to finish.
wait $cmd_pid

# Kill the spinner if it's still running.
kill $spinner_pid 2>/dev/null

# --- Finished ---
echo ""
echo "========================================"
echo "Installer USB creation is complete!"
echo "You can now use your bootable installer USB."
echo "========================================"
