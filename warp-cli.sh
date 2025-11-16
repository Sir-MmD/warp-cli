#!/bin/bash
#MmD
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
GOLD=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0)

root_check() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as ${RED}root!${NC}"
    exit 1
  fi
}

check_host() {
    if command -v apt &> /dev/null; then
        apt_based
    elif command -v yum &> /dev/null; then
        yum_based
    else
        echo "${RED}Package manager (apt/yum) not supported${NC}"
        exit 1
    fi
}

apt_based() {
    echo "${CYAN}Running apt-based installation...${NC}"
    apt update
    apt install -y curl gpg lsb-release apt-transport-https ca-certificates sudo
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
    apt update
    apt -y install cloudflare-warp
}

yum_based() {
    echo "${CYAN}Running yum-based installation...${NC}"
    curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
    yum check-update
    yum install -y curl sudo coreutils
    yum check-update
    yum install -y cloudflare-warp
}

warp_setup() {
    if ! command -v warp-cli &> /dev/null; then
        echo "${RED}WARP-CLI command not found after installation!${NC}"
        exit 1
    fi

    echo "${CYAN}Configuring WARP... (Waiting 2s for service to start)${NC}"
    sleep 2

    if ! yes | warp-cli registration new; then
        echo "${RED}Failed to register WARP client!${NC}"
        echo "This can happen if the service isn't ready. Try running 'warp-cli registration new' manually."
        exit 1
    fi

    if ! warp-cli mode proxy; then
        echo "${RED}Failed to set WARP mode to proxy.${NC}"
        exit 1
    fi

    if ! warp-cli proxy port 10808; then
        echo "${RED}Failed to set WARP proxy port.${NC}"
        exit 1
    fi

    if ! warp-cli connect; then
        echo "${RED}Failed to connect to WARP!${NC}"
        exit 1
    fi

    echo ""
    echo "${CYAN}WARP is ready! ${GOLD}SOCKS5 port: 10808${NC}"
    echo ""
}

apt_uninstall() {
    echo "Uninstalling for apt-based system..."
    apt-get purge -y cloudflare-warp
    rm -f /etc/apt/sources.list.d/cloudflare-client.list
    rm -f /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    apt update
}

yum_uninstall() {
    echo "Uninstalling for yum-based system..."
    yum remove -y cloudflare-warp
    rm -f /etc/yum.repos.d/cloudflare-warp.repo
}

uninstall_warp() {
    echo "${RED}Uninstalling Cloudflare WARP...${NC}"
    
    
    if command -v warp-cli &> /dev/null; then
        echo "Disconnecting and unregistering..."
        warp-cli disconnect &> /dev/null
        warp-cli registration delete &> /dev/null
    fi
    
    
    if command -v systemctl &> /dev/null; then
        systemctl stop cloudflare-warp &> /dev/null
        systemctl disable cloudflare-warp &> /dev/null
    fi

    
    if command -v apt &> /dev/null; then
        apt_uninstall
    elif command -v yum &> /dev/null; then
        yum_uninstall
    else
        echo "${RED}Package manager (apt/yum) not supported. Cannot uninstall.${NC}"
        echo "Please remove 'cloudflare-warp' manually."
        exit 1
    fi

    echo "${GREEN}Cloudflare WARP uninstalled successfully.${NC}"
}

if [ "$1" == "uninstall" ] || [ "$1" == "--uninstall" ]; then
    root_check
    uninstall_warp
    exit 0
fi

if [ "$1" == "reinstall" ] || [ "$1" == "--reinstall" ]; then
    root_check
    echo "${GOLD}Reinstalling WARP...${NC}"
    uninstall_warp
    echo "${CYAN}--- Starting Installation ---${NC}"
    check_host
    warp_setup
    exit 0
fi

root_check

if command -v warp-cli &> /dev/null; then
    
    echo "${CYAN}WARP-CLI is already installed.${NC}"
    echo ""
    echo "What would you like to do?"
    echo "  (r) ${GOLD}Reinstall${NC} (uninstall, then install)"
    echo "  (u) ${RED}Uninstall${NC}"
    echo "  (q) ${GREEN}Quit${NC}"

    read -n 1 -p "Enter your choice [r/u/q]: " choice
    echo ""

    case "$choice" in
        r|R)
            echo "${GOLD}Reinstalling WARP...${NC}"
            uninstall_warp
            echo "${CYAN}--- Starting Installation ---${NC}"
            check_host
            warp_setup
            ;;
        u|U)
            uninstall_warp
            ;;
        q|Q|*)
            echo "Aborting."
            exit 0
            ;;
    esac
else
    echo "${GREEN}WARP-CLI not found. Starting installation...${NC}"
    check_host
    warp_setup
fi

exit 0
