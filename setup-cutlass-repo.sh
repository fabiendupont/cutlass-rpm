#!/bin/bash

# CUTLASS RPM Repository Setup Script
# Automatically configures the appropriate repository for your system

set -e

echo "🚀 Setting up CUTLASS RPM Repository"

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=${VERSION_ID}
else
    echo "❌ Cannot detect OS version"
    exit 1
fi

# Determine repository configuration
case "$OS" in
    "centos"|"rocky"|"almalinux")
        if [[ "$VERSION_ID" =~ ^9 ]]; then
            REPO_NAME="cutlass-centos-stream-9"
            REPO_URL="https://fabiendupont.github.io/cutlass-rpm/repo/centos-stream-9"
            echo "✅ Detected CentOS Stream 9 compatible system"
        else
            echo "❌ Unsupported CentOS/Rocky/AlmaLinux version: $VERSION_ID"
            echo "ℹ️  Only version 9.x is supported"
            exit 1
        fi
        ;;
    "rhel")
        if [[ "$VERSION_ID" =~ ^9 ]]; then
            REPO_NAME="cutlass-rhel-ubi-9"
            REPO_URL="https://fabiendupont.github.io/cutlass-rpm/repo/rhel-ubi-9"
            echo "✅ Detected RHEL 9 system"
        else
            echo "❌ Unsupported RHEL version: $VERSION_ID"
            echo "ℹ️  Only version 9.x is supported"
            exit 1
        fi
        ;;
    *)
        echo "❌ Unsupported operating system: $OS"
        echo "ℹ️  Supported: CentOS Stream 9, RHEL 9, Rocky Linux 9, AlmaLinux 9"
        exit 1
        ;;
esac

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Create repository configuration
echo "📝 Creating repository configuration..."
cat > /etc/yum.repos.d/cutlass.repo << EOF
[$REPO_NAME]
name=CUTLASS for $(echo $OS | tr '[:lower:]' '[:upper:]') $VERSION_ID
baseurl=$REPO_URL
enabled=1
gpgcheck=0
priority=1
EOF

echo "✅ Repository configuration created: /etc/yum.repos.d/cutlass.repo"

# Update package cache
echo "🔄 Updating package cache..."
if command -v dnf >/dev/null 2>&1; then
    dnf makecache
elif command -v yum >/dev/null 2>&1; then
    yum makecache
else
    echo "❌ Neither dnf nor yum found"
    exit 1
fi

echo "✅ Package cache updated"

# Show available packages
echo ""
echo "📦 Available CUTLASS packages:"
if command -v dnf >/dev/null 2>&1; then
    dnf list available 'cutlass*' | grep -v "Available Packages" || echo "No packages found (repository may need time to sync)"
elif command -v yum >/dev/null 2>&1; then
    yum list available 'cutlass*' | grep -v "Available Packages" || echo "No packages found (repository may need time to sync)"
fi

echo ""
echo "🎯 Quick install examples:"
echo ""
echo "For development (headers only):"
echo "  sudo dnf install 'cutlass-devel*modern-all*'"
echo ""
echo "For Python development:"
echo "  sudo dnf install 'cutlass-python*modern-all*'"
echo ""
echo "For profiling tools:"
echo "  sudo dnf install 'cutlass-tools*modern-all*'"
echo ""
echo "Complete development environment:"
echo "  sudo dnf install 'cutlass-devel*modern-all*' 'cutlass-python*modern-all*' 'cutlass-tools*modern-all*'"
echo ""
echo "✅ CUTLASS repository setup complete!"
echo "ℹ️  Visit https://fabiendupont.github.io/cutlass-rpm/ for detailed documentation"