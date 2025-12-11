#!/bin/bash
#
# VCenter One-line Install Script
# Usage: curl -sSL https://vcenter.zsoft.cc/install.sh | sudo bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GITHUB_REPO="zsai001/vcenter"
INSTALL_DIR="/opt/vcenter"
SERVICE_NAME="vcenter"

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo '██╗   ██╗ ██████╗███████╗███╗   ██╗████████╗███████╗██████╗ '
    echo '██║   ██║██╔════╝██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗'
    echo '██║   ██║██║     █████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝'
    echo '╚██╗ ██╔╝██║     ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗'
    echo ' ╚████╔╝ ╚██████╗███████╗██║ ╚████║   ██║   ███████╗██║  ██║'
    echo '  ╚═══╝   ╚═════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝'
    echo -e "${NC}"
    echo "Enterprise Cluster Management Platform - Installer"
    echo ""
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Please run as root (use sudo)${NC}"
        exit 1
    fi
}

# Detect architecture
detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH_NAME="amd64"
            ;;
        aarch64|arm64)
            ARCH_NAME="arm64"
            ;;
        *)
            echo -e "${RED}Error: Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}Detected architecture: ${ARCH} (${ARCH_NAME})${NC}"
}

# Get latest version
get_latest_version() {
    echo -e "${YELLOW}Fetching latest version...${NC}"
    LATEST_VERSION=$(curl -sSL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo -e "${RED}Error: Failed to get latest version${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Latest version: ${LATEST_VERSION}${NC}"
}

# Download and extract
download_and_extract() {
    DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${LATEST_VERSION}/vcenter-${LATEST_VERSION}-linux.tar.gz"
    TEMP_DIR=$(mktemp -d)
    
    echo -e "${YELLOW}Downloading ${DOWNLOAD_URL}...${NC}"
    curl -sSL -o "${TEMP_DIR}/vcenter.tar.gz" "$DOWNLOAD_URL"
    
    echo -e "${YELLOW}Extracting...${NC}"
    tar -xzf "${TEMP_DIR}/vcenter.tar.gz" -C "${TEMP_DIR}"
    
    # Find extracted directory
    EXTRACTED_DIR=$(find "${TEMP_DIR}" -maxdepth 1 -type d -name "vcenter-*" | head -1)
    
    if [ -z "$EXTRACTED_DIR" ]; then
        echo -e "${RED}Error: Failed to find extracted directory${NC}"
        exit 1
    fi
    
    echo "$EXTRACTED_DIR"
}

# Install VCenter
install_vcenter() {
    local EXTRACTED_DIR="$1"
    
    echo -e "${YELLOW}Installing to ${INSTALL_DIR}...${NC}"
    
    # Stop existing service
    systemctl stop ${SERVICE_NAME} 2>/dev/null || true
    
    # Backup existing config
    if [ -f "${INSTALL_DIR}/config.yaml" ]; then
        echo -e "${YELLOW}Backing up existing config...${NC}"
        cp "${INSTALL_DIR}/config.yaml" "${INSTALL_DIR}/config.yaml.bak"
    fi
    
    # Create install directory
    mkdir -p "${INSTALL_DIR}"
    
    # Copy files
    cp -r "${EXTRACTED_DIR}"/* "${INSTALL_DIR}/"
    
    # Restore config if backup exists
    if [ -f "${INSTALL_DIR}/config.yaml.bak" ]; then
        mv "${INSTALL_DIR}/config.yaml.bak" "${INSTALL_DIR}/config.yaml"
    elif [ -f "${INSTALL_DIR}/config.yaml.example" ]; then
        cp "${INSTALL_DIR}/config.yaml.example" "${INSTALL_DIR}/config.yaml"
    fi
    
    # Set permissions
    chmod +x "${INSTALL_DIR}/bin/"* "${INSTALL_DIR}/start.sh" 2>/dev/null || true
    
    # Install systemd service
    if [ -f "${INSTALL_DIR}/vcenter.service" ]; then
        cp "${INSTALL_DIR}/vcenter.service" /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable ${SERVICE_NAME}
    fi
    
    echo -e "${GREEN}Installation complete!${NC}"
}

# Cleanup
cleanup() {
    local TEMP_DIR="$1"
    rm -rf "$TEMP_DIR"
}

# Print success message
print_success() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          VCenter installed successfully!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Installation directory:${NC} ${INSTALL_DIR}"
    echo -e "${BLUE}Version:${NC} ${LATEST_VERSION}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Edit configuration:"
    echo "     nano ${INSTALL_DIR}/config.yaml"
    echo ""
    echo "  2. Start the service:"
    echo "     systemctl start ${SERVICE_NAME}"
    echo ""
    echo "  3. Check status:"
    echo "     systemctl status ${SERVICE_NAME}"
    echo ""
    echo "  4. View logs:"
    echo "     journalctl -u ${SERVICE_NAME} -f"
    echo ""
    echo -e "${BLUE}Documentation:${NC} https://vcenter.zsoft.cc"
    echo ""
}

# Main
main() {
    print_banner
    check_root
    detect_arch
    get_latest_version
    
    TEMP_DIR=$(mktemp -d)
    trap "cleanup '$TEMP_DIR'" EXIT
    
    EXTRACTED_DIR=$(download_and_extract)
    install_vcenter "$EXTRACTED_DIR"
    
    print_success
}

main "$@"
