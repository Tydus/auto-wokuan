#!/bin/sh

IF=pppoe*
THRESHOLD_BOOST=2048
THRESHOLD_RESTORE=1024
COUNT_BOOST=3
COUNT_RESTORE=10
RESERVE_HOURS=5

base="http://bj.wokuan.cn/web"

CURL="wget -q -O -"

LOG=echo


get_status(){
    for i in `$CURL $base/getspeed.php \
        | cut -c2- | sed 's@&@\n@g' \
        | grep -E "^(glst|os|up|gus|old|stu|cn)="`; do eval $i; done # DON'T use while and pipe

    if [ "x$cn" == "x" ]; then
        $LOG "Error: no login"
        exit 1
    fi

    if echo $glst $RESERVE_HOURS | awk '$1>$2{exit 1}'; then
        $LOG "Not enough hours"
        restore
        exit 1
    fi
}

print_status(){
    get_status
    $LOG "Username: $cn"
    $LOG "Standard Speed: ${os}Mbps"
    $LOG "Boost Speed: ${up}Mbps"
    $LOG "Boosted: $stu"
    $LOG "Time Left: ${glst}h"
}

boost(){
    ret=`$CURL "$base/improvespeed.php?ContractNo=$cn&up=$gus&old=$old" | cut -d"&" -f2`

    if [ $ret == "00000000" ]; then
        $LOG "Bandwidth Boosted"
    else
        $LOG "Bandwidth Boost failed: $ret"
    fi

}

restore(){
    ret=`$CURL "$base/lowerspeed.php?ContractNo=$cn" | cut -d"&" -f2`
    if [ $ret == "00000000" ]; then
        $LOG "Restored Bandwidth"
    else
        $LOG "Bandwidth Restore failed: $ret"
    fi
}

print_status

bmon -p "$IF" -r 2 -o 'format:stderr;fmt=$(attr:rxrate:bytes)\n' 2>&1 | awk "
    NR==1{
        break
    }
    \$1>$THRESHOLD_BOOST*1024{
        cr=0
        cb++
    }
    \$1<$THRESHOLD_RESTORE*1024{
        cb=0
        cr++
    }
    {
        if(cb==$COUNT_BOOST)
            print 1
        if(cr==$COUNT_RESTORE)
            print 0
    }
" | while read a; do
    if [ $a -eq 1 ]; then
        boost
        get_status
    else
        restore
        get_status
    fi
done

