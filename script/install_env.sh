#!/bin/bash
# ============================================================
# 🧠 Python Environment Setup Script (Multi-Distro, Full)
# Author: Bruno (Refined by Gemini)
# ============================================================

set -e # stop on any error

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
        UPDATE_CMD="sudo apt update || true" # Simplified update command
        INSTALL_CMD="sudo apt install -y"
        ;;
    fedora|rhel|centos|rocky|alma)
        PKG_MANAGER="dnf"
        PY_DEV="python3-devel"
        DRM_DEV="libdrm-devel"
        UPDATE_CMD="sudo dnf check-update || true"
        INSTALL_CMD="sudo dnf install -y"
        ;;
    *)
        echo "⚠️ Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "✅ Detected distribution: $DISTRO"

# ------------------------------------------------------------
# 2️⃣ Update system package list
# ------------------------------------------------------------
echo "🔄 Updating system package list..."
eval "$UPDATE_CMD"

# ------------------------------------------------------------
# 3️⃣ Install dependencies
# ------------------------------------------------------------
echo "📦 Installing system dependencies..."
if [ "$PKG_MANAGER" = "apt" ]; then
    $INSTALL_CMD python3 python3-pip python3-venv python3-tk $PY_DEV build-essential $DRM_DEV \
        libjpeg-dev libpng-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev \
        tcl-dev tk-dev libffi-dev libssl-dev
else
    $INSTALL_CMD python3 python3-pip python3-venv python3-tk $PY_DEV $DRM_DEV \
        libjpeg-turbo-devel libpng-devel libtiff-devel zlib-devel freetype-devel lcms2-devel libwebp-devel \
        tcl-devel tk-devel libffi-devel openssl-devel
fi

# ------------------------------------------------------------
# 4️⃣ Create and activate virtual environment
# ------------------------------------------------------------
echo "🐍 Creating virtual environment in ./venv..."
python3 -m venv venv

echo "🔌 Activating virtual environment for the duration of this script..."
# A linha abaixo ativa o venv para que os comandos 'pip' a seguir
# instalem os pacotes dentro do ambiente isolado.
source venv/bin/activate

# ------------------------------------------------------------
# 5️⃣ Create requirements.txt
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
echo "⚙️ Upgrading pip and installing Python packages..."
pip install --upgrade pip
pip install --force-reinstall -r requirements.txt

# ------------------------------------------------------------
# 7️⃣ Verify installed packages
# ------------------------------------------------------------
echo "✅ Verifying installed packages..."
pip list | grep -E "pyserial|PyYAML|psutil|pystray|babel|ruamel|sv-ttk|tkinter-tooltip|uptime|requests|ping3|pyinstaller|Pillow|GPUtil"

# ------------------------------------------------------------
# 8️⃣ Run configure.py automatically
# ------------------------------------------------------------
if [ -f "configure.py" ]; then
    echo "⚡ Running configure.py..."
    python3 configure.py
    echo "✅ configure.py executed successfully!"
else
    echo "⚠️ configure.py not found, skipping."
fi

# ------------------------------------------------------------
# 9️⃣ Final message
# ------------------------------------------------------------
echo ""
echo "🎉 Environment successfully configured!"
echo "✅ All packages were installed inside the './venv' directory."
echo ""
echo "👉 IMPORTANTE: Para trabalhar no seu projeto, você DEVE ativar o ambiente manualmente em seu terminal com o comando:"
echo "   source venv/bin/activate"
echo ""
