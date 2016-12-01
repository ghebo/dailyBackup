#!/bin/bash

src1=/backup/daily
src2=/backup/mysql
trg=/backup-manual
log=/var/log/manual-bkp.log
mount=vda1
today=$(date +"%Y%m%d")

echo "$(date +"%d.%m.%Y %H:%M") -----    Start !!!   " > $log

echo "$(date +"%d.%m.%Y %H:%M") ----- Create archive $src1 and $src2 to $trg/$today.tar.gz" >> $log
        tar -czf $trg/$today.tar.gz $src1 $src2 2>>$log

echo "$(date +"%d.%m.%Y %H:%M") ----- Archive successfully created:      $(du -sh $trg/$today.tar.gz) " >> $log
echo "$(date +"%d.%m.%Y %H:%M") ----- Free space left on /$mount:             $(df -h |grep $mount | tr -s " " | cut -d " " -f4) " >> $log

echo "$(date +"%d.%m.%Y %H:%M") -----    Done !!!   " >> $log

mail -s "Daily backup log" gh.botica@gmail.com < $log

