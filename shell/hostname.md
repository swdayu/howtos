
# Ubuntu host name

Change device name display in "System Settings | Details | Overview | **Device name**",
or the hostname display in Terminal "username@**hostname**:~$":

1. check current hostname with command `$ sudo hostname`
2. modify the hostname to you wanted using `$ sudo gedit /etc/hostname`
3. modify hostname in hosts file `$ sudo gedit /etc/hosts`, for example:
    127.0.0.1 localhost
    127.0.1.1 **ubuntu**
4. physically reboot your device
5. open Terminal you will see the updated hostname, for example: `username@ubuntu:~$`
