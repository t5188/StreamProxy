#!/system/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=1
unzip_path="/data/adb"

source_folder="/data/adb/StreamProxy"
destination_folder="/data/adb/StreamProxy$(date +%Y%m%d_%H%M%S)"

unzip -j -o "$ZIPFILE" 'CHANGELOG.md' -d $MODPATH >&2
cat $MODPATH/CHANGELOG.md
rm -f "$MODPATH/CHANGELOG.md"

if [ -d "$source_folder" ]; then
  # If the source folder exists, execute the move operation
  mv "$source_folder" "$destination_folder"
  ui_print "- 正在备份已有文件"
  # Delete old folders and update them
  rm -rf "$source_folder"
else
  # If the source folder does not exist, output initial installation information
  ui_print "- 正在初始安装"
fi

# Set up service directory and clean old installations
if [ -d "/data/adb/modules/AStreamProxy" ]; then
  rm -rf "/data/adb/modules/AStreamProxy"
  ui_print "- 旧模块已删除"
fi

ui_print "- 正在释放文件"
unzip -o "$ZIPFILE" 'StreamProxy/*' -d $unzip_path >&2
unzip -j -o "$ZIPFILE" 'StreamProxy.sh' -d /data/adb/service.d >&2
unzip -j -o "$ZIPFILE" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "$ZIPFILE" "action.sh" -d $MODPATH >&2
unzip -j -o "$ZIPFILE" "module.prop" -d $MODPATH >&2
unzip -j -o "$ZIPFILE" "system.prop" -d $MODPATH >&2

# Customize module name based on environment
if [ "$KSU" = "true" ]; then
  sed -i "s/name=.*/name=StreamProxy for KernelSU/g" $MODPATH/module.prop
elif [ "$APATCH" = "true" ]; then
  sed -i "s/name=.*/name=StreamProxy for APatch/g" $MODPATH/module.prop
else
  sed -i "s/name=.*/name=StreamProxy for Magisk/g" $MODPATH/module.prop
fi

largest_folder=$(find /data/adb -maxdepth 1 -type d -name 'StreamProxy[0-9]*' | sed 's/.*StreamProxy//' | sed 's/_//g' | sort -nr | head -n 1)

if [ -n "$largest_folder" ]; then
  for folder in /data/adb/StreamProxy*; do
    clean_name=$(echo "$folder" | sed 's/.*StreamProxy//' | sed 's/_//g')
    if [ "$clean_name" = "$largest_folder" ]; then
      ui_print "- Found folder: $folder"
      if [ -d "$folder/confx" ]; then
        cp -rf "$folder/confx/"* /data/adb/StreamProxy/confx/
        ui_print "- Copied contents of $folder/confx to /data/adb/StreamProxy/confx/"
        ui_print "- 成功还原配置文件"
      fi
      break
    fi
  done
else
  ui_print "- 首次安装，无备份配置可还原"
fi

download_and_extract() {
  URL="https://core.acstudycn.eu.org/xray/download/android"

  # 保险做法，生成 zip 临时文件
  TMP="$(mktemp xrayXXXXXX 2>/dev/null || echo /tmp/xray$$)"
  mv "$TMP" "${TMP}.zip"
  TMP="${TMP}.zip"

  DEST="$source_folder/binary"

  do_download() {
    ui_print "— 开始下载并解压 Xray 内核..."
    if ! curl -L -o "$TMP" "$URL"; then
      ui_print "⚠️ curl 下载失败，尝试使用 wget..."
      if ! wget -O "$TMP" "$URL"; then
        ui_print "❌ 下载 Xray 内核失败，跳过此步骤"
        return
      fi
    fi
    mkdir -p "$DEST"
    if ! unzip -o "$TMP" -d "$DEST"; then
      ui_print "❌ 解压 Xray 内核失败，跳过此步骤"
      return
    fi
    rm -f "$TMP" "$DEST/LICENSE" "$DEST/README.md"
    ui_print "— Xray 内核下载完成 ✅"
  }

  skip_download() {
    ui_print "— 跳过下载 Xray 内核 ❌"
  }

  # 音量键选择逻辑
  ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  ui_print "— 是否下载并解压 Xray 内核？"
  ui_print "— [ Vol UP(+): 是 ]"
  ui_print "— [ Vol DOWN(-): 否 ]"

  START_TIME=$(date +%s)
  while true ; do
    NOW_TIME=$(date +%s)
    timeout 1 getevent -lc 1 2>&1 | grep KEY_VOLUME > "$TMPDIR/events"

    if [ $(( NOW_TIME - START_TIME )) -gt 9 ]; then
      ui_print "— 10 秒无操作，默认跳过下载"
      skip_download
      break
    elif grep -q KEY_VOLUMEUP "$TMPDIR/events"; then
      do_download
      break
    elif grep -q KEY_VOLUMEDOWN "$TMPDIR/events"; then
      skip_download
      break
    fi
  done

  timeout 1 getevent -cl >/dev/null
}

download_and_extract

ui_print "- 正在设置权限"
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm_recursive /data/adb/StreamProxy/ 0 3005 0755 0755
set_perm_recursive /data/adb/StreamProxy/scripts/ 0 3005 0755 0755
set_perm /data/adb/service.d/StreamProxy.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
set_perm /data/adb/StreamProxy/scripts/ 0 0 0755
set_perm $MODPATH/action.sh 0 0 0755
ui_print "- 完成权限设置"
ui_print "- 还原配置文件"

pm install -r /data/adb/StreamProxy/scripts/toast.apk && rm -f /data/adb/StreamProxy/scripts/toast.apk || ui_print "- 请手动安装toast.apk"
find "${source_folder}" -type f -name ".gitkeep" -exec rm -f {} +
ui_print "- enjoy!"
# customize.sh StreamProxy Last edited: 2025.12.15
