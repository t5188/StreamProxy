#!/system/bin/sh
# Environment variable settings
export PATH="/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH"

module_dir="/data/adb/modules/AXlink"
scripts_dir="/data/adb/xlink/scripts"

restart_proxy_service() {
  if [ ! -f "${module_dir}/disable" ]; then
    echo "🔁Restart Proxy"
    ${scripts_dir}/xlink.service enable >/dev/null 2>&1
  else
    echo "🥴 Module Disabled"
    sleep 1
    exit
  fi
}

restart_proxy_service

# action.sh xlink Last edited: 2025.12.20
