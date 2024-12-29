#!/bin/bash

# 檢測Linux發行版
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VERSION_ID=$VERSION_ID
    else
        echo "無法檢測操作系統版本"
        exit 1
    fi
}

# 檢查並安裝 sudo
check_sudo() {
    # 檢查是否有 sudo 命令
    if ! command -v sudo &> /dev/null; then
        echo "系統未安裝 sudo"
        # 檢查是否為 root 用戶
        if [ "$(id -u)" = "0" ]; then
            echo "正在安裝 sudo..."
            case "$OS" in
                *Ubuntu*|*Debian*)
                    apt update
                    apt install sudo -y
                    ;;
                *CentOS*|*Red*Hat*)
                    yum install sudo -y
                    ;;
                *Alpine*)
                    apk add sudo
                    ;;
            esac
            echo "sudo 安裝完成"
        else
            echo "錯誤：需要 root 權限來安裝 sudo"
            exit 1
        fi
    fi
}

# 建立必要目錄
create_directories() {
    sudo mkdir -p /home/web/
    sudo mkdir -p /home/web/cert
}

# 生成自簽證書
generate_ssl_cert() {
    sudo openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
        -keyout /home/web/cert/default_server.key \
        -out /home/web/cert/default_server.crt \
        -days 5475 \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Common Name"
}

# 下載nginx配置文件
download_config() {
    sudo wget -O default https://raw.githubusercontent.com/gebu8f/SH/refs/heads/main/default_system
    sudo mv default /etc/nginx/sites-available/default 2>/dev/null || sudo mv default /etc/nginx/conf.d/default.conf
}

# Ubuntu/Debian 安裝
debian_install() {
    sudo apt update
    sudo apt install nginx wget openssl -y
    create_directories
    generate_ssl_cert
    sudo rm /etc/nginx/sites-available/default
    download_config
    sudo systemctl restart nginx
}

# CentOS 安裝
centos_install() {
    sudo yum install epel-release -y
    sudo yum install nginx wget openssl -y
    create_directories
    generate_ssl_cert
    download_config
    sudo systemctl restart nginx
}

# Alpine 安裝
alpine_install() {
    sudo apk update
    sudo apk add nginx wget openssl
    create_directories
    generate_ssl_cert
    sudo mkdir -p /etc/nginx/conf.d
    download_config
    sudo rc-service nginx restart
}

# 主程序
main() {
    detect_os
    echo "檢測到的操作系統: $OS"
    
    # 檢查並安裝 sudo
    check_sudo
    
    case "$OS" in
        *Ubuntu*|*Debian*)
            echo "執行 Ubuntu/Debian 安裝流程..."
            debian_install
            ;;
        *CentOS*|*Red*Hat*)
            echo "執行 CentOS 安裝流程..."
            centos_install
            ;;
        *Alpine*)
            echo "執行 Alpine 安裝流程..."
            alpine_install
            ;;
        *)
            echo "不支援的操作系統: $OS"
            exit 1
            ;;
    esac

    echo "Nginx 安裝完成！"
}

main
