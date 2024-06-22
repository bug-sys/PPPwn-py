#!/bin/bash

check_interface() {
    if ! ip link show "$interface" | grep -q "state UP"; then
        sudo ifup "$interface" 2>/dev/null
    fi
}

run_pppwn() {
    while true; do
        # Mematikan dan menyalakan kembali antarmuka eth0
        sudo ip link set dev eth0 down && sudo ip link set dev eth0 up
        
        # Menjalankan pppwn
        sudo "$pppwn" --interface "$interface" --fw "$fw" --stage1 "$stage1" --stage2 "$stage2" &
        pppwn_pid=$!
        wait $pppwn_pid > /dev/null 2>&1
        pppwn_exit_status=$?
        
        if [ $pppwn_exit_status -eq 0 ]; then
            sudo shutdown -h now
        fi		
    done
}

main_menu() {
    while true; do
        check_interface
        if ip link show "$interface" | grep -q "state UP"; then
            echo -e "\033[94mPS4 TERDETEKSI !!!\033[0m"
            run_pppwn
        else
            echo -e "\033[91mTIDAK TERHUBUNG... Pastikan koneksi LAN PS4 terhubung dengan STB.\033[0m"
            sleep 1
        fi
    done
}

# Sumberkan file konfigurasi
source /root/PPPwn/config.ini

# Titik masuk dari skrip
main_menu

exit 0
