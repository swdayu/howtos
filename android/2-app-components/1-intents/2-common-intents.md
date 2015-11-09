
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

## Google Now

Google Now fires some of the intents listed on this page in response to voice commands. 
For more information, see [Intents Fired by Google Now][2].

[1]: https://developer.android.com/guide/components/intents-common.html#AdbIntents.
[2]: https://developer.android.com/guide/components/intents-common.html#Now
