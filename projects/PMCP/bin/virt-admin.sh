#!/bin/bash

i=0
I=

SITES=/opt/example/sites
ROOT=$SITES/www

SUDOERSFILE=/etc/sudoers.d/virtualhosts
SUDOERS_ADMIN_FILE=/etc/sudoers.d/virtualadmin
SUDOERS_VHOSTADMIN_FILE=/etc/sudoers.d/vhostsadmins

MYSQLCMD="/usr/bin/mysql"

ADMIN=luke.doe@acme.com
ADMINGROUP=tomcat
UNIXADMIN=root@acme.com
MAILTO=$ADMIN,$UNIXADMIN

VIRTUALADMIN=/opt/example/sites/config/virtualadmins
VHOSTSADMINSFILE=/opt/example/sites/config/vhostsadmins

function rebuild_permissions() {
  SUDOVIRTUALUSERS=""
  cat /dev/null > $SUDOERS_VHOSTADMIN_FILE
  for j in `cat $VHOSTSADMINSFILE` 
  do 
    IFS=':' read -a vadmins <<< "${j}"
    CMDALIAS=`echo ${vadmins[0]} | tr [a-z] [A-Z]`CMNDS
    USERALIAS=`echo ${vadmins[0]} | tr [a-z] [A-Z]`USERS
    cat >>$SUDOERS_VHOSTADMIN_FILE<<EOF
Cmnd_Alias   $CMDALIAS = /bin/su - ${vadmins[0]}
User_Alias ${USERALIAS} = ${vadmins[1]}
$USERALIAS        ALL     = (ALL) NOPASSWD: $CMDALIAS

EOF
done
  chmod 644   $VHOSTSADMINSFILE
  chown $ADMIN:$ADMINGROUP $VHOSTSADMINSFILE
  chmod 440 $SUDOERS_VHOSTADMIN_FILE
}

function create_system_user() {
	/usr/sbin/adduser -c "Virtual site admin" $vhostname
	all=""
	for i in `grep "Virtual site" /etc/passwd | cut -d":" -f1` ; do  all="$i, $all" ; done
	VIRTUALUSERS=`echo $all | sed 's/,$//'`
	cat >$SUDOERSFILE<<EOF
Cmnd_Alias   VIRTUALCMNDS = /usr/local/bin/virt-chown.sh

VIRTUALUSERS        ALL     = (ALL) NOPASSWD: VIRTUALCMNDS

User_Alias VIRTUALUSERS = $VIRTUALUSERS
EOF
	SUDOVIRTUALUSERS=""
	for i in `grep "Virtual site" /etc/passwd | cut -d":" -f1` ; do  SUDOVIRTUALUSERS="/bin/su - $i, $SUDOVIRTUALUSERS" ; done
	for j in `cat $VIRTUALADMIN` ; do I="$j, $I"; done
	VIRTUALADM=`echo $I | sed 's/,$//'`
	cat >$SUDOERS_ADMIN_FILE<<EOF
Cmnd_Alias   ADMINCMNDS = $SUDOVIRTUALUSERS /usr/local/bin/virt-admin.sh

User_Alias VIRTUALADMIN = $VIRTUALADM

VIRTUALADMIN        ALL     = (ALL) NOPASSWD: ADMINCMNDS
EOF
	chmod 440 $SUDOERSFILE
	chmod 440 $SUDOERS_ADMIN_FILE
}

function create_site_home() {
	mkdir $ROOT/$vhostname
	chown $vhostname $ROOT/$vhostname
}

function create_conf() {
	#echo "creating web config" 
	cp $SITES/templates/$template $SITES/config/vhost.d/$vhostname.conf
	sed -i "s|DOCUMENTROOT|$ROOT|g" $SITES/config/vhost.d/$vhostname.conf
  	sed -i "s/VHOSTNAME/$vhostname/g" $SITES/config/vhost.d/$vhostname.conf
  	/usr/sbin/apachectl graceful
}

function create_db() {
	#echo "creating db"
	echo "CREATE DATABASE db_$vhostname;" | $MYSQLCMD
}

function create_db_user() {
	echo "GRANT ALL PRIVILEGES on db_$vhostname.* TO $vhostname@'localhost' IDENTIFIED BY '$MYPASS';" | $MYSQLCMD
	#echo "database user: $vhostname"; echo "database user password: $MYPASS";
}

function create_notification() {
	MSG="Se ha creado un nuevo entorno virtual con los siguientes datos:\n
\n
Directorio raiz del sitio web: $ROOT/$vhostname\n
Usuario: $vhostname\n
\n
Database name: db_$vhostname\n
Database user: $vhostname\n
Database user password: $MYPASS\n
\n
Para trabajar con este entorno debera utilizar el usuario creado a traves del comando sudo:\n
sudo /bin/su - $vhostname\n
\n
El sitio web se encuentra accesible a traves de la URL:\n
http://$vhostname.dev.acme.com\n
\n
Puede trabajar con la base de datos accediendo a traves de la url:\n
http://$vhostname.dev.acme.com/phpmyadmin/\n
\n
En caso de existir alguna duda contactar al administrador del entorno: $ADMIN\n
\n"	
	echo -e $MSG
	echo -e $MSG | mail -s "nuevo entorno virtual $vhostname" $MAILTO
	echo ""
        echo "---------------------------------------------------"
	echo ""
}

function create_site() {
	create_system_user
	create_site_home
	create_conf
	create_db
	create_db_user
	create_notification
}

function delete_system_user() {
        echo "deleting system user"
	/usr/sbin/userdel $vhostname
}

function delete_site_home() {
        echo "deleting site home: $ROOT$vhostname"
  	rm -fr $ROOT/$vhostname
}

function delete_conf() {
        echo "deleting web config"
  rm $SITES/config/vhost.d/$vhostname.conf
  /usr/sbin/apachectl graceful
}

function delete_db_user() {
        echo "deleting db user"
	echo "DELETE USER $vhostname@'localhost';" | $MYSQLCMD
}

function delete_db() {
        echo "deleting db"
	echo "DROP DATABASE db_$vhostname;" | $MYSQLCMD
}

function delete_site() {
        delete_conf
        delete_site_home
        delete_db_user
        delete_db
        delete_system_user
}
 
function create_default_template() {
  cat >$SITES/templates/default<<'EOF'
<VirtualHost *:80>
        ServerAdmin root@acme.com
        ServerName VHOSTNAME.dev.acme.com
        DocumentRoot DOCUMENTROOT/VHOSTNAME/
        ErrorLog logs/VHOSTNAME-error.log
        CustomLog logs/VHOSTNAME-access.log common
</VirtualHost>
EOF
  cat >$SITES/templates/tomcat<<'EOF'
#ProxyRequests Off
#ProxyPreserveHost On
<VirtualHost *:80>
        ServerAdmin root@acme.com
        ServerName VHOSTNAME.dev.acme.com
        ErrorLog logs/VHOSTNAME-error.log
        CustomLog logs/VHOSTNAME-access.log common
        ProxyPass / ajp://localhost:8009/
        ProxyPassReverse /  ajp://localhost:8009/
</VirtualHost>
EOF
}

if [ ! -d "$SITES" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    mkdir -p $SITES/{templates,bin,www,config}
    mkdir -p $SITES/config/vhost.d
    create_default_template
fi


while [ $i != "Q" ]
do
  clear

  if [ $i = "1" ]
  then 
  echo "Listado de sitios"
	ls -1 $ROOT
        echo ""
        echo "---------------------------------------------------"
        echo ""
  fi

  if [ $i = "2" ]
  then
  PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c8`
  MYPASS=`echo $PASS | rev`
  echo "Ingrese el <nombre> del nuevo sitio a crear (<nombre>.dev.acme.com):"
  read vhostname
  echo "Tipos de sitio disponibles:"
  ls $SITES/templates/
  lamp=default
  read -e -p "Ingrese el nombre de sitio: [$lamp] "  template
  [ -z "$template" ] && template=$lamp
  #TODO validate template
  echo "---------------------------------------------------"
  echo ""
  create_site
        echo ""
        echo "Sitio creado exitosamente"
        echo ""
        echo "---------------------------------------------------"
        echo ""
  fi

  if [ $i = "3" ]
  then
  echo "Sitios disponibles:"
  ls $ROOT
  echo "Ingrese el nombre del sitio a eliminar:"
  read vhostname
  delete_site
  echo "Listo..."
  echo ""
  echo "---------------------------------------------------"
  echo ""
  fi

  if [ $i = "4" ]
  then
  	echo "rebuilding permissions for site admins :"
  	rebuild_permissions
  fi

  echo "Manejo de sitios virtuales"
  echo "---------------------------------------------------"
  echo "1: Listar sitios"
  echo "2: Crear un nuevo sitio"
  echo "3: Eliminar un sitio"
  echo "4: Rebuild site admin permissions"
  echo "Q: Salir"
  
  read i
done
