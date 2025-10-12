#!/bin/bash
# ============================================================
# 🧠 Python Environment Setup Script (Multi-Distro, Full)
# Ensures ruamel.yaml, Pillow, GPUtil installed correctly
# Activates virtualenv and runs configure.py automatically
# Supports Ubuntu/Debian and Fedora/RHEL/CentOS
# Author: Bruno
# ============================================================

set -e  # stop on any error

# ------------------------------------------------------------
# 1️⃣ Detect Linux distribution
# ------------------------------------------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "❌ Could not detect Linux distribution. Exiting."
    exit 1
fi

case "$DISTRO" in
    ubuntu|debian)
        PKG_MANAGER="apt"
        PY_DEV="python3-dev"
        DRM_DEV="libdrm-dev"
        UPDATE_CMD="sudo apt update || true && sudo apt upgrade -y || true"
        INSTALL_CMD="sudo apt install -y"
        ;;
    fedora|rhel|centos|rocky|alma)
        PKG_MANAGER="dnf"
        PY_DEV="python3-devel"
        DRM_DEV="libdrm-devel"
        UPDATE_CMD="sudo dnf update -y"
        INSTALL_CMD="sudo dnf install -y"
        ;;
    *)
        echo "⚠️ Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "✅ Detected distribution: $DISTRO"
echo "📦 Using package manager: $PKG_MANAGER"
echo "🐍 Python dev package: $PY_DEV"
echo "🖥️ DRM dev package: $DRM_DEV"

# ------------------------------------------------------------
# 2️⃣ Update system (ignore invalid PPAs)
# ------------------------------------------------------------
echo "🔄 Updating system (ignoring invalid PPAs)..."
if [ "$PKG_MANAGER" = "apt" ]; then
    for file in /etc/apt/sources.list.d/*.list; do
        sudo cp "$file" "$file.bak"
        sudo sed -i 's/^/#/' "$file"
    done
    sudo apt update || true
    sudo apt upgrade -y || true
    for file in /etc/apt/sources.list.d/*.list; do
        sudo mv "$file.bak" "$file" 2>/dev/null || true
    done
else
    eval "$UPDATE_CMD"
fi

# ------------------------------------------------------------
# 3️⃣ Install Python, dev packages, and graphics libraries
# ------------------------------------------------------------
echo "📦 Installing Python, dev packages, and graphics libraries..."
if [ "$PKG_MANAGER" = "apt" ]; then
    eval "$INSTALL_CMD python3 python3-pip python3-venv python3-tk $PY_DEV build-essential $DRM_DEV \
        libjpeg-dev libpng-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev \
        tcl-dev tk-dev libffi-dev libssl-dev"
else
    eval "$INSTALL_CMD python3 python3-pip python3-venv python3-tk $PY_DEV $DRM_DEV \
        libjpeg-turbo-devel libpng-devel libtiff-devel zlib-devel freetype-devel lcms2-devel libwebp-devel \
        tcl-devel tk-devel libffi-devel openssl-devel"
fi

# ------------------------------------------------------------
# 4️⃣ Create and activate virtual environment
# ------------------------------------------------------------
echo "🐍 Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# ------------------------------------------------------------
# 5️⃣ Create requirements.txt with exact versions
# ------------------------------------------------------------
echo "📝 Generating requirements.txt..."
cat <<EOF > requirements.txt
pyserial==3.5
PyYAML==6.0.2
psutil==7.0.0
pystray==0.19.5
babel==2.17.0
ruamel.yaml==0.18.10
sv-ttk==2.6.0
tkinter-tooltip==3.1.2
uptime==3.0.1
requests==2.32.3
ping3==4.0.8
pyinstaller==6.13.0
Pillow==11.2.1
GPUtil==1.4.0
EOF

# ------------------------------------------------------------
# 6️⃣ Upgrade pip and install Python packages
# ------------------------------------------------------------
echo "⚙️ Upgrading pip..."
pip install --upgrade pip

echo "⚙️ Installing Python packages from requirements.txt..."
pip install --force-reinstall -r requirements.txt

# ------------------------------------------------------------
# 7️⃣ Force-reinstall ruamel.yaml, Pillow, GPUtil explicitly
# ------------------------------------------------------------
echo "⚡ Force-reinstalling ruamel.yaml, Pillow, GPUtil to ensure proper import..."
pip install --force-reinstall ruamel.yaml==0.18.10 Pillow==11.2.1 GPUtil==1.4.0

# ------------------------------------------------------------
# 8️⃣ Verify installed packages
# ------------------------------------------------------------
echo "✅ Checking installed packages..."
pip list | grep -E "pyserial|PyYAML|psutil|pystray|babel|ruamel|sv-ttk|tkinter-tooltip|uptime|requests|ping3|pyinstaller|Pillow|GPUtil"

# ------------------------------------------------------------
# 9️⃣ Final message
# ------------------------------------------------------------
echo "🎉 Environment successfully configured!"

# ------------------------------------------------------------
# 🔟 Activate virtual environment automatically
# ------------------------------------------------------------
echo "🐍 Activating virtual environment..."
source venv/bin/activate
echo "✅ Virtual environment activated! You are now inside venv."
echo "👉 To manually activate later, use: source venv/bin/activate"

# ------------------------------------------------------------
# 11️⃣ Run configure.py automatically
# ------------------------------------------------------------
if [ -f "configure.py" ]; then
    echo "⚡ Running configure.py..."
    python3 configure.py
    echo "✅ configure.py executed successfully!"
else
    echo "❌ configure.py not found in current directory!"
fi
