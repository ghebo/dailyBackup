#!/bin/bash

#Variables
src1=/backup/daily
src2=/backup/mysql
trg=/backup-manual
log=/var/log/manual-bkp.log
mount=vda1
today=$(date +"%Y%m%d")
archive_name="manual-backup"
email=your.email@example.com
ftp_user="MyFtpUser"
ftp_pass="MyFtpPassword"
ftp_server="ftpserver.example.com"
ftp_port=21
cc="/path/to/ftp/dir"
#End of variables

echo "$(date +"%d.%m.%Y %H:%M") ----- Start !!!   " > $log

echo "$(date +"%d.%m.%Y %H:%M") ----- Removing old backups   " > $log
echo "$(find /backup-manual/ -name '*' -mtime 5)" >> $log

find /backup-manual/ -name '*' -mtime 5 |xargs rm -rf

if [ $(df -h |grep $mount | tr -s " " | cut -d " " -f4 | cut -d "G" -f1 | cut -d "." -f1) -lt 3 ]
        then
                echo "$(date +"%d.%m.%Y %H:%M") ----- ERROR !!! Free space left on /$mount: $(df -h |grep $mount | tr -s " " | cut -d " " -f4) " >> $log
        else

                echo "$(date +"%d.%m.%Y %H:%M") ----- Create archive $src1 and $src2 to $trg/$archive_name_$today.tar.gz" >> $log
                tar -czf $trg/host.involity.com_$today.tar.gz $src1 $src2 2>>$log

                echo "$(date +"%d.%m.%Y %H:%M") ----- Archive successfully created: $(du -sh $trg/$archive_name_$today.tar.gz) " >> $log
                echo "$(date +"%d.%m.%Y %H:%M") ----- Free space left on /$mount: $(df -h |grep $mount | tr -s " " | cut -d " " -f4) " >> $log

                echo "$(date +"%d.%m.%Y %H:%M") ----- Done !!! " >> $log

                echo "$(date +"%d.%m.%Y %H:%M") ----- START copy archive to FTP" >> $log
                sshpass -p $ftp_pass scp -P$ftp_port $trg/$archive_name_$today.tar.gz $ftp_user@$ftp_server:$ftp_dir
                exit_code=$?
                if [ $exit_code -eq 0 ]
                        then
                                echo "Exit Code = $exit_code . Will delete curent backup $trg/$archive_name_$today.tar.gz" >> $log
                                rm -rf $trg/$archive_name_$today.tar.gz
                        else
                                echo "Exit Code = $exit_code . Do not delete curent backup $trg/$archive_name_$today.tar.gz" >> $log
                fi
                echo "$(date +"%d.%m.%Y %H:%M") ----- END copy archive to FTP" >> $log
fi

mail -s "Manual backup log" $email < $log
