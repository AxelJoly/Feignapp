# Feignapp



## Introduction



This app is simply a little project made for my daily usage.

UPDATE v1.1: You can now define your stations in the settings page, it will synchronize automatically on your Apple Watch App.





## Screenshots

### Apple Watch App


<img src="https://github.com/AxelJoly/Feignapp/blob/master/watch1.png" width="300" height="300" />



### iPhone App

| <img src="https://github.com/AxelJoly/Feignapp/blob/master/phone1.png" width="300" height="650" /> | <img src="https://github.com/AxelJoly/Feignapp/blob/master/phone2.png" width="300" height="650" /> |
| ------------- | ------------- |




## Installation

```pod install``` inside your root folder to install CocoaPods frameworks

If you want to log with Firebase, I let you refer to this link how to configure Firebase with iOS: ```https://firebase.google.com/docs/ios/setup```

Create a "env" folder.

Create and add Environment.swift in env folder.

Finally, you should implement Environment.swift class like that:



```config

class Environment: NSObject {

var SNCF_TOKEN = "YourToken"
var PHONE_NUMBER = "YourPhoneNumber"

}

```



You can simply get your token on this url:  https://www.digital.sncf.com/startup/api

## Requirements
- WatchOS 4.0+
- iOS 11.0+

## Built With

* [Alamofire](https://github.com/Alamofire/Alamofire) -  HTTP networking library
* [SwiftJSON](https://github.com/SwiftyJSON/SwiftyJSON) - Makes it easy to deal with JSON data in Swift.
* [Firebase](https://firebase.google.com/) - Google database services
*  [PopupDialog](https://github.com/Orderella/PopupDialog) - Customizable popup dialog
* [EMTLoadingIndicator](https://github.com/hirokimu/EMTLoadingIndicator) - Displays loading indicator on Apple watchOS 3+
* [SearchTextField](https://github.com/apasccon/SearchTextField) - Show an autocomplete suggestions list.

## Authors

* **Joly Axel** - *Computer science student at ISEN Toulon* - [Github](https://github.com/AxelJoly)
