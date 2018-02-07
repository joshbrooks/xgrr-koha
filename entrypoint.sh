#! /bin/bash
echo "entrypoint.sh"

username="$name-koha"
configdump=/library/$name.tar.gz
sqldump=/library/.sql.gz
database=koha_$name

echo "Check server connection"

echo "Waiting for server $server to become available"
until mysql -u$user -h$server -p$pass -e ";" ; do
    sleep 5
done

if ! grep $username /etc/passwd; then
	echo "Create user $username"
	adduser --no-create-home --disabled-login --gecos "Koha instance $username" \
    	--home "/var/lib/koha/$name" --quiet "$username"

echo "Creating koha library directories"
koha-create-dirs "$name"
tar -C / -xf "$configdump"
sed -i -e"s|<hostname>localhost</hostname>|<hostname>$server</hostname>|" /etc/koha/sites/$name/koha-conf.xml
fi



if ! mysql -u$user -h$server -p$pass -e ";" $database ; then
	echo "Re-create database and database user."

	mysqldb="koha_$name"
	mysqluser="koha_$name"
	mysqlpwd="$( xmlstarlet sel -t -v 'yazgfs/config/pass' /etc/koha/sites/$name/koha-conf.xml )"
	zcat "$sqldump" | mysql --defaults-extra-file=/etc/mysql/koha-common.cnf
	mysql --defaults-extra-file=/etc/mysql/koha-common.cnf -e "DROP USER '$mysqluser';"
	mysql --defaults-extra-file=/etc/mysql/koha-common.cnf -e " \
	CREATE USER '$mysqluser' IDENTIFIED BY '$mysqlpwd'; \
	GRANT ALL PRIVILEGES ON $mysqldb.* TO '$mysqluser'; \
	FLUSH PRIVILEGES;"
	koha-rebuild-zebra --full "$name"

        else
            echo "Made a connection to $database"
fi

if [ -f "/etc/apache2/sites-enabled/000-default.conf" ] ; then
	echo 'Disable default site'
	a2dissite 000-default
fi

koha-start-zebra $name

/usr/sbin/apache2ctl -D FOREGROUND
