#!/bin/bash
# ===================================================================
# 🗑️ Turing Smart Screen Uninstallation Script
# This script will:
# 1. Stop and disable the systemd service.
# 2. Remove the systemd service file.
# 3. Securely remove the application directory.
# Author: Bruno (Created with Gemini)
# ===================================================================

set -e # Stop on any error

# --- Configuration ---
# ⚠️ IMPORTANT: Please verify these variables match your setup!
SERVICE_NAME="turing-smart-screen.service"
PROJECT_DIR="/opt/turing-smart-screen-python" # The main directory of your application
# --- End of Configuration ---

SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

echo "Uninstalling Turing Smart Screen..."
echo "-------------------------------------"

# ------------------------------------------------------------
# 1️⃣ Stop and Disable the Systemd Service
# ------------------------------------------------------------
echo "🛑 Stopping and disabling the systemd service..."
if systemctl is-active --quiet "$SERVICE_NAME"; then
    sudo systemctl stop "$SERVICE_NAME"
    echo "Service stopped."
else
    echo "Service was not running."
fi

if systemctl is-enabled --quiet "$SERVICE_NAME"; then
    sudo systemctl disable "$SERVICE_NAME"
    echo "Service disabled from startup."
else
    echo "Service was not enabled."
fi

# ------------------------------------------------------------
# 2️⃣ Remove the Systemd Service File
# ------------------------------------------------------------
echo "🚮 Removing the systemd service file..."
if [ -f "$SERVICE_FILE" ]; then
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
    echo "✅ Service file removed and systemd reloaded."
else
    echo "⚠️ Service file not found, skipping."
fi

# ------------------------------------------------------------
# 3️⃣ Remove the Project Directory
# ------------------------------------------------------------
echo "🔥 Preparing to delete the project directory: $PROJECT_DIR"
echo "   This action is IRREVERSIBLE and will delete the venv, scripts, and all configurations."
echo ""

read -p "Are you absolutely sure you want to delete this directory? [y/N] " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    if [ -d "$PROJECT_DIR" ]; then
        echo "Deleting directory: $PROJECT_DIR..."
        sudo rm -rf "$PROJECT_DIR"
        echo "✅ Project directory successfully deleted."
    else
        echo "⚠️ Project directory not found, skipping."
    fi
else
    echo "Deletion aborted by user. The project directory has NOT been removed."
    exit 0
fi

# ------------------------------------------------------------
# 4️⃣ Optional Cleanup Suggestion
# ------------------------------------------------------------
echo ""
echo "💡 Optional Cleanup: System Dependencies"
echo "The setup script installed some system packages (like python3-dev, libjpeg-dev, etc.)."
echo "These are NOT removed automatically, as they might be used by other applications."
echo "If you are sure you no longer need them, you can run a command like 'sudo apt autoremove' to clean up unused packages."

# ------------------------------------------------------------
# 5️⃣ Final Message
# ------------------------------------------------------------
echo ""
echo "🎉 Uninstallation complete!"
echo "The Turing Smart Screen service and application files have been removed."
