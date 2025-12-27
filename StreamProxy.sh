#!/system/bin/sh
scripts_dir="/data/adb/StreamProxy/scripts"
mode=$(stat -c %a "${scripts_dir}/start.sh" 2>/dev/null)

(
  until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 3; done

  if [ "${mode}" != "755" ]; then
    chmod 755 "${scripts_dir}/start.sh"
    chown root:net_admin "${scripts_dir}/start.sh"
  fi

  "${scripts_dir}/start.sh"
) &
exit 0
