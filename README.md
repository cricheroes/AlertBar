# AlertBar

[![Version](https://img.shields.io/cocoapods/v/AlertBar.svg?style=flat)](http://cocoapods.org/pods/AlertBar)
[![License](https://img.shields.io/cocoapods/l/AlertBar.svg?style=flat)](http://cocoapods.org/pods/AlertBar)
[![Platform](https://img.shields.io/cocoapods/p/AlertBar.svg?style=flat)](http://cocoapods.org/pods/AlertBar)

An easy alert on status bar.

![demo](./etc/demo.gif)

## Usage
### Import
```
import AlertBar
```

### Show alert message
AlertBar has default types:
- success
- error
- notice
- warning
- info

```
AlertBar.show(.success, message: "This is a Success message.")
```

And you can customize the background and text colors of AlertBar.  
Select `Custom` type and set background and text colors as UIColor:  `.Custom(BackgroundColor, TextColor)`

```
AlertBar.show(.custom(.lightGray, UIColor.black), message: "This is a Custom message.")
```

#### Alert duration
AlertBar accepts to custom alert duration.
```
AlertBar.show(.success, message: "This is a Success message.", duration: 10)
```

### Custom Options
#### TextAlignment
AlertBar accepts to custom text alignment.  
NOTE: This option is global.
```
AlertBar.textAlignment = .center
```

## Requirements

- Swift 3.0
- iOS 8.0
- ARC

## Installation
[!] AlertBar 0.2.0 requires CocoaPods 1.1.0

AlertBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AlertBar"
```

## Author

Jin Sasaki, sasakky_j@gmail.com

## License

AlertBar is available under the MIT license. See the LICENSE file for more info.
