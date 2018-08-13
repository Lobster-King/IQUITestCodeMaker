# Overview

[![Build Status](https://travis-ci.org/Lobster-King/IQUITestCodeMaker.svg?branch=master)](https://travis-ci.org/Lobster-King/IQUITestCodeMaker)
[![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/Lobster-King/IQUITestCodeMaker)
[![CocoaPods](https://img.shields.io/cocoapods/v/IQUITestCodeMaker.svg)](http://cocoapods.org/pods/IQUITestCodeMaker)
[![Github All Releases](https://img.shields.io/github/downloads/Lobster-King/IQUITestCodeMaker/total.svg)](https://github.com/Lobster-King/IQUITestCodeMaker)
![GitHub forks](https://img.shields.io/github/forks/badges/shields.svg?style=social&label=Fork)
![GitHub stars](https://img.shields.io/github/stars/badges/shields.svg?style=social&label=Stars)
![GitHub followers](https://img.shields.io/github/followers/espadrine.svg?style=social&label=Follow)
[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/lobster_geek)

IQUITestCodeMaker is a modern and lightweight tool  for generating iOS UI test script codes automatically without lanuching Appium Desktop or using inspector.

## A series of IQUITestCodeMaker  concepts

* Non intrusive that you don't need to do anything but downloading it using cocoapods.
* Generating script codes automatically.
* In order to make the result more accurate,you are advised to set accessibilityIdentifier manually.
* For performance reasons,you are advised to turn off IQUITestCodeMaker in release mode.
* With the debug ball support,you can export script file to desktop easily.

## Support Languages

- [x] Ruby
- [x] Python
- [x] JavaScript(webdriverio)
- [x] JavaScript(Promise)
- [ ] Java
- [ ] Objective-C
- [ ] Swift

## Reference
* [Generating UI test label automatically for iOS](https://github.com/yulingtianxia/TBUIAutoTest)
* [Appium Server and Inspector in Desktop GUIs for Mac, Windows, and Linux](https://github.com/appium/appium-desktop)

# Get Started

## Installation

### cocoapods

```bash
$ gem install cocoapods
```

### edit podfile
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'Example' do
    pod 'IQUITestCodeMaker',:git => 'https://github.com/Lobster-King/IQUITestCodeMaker.git',:configurations => ['Debug']
end
```
### pod install
```bash
$ pod install
```

# Debug Ball

![Demo gif](https://github.com/Lobster-King/IQUITestCodeMaker/blob/master/Demo.gif)


# About appium
Appium is an open source, cross-platform test automation tool for native,
hybrid and mobile web and desktop apps. It support simulators (iOS), emulators
(Android), and real devices (iOS, Android, Windows, Mac).

## Documentation
* [How to install appium ?](https://github.com/appium/appium/blob/master/docs/en/about-appium/getting-started.md)




# Roadmap

* more languages support.
* macaca support.
* ui element location strategy.

# Have a problem?

You can contact me in the following ways

* PRs or Issues.
* Email :[zhiwei.geek@gmail.com](zhiwei.geek@gmail.com)


