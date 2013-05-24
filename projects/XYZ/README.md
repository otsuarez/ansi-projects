# project XYZ

 

## hosts

```
[XYZ]
golf01.example.com
golf00.example.com
```

## ansible requirements

ansible XYZ -m raw -a "sudo yum -y install python-simplejson"

## project request

To provide a set of privileges to a group of users:
* start,stop,restart the apache daemon
* copy/delete permissions on the /var/www directory
* assign those privileges to users: john.doe and martin.doe
