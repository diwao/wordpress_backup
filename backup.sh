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

#転送先のサーバドメイン/ユーザー/パスワード/保存先ディレクトリ
domain='example.com'
user='user'
password='password'
savepath='/var/www/backup'

#バックアップの保存期間(days)
period=3

#---------------------------------------
#バックアップ処理
#---------------------------------------
echo "Backup start..."

mkdir $dirpath
mkdir $dirpath/httpd

cp -p -r /etc/httpd/conf/ $dirpath/httpd/conf/
cp -p -r /etc/httpd/conf.d/ $dirpath/httpd/conf.d/

cp -p -r $wppath $dirpath/wordpress/

mkdir $dirpath/db
mysqldump -u $dbuser -p$dbpass $dbname > $dirpath/db/$dbfile

cd $basedir
zip -r $basedir/$currentdate.zip $currentdate
rm -rf $dirpath

#---------------------------------------
#バックアップをscpで転送
#---------------------------------------

expect -c "
set timeout 60
spawn scp $basedir/$currentdate.zip $user@$domain:$savepath
expect \"$user@$domain's password:\"
send  \"$password\n\"
expect {\"100%\" { exit 0 }}
"

#---------------------------------------
#古いzipを削除
#---------------------------------------

#削除の基準となる日付を取得
olddate=`date --date "$period days ago" +%Y%m%d`

#現存するzipを探すコマンド
targetcommand="ls -1 "$basedir"/"

for var in `$targetcommand`
do
	#保存期間を過ぎたzipを削除
	target=`echo $var | sed s/\.zip//g`
	if [ $target -le $olddate ]
	then
		rm -f $basedir/$var
		echo "delete $var"
	fi
done

echo "Backup complete!"