README.md

# proyecto
XYZ 

# hosts
[XYZ]
golf01.example.com
golf00.example.com

# instalar requerimientos
ansible XYZ -m raw -a "sudo yum -y install python-simplejson"

# ticket
ticket nro [123456 Linux VM - Permissions to write](https://tickets.acme.com/issues/123456)


Recientemente pedi si podian darle acceso a john.doe con los mismos permisos que james.doe... Aparentemente estaba todo ok, puede hacer algunas cosas como subir y bajar apache, pero no tiene permiso de escritura sobre los directorios de apache (/var/www)

 Te pido si podemos crear un grupo que sean owners y asignar a los usuarios john.doe y martin.doe