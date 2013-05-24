
Administración
==============

El script maneja dos grupos de administradores. Los administradores del ambiente, son los autorizados a ejecutar el script y tienen acceso a todos los sites.
Los administradores de los sites se definen por separado para cada site.


Admins del ambiente virtual
===========================

Son los usuarios que pueden ejecutar el script <code>virt-admin.sh</code> y pueden trabajar con todos los sites

## archivo de configuracion

Se definen en el archivo: <code>/opt/example/sites/config/virtualadmins</code>.

## formato 

El archivo de configuracion se compone de un listado de usuarios, un usuario por linea. El usuario es el nombre de la cuenta tal como se utiliza para iniciar sesión por ssh.

e.g.
luke.doe
mark.doe

## nota

Los admins tienen permisos para trabajar con todos los sites de manera predeterminada.

Admins de los sites
===================

Especifica que usuarios que pueden trabajar con que sites

## archivo de configuracion

Se definen en el archivo: <code>/opt/example/sites/config/vhostsadmins</code>.

## formato 

El archivo de configuracion sigue el siguiente formato

```
<site>:<listado de usuarios separados por coma>
```

ejemplo:

```
tango:luke.doe,mark.doe
lima:root
```
