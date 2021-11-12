# preview & set wallpaper(for i3wm & swaywm)
# 
# for i3, use feh
# for sway, use swaybg

I3WM_CONFIG_PATH=$HOME/.config/i3/config
SWAY_CONFIG_PATH=$HOME/.config/sway/config

feh-switch-bg() { 
    feh --bg-fill --bg-center $1 
}
way-switch-bg() { # kill all swaybg instances and substitude with a new one
    ps -ef |grep 'swaybg -m fill -i' |grep -v 'grep' |awk '{print $2}'|xargs kill -9
    swaymsg exec "swaybg -m fill -i ${1}"
}
WM_CONFIG_PATH=''

function set-wallpaper {
  # get desktop env
  case $XDG_SESSION_DESKTOP in
  "i3")
    WM_CONFIG_PATH=$I3WM_CONFIG_PATH
    WP_PREVIEW_CMD=feh-switch-bg
  ;;
  "sway")
    WM_CONFIG_PATH=$SWAY_CONFIG_PATH
    WP_PREVIEW_CMD=way-switch-bg
  ;;
  *)
    echo "unknow desktop environment"
    return
  ;;
  esac
  # get arguments
  case $1 in
  "-h")
    echo "WM_CONFIG_PATH=$WM_CONFIG_PATH"
    echo "[NUM] use a wallpaper in \$FEH_WALLPAPER_PATH"
    echo "-p [PATH] preview wallpaper"
    echo "-s [PATH] substitute wallpaper settings in configuration file"
    ;;
  "-p")
    $WP_PREVIEW_CMD $(realpath $2)
    ;;
  "-s")
    awk '{ sub(/set \$wallpaper .*$/, "set \$wallpaper \"'$(realpath $2)'\""); print >"tmp-out" }' $WM_CONFIG_PATH 2>/dev/null && mv tmp-out $WM_CONFIG_PATH
    return
    ;;
  esac
}
