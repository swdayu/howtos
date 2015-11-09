
# Common Intents

An intent allows you to start an activity in another app by describing a simple action you'd like to perform 
(such as "view a map" or "take a picture") in an Intent object. 
This type of intent is called an implicit intent because it does not specify the app component to start, 
but instead specifies an action and provides some data with which to perform the action.

When you call `startActivity()` or `startActivityForResult()` and pass it an implicit intent, 
the system resolves the intent to an app that can handle the intent and starts its corresponding Activity. 
If there's more than one app that can handle the intent, 
the system presents the user with a dialog to pick which app to use.

This page describes several implicit intents that you can use to perform common actions, 
organized by the type of app that handles the intent. 
Each section also shows how you can create an intent filter to advertise your app's ability 
to perform the same action.

> **Caution:** If there are no apps on the device that can receive the implicit intent, 
your app will crash when it calls `startActivity()`. 
To first verify that an app exists to receive the intent, call `resolveActivity()` on your Intent object. 
If the result is non-null, there is at least one app that can handle the intent 
and it's safe to call `startActivity()`. 
If the result is null, you should not use the intent and, if possible, 
you should disable the feature that invokes the intent.

If you're not familiar with how to create intents or intent filters, 
you should first read [Intents and Intent Filters](./1-intents-and-filters.md).

To learn how to fire the intents listed on this page from your development host, 
see [Verify Intents with the Android Debug Bridge][1].

[1]: https://developer.android.com/guide/components/intents-common.html#AdbIntents.

## Create an alarm

To create a new alarm, use the `ACTION_SET_ALARM` action and specify alarm details 
such as the time and message using extras defined below.

> **Note:** Only the hour, minutes, and message extras are available in Android 2.3 (API level 9) and higher. 
The other extras were added in later versions of the platform.

**Example intent:**

```java
public void createAlram(String message, int hour, int minutes) {
  Intent intent = new Intent(AlarmClock.ACTIAON_SET_ALARM)
          .putExtra(AlarmClock.EXTRA_MESSAGE, message)
          .putExtra(AlarmClock.EXTRA_HOUR, hour)
          .putExtra(AlarmClock.EXTRA_MINUTES, minutes);
  if (intent.resolveActivity(getPackageManager()) != null) {
    startActivity(intent);
  }
}
```

> **Note:** In order to invoke the `ACTION_SET_ALARM` intent, your app must have the `SET_ALARM` permission:
> ```
> <uses-permission android:name="com.android.alarm.permission.SET_ALARM" />
> ```

**Example intent filter:**
```xml
<activity ...>
  <intent-filter>
    <action android:name="android.intent.action.SET_ALARM" />
    <category android:name="android.intent.category.DEFAULT" />
  </intent-filter>
</activity>
```
