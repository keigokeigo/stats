#!/bin/bash

DATE=$(date +'%Y%m%d')
LOGDIR=$(dirname $0)/logs
mkdir -p $LOGDIR > /dev/null 2>&1

STATS_LOG_FILE=$LOGDIR/stat-${DATE}.txt
DETAIL_LOG_FILE=$LOGDIR/detail-${DATE}.txt

# see "/usr/include/netinet/tcp.h"
STATUS="ESTABLISHED SYN_SENT SYN_RECV FIN_WAIT1 FIN_WAIT2 TIME_WAIT CLOSE CLOSE_WAIT LAST_ACK LISTEN CLOSING"


# output header
if [ ! -s $STATS_LOG_FILE ]; then
  echo -n "datetime" >> $STATS_LOG_FILE
  for STAT in $STATUS
  do
    echo -ne "\t$STAT" >> $STATS_LOG_FILE
  done
  echo -ne "\n" >> $STATS_LOG_FILE
fi

# every 10sec (using 'sleep 10')
for i in $(seq 1 6)
do
  DATETIME=$(date +'%Y-%m-%d %H:%M:%S.%N')
  RESULT="$(netstat -an)"

  echo -n $DATETIME >> $STATS_LOG_FILE
  for STAT in $STATUS
  do
    COUNT=$(echo "$RESULT" | grep -c -P "\b$STAT\b")
    echo -ne "\t$COUNT" >> $STATS_LOG_FILE
  done
  echo -ne "\n" >> $STATS_LOG_FILE

  cat <<_DETAIL_ >> $DETAIL_LOG_FILE
**
**	$DATETIME
**
$RESULT

_DETAIL_

  sleep 10
done

# clean up old log files
find $LOGDIR -type f -mtime +7 -daystart | xargs -r rm -f
find $LOGDIR -type f -not -name "*-$DATE.txt" -not -name "*.gz" -exec gzip -9 '{}' ';'
