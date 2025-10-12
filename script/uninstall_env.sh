#!/bin/bash
# ============================================================
# 🧹 Safe Uninstall Script for Python Environment
# For Ubuntu — cleans up the environment created by the setup script
# Author: Bruno
# ============================================================

# 1️⃣ Confirm with the user before starting
echo "⚠️ This script will permanently remove the following:"
echo "   - The 'venv' virtual environment directory"
echo "   - The 'requirements.txt' file"
echo ""
read -p "Are you sure you want to continue? [y/N] " confirm
echo ""

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "🛑 Uninstall cancelled by user."
    exit 1
fi

# 2️⃣ Deactivate virtual environment if it's active
# This is good practice, though removing the directory makes it unusable anyway.
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "🐍 Deactivating active virtual environment..."
    deactivate
fi

# 3️⃣ Remove the virtual environment directory
if [ -d "venv" ]; then
    echo "🗑️ Removing virtual environment directory: venv/"
    rm -rf venv
    echo "✅ 'venv' directory removed."
else
    echo "🤷 'venv' directory not found. Skipping."
fi

# 4️⃣ Remove the requirements.txt file
if [ -f "requirements.txt" ]; then
    echo "🗑️ Removing requirements file: requirements.txt"
    rm requirements.txt
    echo "✅ 'requirements.txt' file removed."
else
    echo "🤷 'requirements.txt' not found. Skipping."
fi

echo ""
echo "🎉 Local environment cleanup complete!"
echo "------------------------------------------------------------"

# 5️⃣ Optional: Remove system-level packages
echo "📦 The original script installed system packages with 'apt'."
echo "⚠️ WARNING: Other projects on your system may depend on these packages!"
echo "   Only proceed if you are sure you no longer need them."
echo ""
read -p "Do you want to attempt to remove system packages? [y/N] " confirm_apt

if [[ "$confirm_apt" =~ ^[Yy]$ ]]; then
    echo "🔧 Removing system development packages..."
    # We will NOT remove python3 or build-essential as they are critical.
    # We only target the specific libraries installed for this project.
    sudo apt remove --purge -y \
        python3-pip \
        python3-venv \
        python3-tk \
        python3-dev \
        libdrm-dev

    echo "🧹 Running autoremove to clean up any unused dependencies..."
    sudo apt autoremove -y
    echo "✅ System package cleanup complete."
else
    echo "👍 Skipping removal of system packages."
fi

echo ""
echo "🎉 Uninstall process finished!"