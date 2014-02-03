XenServer_XCP
=============

Scripts o documentación sobre Xen (XenServer y XCP)

* **hostBackup.sh**
Permite realizar backup del host de XEN

* **metaBackup.sh**
Permite realizar backup de los metadatos del Host de XEN

* **vmsBackup.sh**
Este script por defecto permite realizar backup de todas las Virtual Machines del Host de XEN.
Por defecto, solamente **hace backup de las VM que tengan un TAG: BACKUP**
También es posible utilizarlo para hacer backup de 1 VM, pasando como parámetro el nombre de la VM

  Una de las últimas funcionalidades añadidas, es que **permite excluir discos en las VMs**, para ello, solamente hay que añadir en la descripción del disco, para que aparezca la palabra NOBACKUP. El script, hace un SnapShot de la VM, y elimina los discos del SnapShot que tienen esa palabra en la descripción del disco.
