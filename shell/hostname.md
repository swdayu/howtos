
Using following commands to change the hostname on Ubuntu:
```
$ sudo hostname # display current hostname
$ sudo gedit /etc/hostname
$ sudo gedit /etc/hosts
```

After physically reboot your device, the hostname will be updated permanently.
Check the name display in `System Settings | Details | Overview | **Device name**`,
and the name on the Terminal `username@**hostname**:~$`.
