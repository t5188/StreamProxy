#!/system/bin/sh
scripts_dir="/data/adb/StreamProxy/scripts"
mode=$(stat -c %a "${scripts_dir}/start.sh")

(
  until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 3; done

  if [ "${mode}" != "755" ]; then
    chmod 755 "${scripts_dir}/start.sh"
    chown root:net_admin "${scripts_dir}/start.sh"
  fi

  "${scripts_dir}/start.sh"
) &

fw_clean() {
  echo "[*] delete iptables references"
  iptables -D OUTPUT -j fw_OUTPUT           2>/dev/null
  iptables -D INPUT  -j fw_INPUT            2>/dev/null
  iptables -D OUTPUT -j fw_OUTPUT_oplus_dns 2>/dev/null

  echo "[*] delete ip6tables references"
  ip6tables -D OUTPUT -j fw_OUTPUT           2>/dev/null
  ip6tables -D INPUT  -j fw_INPUT            2>/dev/null
  ip6tables -D OUTPUT -j fw_OUTPUT_oplus_dns 2>/dev/null

  echo "[*] flush custom chains"
  iptables  -F fw_INPUT            2>/dev/null
  iptables  -F fw_OUTPUT           2>/dev/null
  iptables  -F fw_OUTPUT_oplus_dns 2>/dev/null

  ip6tables -F fw_INPUT            2>/dev/null
  ip6tables -F fw_OUTPUT           2>/dev/null
  ip6tables -F fw_OUTPUT_oplus_dns 2>/dev/null

  echo "[*] delete custom chains"
  iptables  -X fw_INPUT            2>/dev/null
  iptables  -X fw_OUTPUT           2>/dev/null
  iptables  -X fw_OUTPUT_oplus_dns 2>/dev/null

  ip6tables -X fw_INPUT            2>/dev/null
  ip6tables -X fw_OUTPUT           2>/dev/null
  ip6tables -X fw_OUTPUT_oplus_dns 2>/dev/null

  echo "[✓] fw_INPUT / fw_OUTPUT / fw_OUTPUT_oplus_dns cleaned"
}

fw_clean

exit 0
# Last edited: 2026.1.9