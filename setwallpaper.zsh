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
MY_BGLIST_PATH=$HOME/.cache/zsh/wallpapers

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
  ;;
  esac
   # proceed arguments
  case $1 in
  "-a")
    if [ -f $2 ]; then
      echo $(realpath $2) | tee -a $MY_BGLIST_PATH
      shift 2
    else
      echo "${2} is not a file"
      return
    fi
    ;;
  "-ad")
    if [ -d $2 ]; then
      find $(realpath $2) -maxdepth 1 -type f -regex ".*\.png\|.*\.jpg" | tee -a $MY_BGLIST_PATH
    shift 2
    else
      echo "${2} is not a directory name"
      return
    fi
    ;;
  "-aR")
    if [ -d $2 ]; then
      find $(realpath $2) -type f -regex ".*\.png\|.*\.jpg" | tee -a $MY_BGLIST_PATH
      shift 2
    else
      echo "${2} is not a directory name"
      return
    fi
    ;;
  "-c")
    if [ -r $2 ]; then
      MY_BGLIST_PATH=$(realpath "$2")
      shift 1
    else
      echo "${2} is not accessible"
      return
    fi
    ;;
  "-clr")
    :>$MY_BGLIST_PATH
    shift 1
    ;;
  "-d")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $MY_BGLIST_PATH|awk '{print $1}') ]
    then
      sed -i ${2}'d' $MY_BGLIST_PATH
      shift 2
    else
      echo "-d needs a valid line number"
      return
    fi
    ;;
  "-dr")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $MY_BGLIST_PATH|awk '{print $1}') ]&&[ $3 -gt 0 ]&&[ $3 -le $(wc -l $MY_BGLIST_PATH|awk '{print $1}') ]&&[ $2 -le $3 ]
    then
      sed -i ${2}','${3}'d' $MY_BGLIST_PATH
      shift 3
    else
      echo "-dr needs two valid line numbers"
      return
    fi
    ;;
  "-h")
    echo "MY_BGLIST_PATH=${MY_BGLIST_PATH}"
    echo "WM_CONFIG_PATH=${WM_CONFIG_PATH}"
    echo "\t-a  [PATH]  add a wallpaper into \$MY_BGLIST_PATH"
    echo "\t-ad [PATH]  add all jpg/png in a directory into \$MY_BGLIST_PATH"
    echo "\t-aR [PATH]  add all jpg/png in a directory into \$MY_BGLIST_PATH  recursively"
    echo "\t-c  [PATH]  change \$MY_BGLIST_PATH temporarily"
    echo "\t-clr        clear content in \$MY_BGLIST_PATH"
    echo "\t-d  [ID]    delete a wallpaper from \$MY_BGLIST_PATH by line number"
    echo "\t-dr [FROM] [TO] delete a range in \$MY)BGLIST_PATH by line number"
    echo "\t-h          show this help"
    echo "\t-l          list wallpapers saved in \$MY_BGLIST_PATH"
    echo "\t-m          merge duplicated items in \$MY_BGLIST_PATH"
    echo "\t-p  [PATH]  preview with swaybg"
    echo "\t-pn [ID]    preview a wallpaper from \$MY_BGLIST_PATH by line number"
    echo "\t-r          randomly pick a wallpaper from \$MY_BGLIST_PATH"
    echo "\t-s  [PATH]  set \$wallpaper to [PATH] configuration file"
    echo "\t-sn [ID]    set \$wallpaper with a path in \$MY_BGLIST_PATH by line number"
    echo "\t-sl [PATH]  set swaylock background to [PATH]"
    echo "\t-sln [ID]   set swaylock background with a path in \$MY_BGLIST_PATH by line number"
    echo "  HINT: support multiple parameters, e. g. set-wallpaper -aR [PATH] -sn [ID] -m"
    shift 1
    ;;
  "-l")
    cat -n $MY_BGLIST_PATH
    shift 1
    ;;
  "-m")
    sort $MY_BGLIST_PATH |uniq |tee $MY_BGLIST_PATH
    shift 1
    ;;
  "-p")
    if [ -f $2 ]; then
      $WP_PREVIEW_CMD $(realpath "$2")
      shift 2
    else
      echo "${2} is not a file"
      return
    fi
    ;;
  "-pn")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $MY_BGLIST_PATH|awk '{print $1}') ]
    then
      $WP_PREVIEW_CMD $(sed -n ${2}'p' $MY_BGLIST_PATH)
      shift 2
    else
      echo "-pn needs a valid line number"
      return
    fi
    ;;
  "-r")
    $WP_PREVIEW_CMD $(sed -n $(wc -l $MY_BGLIST_PATH|awk 'BEGIN{srand()} {print int($1 *rand())+1}')'p' $MY_BGLIST_PATH)
    shift 1
    ;;
  "-s")
    if [ -f $2 ]; then
      awk '{ sub(/set \$wallpaper .*$/, "set \$wallpaper \"'$(realpath $2)'\""); print >"tmp-out" }' $WM_CONFIG_PATH 2>/dev/null && mv tmp-out $WM_CONFIG_PATH
      shift 2
    else
      echo "${2} is not a file"
      return
    fi
    ;;
  "-sn")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $MY_BGLIST_PATH|awk '{print $1}') ]
    then
      awk '{ sub(/set \$wallpaper .*$/, "set \$wallpaper \"'$(sed -n $2'p' $MY_BGLIST_PATH)'\""); print >"tmp-out" }' $WM_CONFIG_PATH 2>/dev/null && mv tmp-out $WM_CONFIG_PATH
    else
      echo "-sn needs a valid line number"
      return
    fi
    ;;
  "-sl")
    if [ -f $2 ]; then
      awk '{ sub(/set \$Locker .*$/, "set \$Locker swaylock -i \"'$(realpath $2)'\" -s fill"); print >"tmp-out" }' $WM_CONFIG_PATH 2>/dev/null && mv tmp-out $WM_CONFIG_PATH
      shift 2
    else
      echo "${2} is not a file"
      return
    fi
    ;;
  "-sln")
    if [ $2 -gt 0 ]&&[ $2 -le $(wc -l $MY_BGLIST_PATH|awk '{print $1}') ]
    then
      awk '{ sub(/set \$Locker .*$/, "set \$Locker swaylock -i \"'$(sed -n $2'p' $MY_BGLIST_PATH)'\" -s fill"); print >"tmp-out" }' $WM_CONFIG_PATH 2>/dev/null && mv tmp-out $WM_CONFIG_PATH
      shift 2
    else
      echo "-sln needs a valid line number"
      return
    fi
    ;;
  *)
    echo "${1}: invalid parameter. -h for help"
    return
    ;;
  esac
  # get parameters recursively
  if [ $# -gt 0 ]; then
    set-wallpaper $@
  fi
}
