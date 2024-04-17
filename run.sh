#!/bin/sh

echo "
  __  __                            _   _        _                          _
 |  \/  |  ___  ___   ___   _ __   | \ | |  ___ | |_ __      __ ___   _ __ | | __
 | |\/| | / _ \/ __| / _ \ | '_ \  |  \| | / _ \| __|\ \ /\ / // _ \ | '__|| |/ /
 | |  | ||  __/\__ \| (_) || | | | | |\  ||  __/| |_  \ V  V /| (_) || |   |   <
 |_|  |_| \___||___/ \___/ |_| |_| |_| \_| \___| \__|  \_/\_/  \___/ |_|   |_|\_\.
"

APP_NAME="meson_cdn"

if [ -d ./$APP_NAME* ]; then
    cd ./$APP_NAME* || exit 1

    sudo ./service start $APP_NAME
    sudo ./service status meson_cdn
else
    CPU_ARCH=$(uname -m)
    LINK="https://staticassets.meson.network/public/meson_cdn/v3.1.20"

    case "$CPU_ARCH" in
        x86_64)
            FILENAME="$APP_NAME-linux-amd64.tar.gz"
            ;;
        arm64|aarch64)
            FILENAME="$APP_NAME-linux-arm64.tar.gz"
            ;;
        *)
            echo "Your CPU type is not supported."
            exit 1
            ;;
    esac

    echo "CPU Arch: $CPU_ARCH"
    echo "Download link: $LINK/$FILENAME"
    echo
    echo "Downloading binary..."

    curl -o $FILENAME $LINK/$FILENAME
    tar -zxf $FILENAME
    rm -f $FILENAME
    cd ./$APP_NAME* || exit 1

    sudo ./service install $APP_NAME

    # Set default values if variables are not provided
    : ${CACHE_SIZE:=20}   # Default cache size 20G
    : ${PORT:=443}        # Default port is 443
    echo "Current Cache Size:  $CACHE_SIZE"
    echo "Current Port:        $CACHE_SIZE"

    sudo ./$APP_NAME config set --token=$TOKEN --https_port=$PORT --cache.size=$CACHE_SIZE
    sudo ./service start $APP_NAME
    sudo ./service status meson_cdn
fi
