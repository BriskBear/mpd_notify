# Pause / Play mpd via notifications : 

function mpd-status() {
  ipath='/usr/share/icons/Leafy/scalable/actions'
  output=`mpc`
  status=`echo "$output"|ag '\['|awk -F'\\\]| |\\\[' '{print $2}'`

  case $status in 
    'playing')
      action='pause'
      icon="${ipath}/player_play.svg"
    ;;
    'paused')
      action='play'
      icon="${ipath}/player_pause.svg"
    ;;
    *)
      action='error'
      icon="${ipath}/gtk-no.svg"
    ;;
  esac
}

function mpd-notify() {
  mpd-status

  if [[ ! $action =~ 'error' ]]
  then
    output=`mpc $action`
    status=`echo "$output"|ag '\['|awk -F'\\\]| |\\\[' '{print $2}'`
    title=`echo "$output"|head -n1|awk -F' - ' '{print $3,$4}'`
    artist=`echo "$output"|head -n1|awk -F' - ' '{print $2}'`
    body=`echo -e "$artist\n$title\n[${status}]"`
    result=`dunstify -A "$action,default" -i $icon -r 333 -h string:fgcolor:"#ffffcf" -h string:bgcolor:"#1d1f21" 'MPD: ' "$body"`
  else
    msg='mpd is in a state other than: [paused, playing]'
    dunstify -r 333 -h string:fgcolor:"#ff0000" -h string:bgcolor:"#1d1f21" 'MPD Notifier:' "$msg" 
    reply -e "$msg" 
  fi
  
  [[ $result -eq 2 ]] || mpd-notify
  unset result
}
