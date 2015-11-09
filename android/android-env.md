
# Android Studio
- http://developer.android.com/sdk/index.html
- http://developer.android.com/sdk/installing/index.html?pkg=studio

## Install

Before you set up Android Studio, be sure you have installed JDK 6 or higher (the JRE alone is not sufficient), 
JDK 7 is required when developing for Android 5.0 and higher.
To check if you have JDK installed (and which version), open a terminal and type `javac -version`.
If the JDK is not available or the version is lower than version 6, 
download the [Java SE Development Kit 7][].

[Java SE Development Kit 7]: http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html

**To set up Android Studio on Windows:**

1. Launch the `.exe` file you just download.
2. Follow the setup wizard to install Android Studio and any necessary SDK tools.
   On some Windows systems, the launcher script does not find where Java is installed.
   If you encounter this problem, you need to set an environment variable indicating the correct location.
   Select **Environment Variables** and add a new system variable `JAVA_HOME` that points to your JDK folder,
   for example `C:\Program Files\Java\jdk1.7.0_21`.

The individual tools and other SDK packages are saved outside the Android Studio application directory.
If you need to access tools directly, use a terminal to navigate to the location where they are installed.
For example: `\Users\<user>\sdk\`.

**To set up Android Studio on Mac OSX:**

1. Launch the `.dmg` file you just download.
2. Drag and drop Android Studio into the Applications folder.
3. Open Android Studio and follow the setup wizard to install any necessary SDK tolls.
   Depending on your security settings, when you attempt to open Android Studio,
   you might see a warning that says the packages is damaged and shoud be moved to the trash.
   If this happens, go to **System Preferences > Security & Privacy** and 
   under **Allow applications downloaded from**, select **Anywhere**.
   The open Android Studio again.

If you need use the Android SDK tools from a command line, you can access them at:
`/Users/<user>/Library/Android/sdk/`.

**To set up Android Studio on Linux:**

1. Unpack the downloaded ZIP file into an appropriate location for your applications.
2. To launch Android Studio, navigate to the `android-studio/bin/` directory in a terminal
   and execute `studio.sh`. You may want to add `android-studio/bin/` to your PATH environment
   variable so that you can start Android Studio from any directory.
3. If the SDK is not already installed, follow the setup wizard to install the SDK and any necessary SDK tools.
   Note: You may also need to install the ia32-libs, lib32ncurses5-dev, and lib32stdc++6 packages.
   These packages are required to support 32-bit apps on a 64-bit machine.

The Android SDK will be installed at `/home/<user>/Android/Sdk` by default.

Android Studio is now ready and loaded with the Android developer tools,
but there are still a couple packages you should add to make your Android SDK complete.

## Adding SDK Packages

By default, the Android SDK does not include everything you need to start developing.
The SDK separates tools, platforms, and other components into packages 
you can downloaded as needed using the Android SDK Manager.
So before you can start, there are a few packages you should add to your Android SDK.

To start adding packages, launch the Android SDK Manager in one of the following ways:
- In Android Studio, click **SDK Manager** in the toolbar.
- Windows: Double-click the `SDK Manager.exe` file at the root of the Android SDK directory.
- Mac/Linux: Open a terminal and navigate to the `tools/` directory in the location where
  the Android SDK was installed, then execute `android sdk`.

When you open the SDK Manager for the first time, several packages are selected by default.
Leave these selected, but be sure you have everything you need to get started by following these steps:

1. **Get the latest SDK tools**

   As a minimum when setting up the Android SDK, you should download the latest tools and Android platform.
   
   Open the tools directory and select: Android SDK Tools, Android SDK Platform-tools, 
   Android SDK Build-tools (highest version)
   
   Open the first Android X.X folder (the latest version) and select: SDK Platform,
   A system image for the emulator, such as ARM EABI v7a System Image.
   
2. **Get the support library for additional APIs**

   The Android Support Library provides an extended set of APIs that
   are compatible with most versions of Android.
   
   Open the **Extras** directory and select: Android Support Repository, Android Support Library.
   
3. Build something

   With the above packages now in your Android SDK, you're ready to build apps for Android.
   As new tools and other APIs become available, simply launch the SDK Manager 
   to download the new packages for your SDK.
   

