#!/bin/sh 

sleep 10
login=$(cat /etc/httpd.conf | grep cgi-bin | cut -d':' -f2)
pass=$(cat /etc/httpd.conf | grep cgi-bin | cut -d':' -f3)
chtime=20 #время повтора скрипта всекундах
chexp=16000 #ночной режим экспозиции
chexpday=1800 #дневной режим экспозиции
chexppm=3100 #вечерний-утренний режим экспозиции
day=1
am=4 #утро после 4 часов
pm=20 #вечер после 20 часов

while true; do

exp=$(curl -s http://localhost/metrics | grep ^isp_again | cut -d' ' -f2)
bri=expr $exp / 1
HOUR=$(date +%H)

#дневной режим
if [ $HOUR -gt $am -a $HOUR -le $pm ] ; then
  
    if [ $bri -gt $chexp -a $day -eq 1 ] ;then
  day=0
  curl -u $login:$pass http://localhost/night/on
        logger "Night mode on! Exp = $bri"
    fi

    if [ $bri -le $chexpday -a $day -eq 0 ] ;then
  day=1
  curl -u $login:$pass http://localhost/night/off
        logger "Night mode off! Exp = $bri "
 
    fi

fi

#вечерний режим до 12 ночи
if [ $HOUR -gt $pm -a $HOUR -le 24 ] ; then
  
    if [ $bri -gt $chexp -a $day -eq 1 ] ;then
  day=0
  curl -u $login:$pass http://localhost/night/on
        logger "Night mode on! Exp = $bri"
    fi

    if [ $bri -le $chexppm -a $day -eq 0 ] ;then
  day=1
  curl -u $login:$pass http://localhost/night/off
        logger "Night mode off! Exp = $bri "
    fi
  
fi 
  
#вечерний режим до 4 утра
if [ $HOUR -ge 0 -a $HOUR -le $am ] ; then

    if [ $bri -gt $chexp -a $day -eq 1 ] ;then
  day=0
  curl -u $login:$pass http://localhost/night/on
  logger "Night mode on! Exp = $bri"
    fi

    if [ $bri -le $chexppm -a $day -eq 0 ] ;then
  day=1
  curl -u $login:$pass http://localhost/night/off
        logger "Night mode off! Exp = $bri "
 
    fi

fi 

sleep $chtime

done
