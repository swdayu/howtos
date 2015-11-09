
# App Components

Android's application framework lets you create rich and innovative apps using a set of reusable components. 
This section explains how you can build the components that define the building blocks of your app 
and how to connect them together using intents. 

## Intents and Intent Filters

An `Intent` is a messaging object you can use to request an action from another `app component`. 
Although intents facilitate communication between components in several ways, 
there are three fundamental use-cases:

- **To start an activity:**

    An `Activity` represents a single screen in an app. 
    You can start a new instance of an `Activity` by passing an `Intent` to `startActivity()`. 
    The `Intent` describes the activity to start and carries any necessary data.

    If you want to receive a result from the activity when it finishes, call `startActivityForResult()`. 
    Your activity receives the result as a separate `Intent` object in your activity's `onActivityResult()` callback. 
    For more information, see the `Activities` guide.

