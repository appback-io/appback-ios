# appback-ios

## Install the SDK

Our SDK is distributed using Cocoapods. If you are not familiar with Cocoapods, check them out [here](https://cocoapods.org/#install).

First add our pod to your Podfile

```text
pod 'AppBack'
```

Now update your project by running an install

```text
pod install
```

### Configure the SDK

Open your project .xcworkspace and then import the dependency on your AppDelegate.swift

```text
import AppBack
```

Now add the configure method from AppBack to your didFinishLaunchingWithOptions method like this:

```text
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppBack.shared.configure(apiKey: "PASTE_YOUR_API_KEY_HERE")
        return true
    }
```

## Feature Toggles

Once you have AppBack configured in your project, you can make use of the Feature Toggle functionality.

### Configure initial call

This call will be used whenever it is required to update the list of values registered in our AppBack dashboard.

```text
AppBack.shared.getToggles(router: ”MY_ROUTER”) { (success) in
    if success {
        // The call was successful
    }
}
```

### Get features toggles

You can use some of the following methods depending on the type of value defined in the AppBack dashboard.

```text
let welcomeMessage: String = AppBack.shared.getStringToggle("welcome_message")
let showWelcomeMessage: Bool = AppBack.shared.getBoolToggle("show_welcome_message")
let attemptsNumber: Int = AppBack.shared.getIntToggle("attempts_number")
let sodaPrice: Double = AppBack.shared.getDoubleToggle("soda_price")
```

**NOTE**
These values were previously defined in the AppBack dashboard: welcome_message, show_welcome_message, attempts_number and soda_price
***

Complete guide docs [here](https://appback.io/docs/)
