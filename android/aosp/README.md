# AOSP (android open source project)
- http://source.android.com/source/index.html

## Factory images
- https://developers.google.com/android/nexus/images
- https://source.android.com/source/running.html#booting-into-fastboot-mode

> The factory binary image file allow you to restore your Nexus device's original factory firmware.  
> It includes scripts that flashes the device, typically named `flash-all.sh` or `flash-all.bat` on Windows.  
> To flash a device, you need the latest `fastboot` tool, it can be found in `platform-tools/` under Android SDK.  
> Once you have the `fastboot` and add it to `PATH`, also be certain that you've set up USB access for your device.  
> Flashing a new system image deletes all user data, be certain to first backup data such as photos.  

Flash a system image
> Download the appropriate system image for your device, then unzip it to a safe directory.  
> Switch on "OEM unlocking" in "Developer options" on your device.  
> Connect the device to your computer over USB.  
> Start fastboot mode using `adb reboot bootloader` or press [Volume Down + Power](https://source.android.com/source/running.html#booting-into-fastboot-mode) for example when device off.  
> If necessary, unlock the device's bootloader by `fastboot flashing/oem unlock`, later is for older devices.  
> Open a terminal and navigate to the unzipped system image directory.  
> Execute `flash-all` scipt, it installs the necessary bootloader, baseband firmwares, and operating system.  
> Once the script finishes, your device reboots. You should now lock the bootloader for security:  
> Start the device in fastboot mode again and execute `fastboot flashing lock` or `fastboot oem lock`.  

An example for the `flash-all` script
>     fastboot flash bootloader bootloader-bullhead-bhz11f.img
    fastboot reboot-bootloader
    sleep 5
    fastboot flash radio radio-bullhead-m8994f-2.6.33.2.14.img
    fastboot reboot-bootloader
    sleep 5
    # files in this zip: boot.img cache.img recovery.img system.img userdata.img vendor.img
    fastboot -w update image-bullhead-nbd90w.zip

## OTA images
- https://developers.google.com/android/nexus/ota

> The OTA binary image file allow you to manually update your Nexus devices.  
> This has the same effect of flashing the corresponding factory images, but without wiping the device.  
> But for safety, be certain to first backup your data such as photos before applying update.  
> To apply an OTA update image, follow steps shown below:  
> Download the appropriate update image for your device.  
> With the device powered on and USB debugging enabled, execute `adb reboot recovery`.  
> Hold "Power" button and press "Volume Up" once, select "Apply update from ADB" from shown menu.  
> Run the command `adb sideload your_ota_file.zip`.  
> Once the update finishes, you should reboot the phone by choosing `Reboot the system now`.  
> For device security, you should disable USB debugging when it is not being updated.  

## Android versions and builds

| Build | Branch | Version |
| :---- | :----- | :------ |
| NBD90W (Nexus 5X) | android-7.0.0_r12 | Nougat (API level 24) |
| NRD90S (Nexus 5X) | android-7.0.0_r4 | Nougat (API level 24) |
| NRD90R (Nexus 5X) | android-7.0.0_r3 | Nougat (API level 24) |
| NRD90M (Nexus 5X) | android-7.0.0_r1 | Nougat (API level 24) |
| MTC20K (Nexus 5X) | android-6.0.1_r67 | Marshmallow (API level 23) |
| MTC20F (Nexus 5X) | android-6.0.1_r62 | Marshmallow (API level 23) |
| MTC19Z (Nexus 5X) | android-6.0.1_r54 | Marshmallow (API level 23) |
| MTC19V (Nexus 5X) | android-6.0.1_r45 | Marshmallow (API level 23) |
| MTC19T (Nexus 5X) | android-6.0.1_r25 | Marshmallow (API level 23) |
| MHC19Q (Nexus 5X) | android-6.0.1_r24 | Marshmallow (API level 23) |
| MHC19J (Nexus 5X) | android-6.0.1_r22 | Marshmallow (API level 23) |
| MMB29V (Nexus 5X) | android-6.0.1_r17 | Marshmallow (API level 23) |
| MMB29Q (Nexus 5X) | android-6.0.1_r11 | Marshmallow (API level 23) |
| MMB29P (Nexus 5X) | android-6.0.1_r8 | Marshmallow (API level 23) |
| MMB29K (Nexus 5X) | android-6.0.1_r1 | Marshmallow (API level 23) |
| MDB08M (Nexus 5X) | android-6.0.0_r26 | Marshmallow (API level 23) |
| MDB08L (Nexus 5X) | android-6.0.0_r25 | Marshmallow (API level 23) |
| MDB08I (Nexus 5X) | android-6.0.0_r23 | Marshmallow (API level 23) |
| MDA89E (Nexus 5X) | android-6.0.0_r12 | Marshmallow (API level 23) |
