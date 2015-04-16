function uptime_info() {
  let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
  let secs=$((${upSeconds}%60))
  let mins=$((${upSeconds}/60%60))
  let hours=$((${upSeconds}/3600%24))
  let days=$((${upSeconds}/86400))
  UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`
  echo "${UPTIME}"
}

#get the load averages
function get_load_avg() {
  read one five fifteen rest < /proc/loadavg
  echo "${one}, ${five}, ${fifteen} (1, 5, 15 min)"
}

echo "
$fg[green]   .~~.   .~~.    $fg[yellow]$(date)
$fg[green]  '. \ ' ' / .'   `uname -srmo`$fg[red]
   .~ .~~~..~.    
   .~ .~~~..~.    $fg[cyan]Uptime.............: $fg[yellow]$(uptime_info)$fg[red]
 ~ (   ) (   ) ~  $fg[cyan]Memory.............: $fg[green]`cat /proc/meminfo | grep MemFree | awk {'print $2'}`kB (Free) / `cat /proc/meminfo | grep MemTotal | awk {'print $2'}`kB (Total)$fg[red]
( : '~'.~.'~' : ) $fg[cyan]Load Averages......: $fg[green]$(get_load_avg)$fg[red]
 ~ .~ (   ) ~. ~  $fg[cyan]Running Processes..: $fg[green]`ps ax | wc -l | tr -d " "`$fg[red]
  (  : '~' :  )   $fg[cyan]CPU Temperature....: $fg[yellow]`/opt/vc/bin/vcgencmd measure_temp | cut -c 6-9 | awk '{ print $1 "°C" }'`$fg[red]
   '~ .~~~. ~'    $fg[cyan]Free Disk Space....: $fg[magenta]`df -Ph | grep -E '^/dev/root' | awk '{ print $4 " of " $2 }'`$fg[red]
       '~'        $fg[cyan]IP Addresses.......: $fg[yellow]`/sbin/ifconfig eth0 | /bin/grep "inet addr" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1`$reset_color and $fg[green]`wget -q -O - http://icanhazip.com/ | tail`
"
