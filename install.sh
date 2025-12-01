#!/usr/bin/env bash

set -e

echo "=== QEMU-Compose Installer ==="

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VER=$VERSION_ID
else
    echo "Cannot detect OS. Exiting."
    exit 1
fi

echo "Detected OS: $NAME $VERSION_ID"

install_packages_debian() {
    echo "Installing packages for Debian/Ubuntu..."
    sudo apt update
    sudo apt install -y qemu qemu-kvm qemu-utils python3-pip
}

install_packages_redhat() {
    echo "Installing packages for RedHat/CentOS/Fedora..."
    sudo dnf install -y qemu-kvm qemu-img qemu-system-x86 python3-pip
}

install_packages_arch() {
    echo "Installing packages for Arch/Manjaro..."
    sudo pacman -Sy --noconfirm qemu qemu-arch-extra python-pip
}

case "$OS_NAME" in
    ubuntu|debian)
        install_packages_debian
        ;;
    fedora|centos|rhel)
        install_packages_redhat
        ;;
    arch)
        install_packages_arch
        ;;
    *)
        echo "Unsupported OS: $OS_NAME. Please install QEMU and python3 manually."
        ;;
esac

# Check QEMU binaries
QEMU_BINS=(qemu-system-x86_64 qemu-system-aarch64 qemu-img)
for bin in "${QEMU_BINS[@]}"; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "Warning: $bin not found in PATH."
    else
        echo "$bin found."
    fi
done

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --user pyyaml

# Make qemu-compose executable
if [ -f "qemu-compose" ]; then
    chmod +x qemu-compose
    echo "qemu-compose is now executable."
else
    echo "qemu-compose not found in current directory."
fi
cd ..
rm -rf qemu-compose
echo "=== Installation Complete ==="
echo "You can now run: ./qemu-compose up"
