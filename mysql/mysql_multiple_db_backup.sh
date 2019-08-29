#!/bin/bash
 
################################################################
##
##   MySQL Database Backup Script 
##   Written By: Sharon Sahadevan
##  
################################################################
 
export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%m-%d-%y"`
 
################################################################
################## Update below values  ########################
 
DB_BACKUP_PATH='/var/database_backup'
MYSQL_HOST='HOST'
MYSQL_PORT='PORT'
MYSQL_USER='USER'
MYSQL_PASSWORD='PASSWORD'
BACKUP_RETAIN_DAYS=14   ## Number of days to keep local backup copy
 
#################################################################

mkdir -p ${DB_BACKUP_PATH}/${TODAY}
databases=`/usr/local/mysql/bin/mysql -u${MYSQL_USER} -e 'show databases' -s --skip-column-names -p${MYSQL_PASSWORD} | grep -Ev "(Database|information_schema|performance_schema)"`;

for DATABASE_NAME in $databases; do
echo "Backup started for database - ${DATABASE_NAME}"
 
 
/usr/local/mysql/bin/mysqldump --routines -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD}  ${DATABASE_NAME} | gzip > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql.gz
 
if [ $? -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
  exit 1
fi
done

##### Upload latest backup to S3 if it is Sunday###############

 
##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
 
DBDELDATE=`date +"%m-%d-%y" --date="${BACKUP_RETAIN_DAYS} days ago"`
 
if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi
 
### End of script ####
