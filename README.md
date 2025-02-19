# macOS Installer USB Creator

This repository contains scripts to automate the process of creating a bootable macOS installer USB.

## Features
- Automatically detects macOS installers in `/Applications`.
- Lists available USB drives for selection.
- Runs Apple's `createinstallmedia` tool to create a bootable installer.
- Displays real-time progress during installation.
- Validates user input to prevent errors.

## Requirements
- A macOS machine.
- A USB drive with at least **16GB** of space.
- A macOS installer downloaded from the Mac App Store (`Install macOS*.app` in `/Applications`).
- Administrator privileges (sudo access).


## Usage

### Bash Script
1. Open Terminal and navigate to the script directory:
   ```sh
   cd /path/to/script
   ```
2. Give execution permission:
   ```sh
   chmod +x create_installer.sh
   ```
3. Run the script:
   ```sh
   ./create_installer.sh
   ```


## How It Works
1. The script asks whether to auto-detect a macOS installer or manually enter a path.
2. If an installer is found, it confirms the selection.
3. It lists available volumes (USB drives) and asks the user to select one.
4. The script runs the `createinstallmedia` command, displaying progress.
5. Once finished, it confirms that the installer USB is ready.

## Notes
- **Data on the selected USB will be erased!** Ensure you back up important files before proceeding.
- If the script cannot detect an installer automatically, you can manually enter the path to a valid macOS installer.
- You may be prompted for your administrator password when running the script.

## License
This project is licensed under the MIT License.
