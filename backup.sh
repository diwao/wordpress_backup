#!/bin/sh

#---------------------------------------
#変数宣言
#---------------------------------------
#バックアップの保存先
basedir='/var/www/wp-backup'

#バックアップの実行日
currentdate=`date +%Y%m%d`

#保存先ディレクトリのパス
dirpath="$basedir/$currentdate"

#wordpressのパス
wppath="/var/www/html/wordpress"

#MySQLのユーザー/パス/DB名
dbuser='user'
dbpass='pass'
dbname='wordpress'

#dumpしたDBファイル名
dbfile='wordpress.sql'


#---------------------------------------
#バックアップ処理
#---------------------------------------
echo "Backup start..."

mkdir $dirpath
mkdir $dirpath/httpd

cp -p -r /etc/httpd/conf/ $dirpath/apache/conf/
cp -p -r /etc/httpd/conf.d/ $dirpath/apache/conf.d/

cp -p -r $wppath $dirpath/wordpress/

mkdir $dirpath/db
mysqldump -u $dbuser -p$dbpass $dbname > $dirpath/db/$dbfile

cd $basedir
zip -r $basedir/$currentdate.zip $currentdate
rm -rf $dirpath

echo "Backup complete!"