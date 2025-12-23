#!/system/bin/sh
# Environment variable settings
export PATH="/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH"

module_dir="/data/adb/modules/AStreamProxy"
scripts_dir="/data/adb/StreamProxy/scripts"

restart_proxy_service() {
  if [ ! -f "${module_dir}/disable" ]; then
    echo "🔁Restart StreamProxy"
    ${scripts_dir}/StreamProxy.service enable >/dev/null 2>&1
  else
    echo "🥴 Module Disabled"
    sleep 1
    exit
  fi
}

restart_proxy_service

# Last edited: 2025.12.23
