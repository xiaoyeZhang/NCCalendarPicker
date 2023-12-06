# NCCalendarPicker

## 安装

##### [CocoaPods](http://cocoapods.org/)是 Cocoa 项目的依赖管理器。您可以使用以下命令安装它：

    $ gem install cocoapods

> 构建 NCCalendarPicker 4.0.0+ 需要 CocoaPods 1.1.0+。

要使用 CocoaPods 将 NCCalendarPicker 集成到您的 Xcode 项目中，请在您的 中指定它`Podfile`：

    platform :ios, '11.0'

    use_frameworks!

    target '<Your Target Name>' do&
    	pod 'NCCalendarPicker'
    end

然后，运行以下命令：

    $ pod install

#### Swift Package Manager

##### Swift Package Manager 是一个用于管理 Swift 代码分发的工具。它与 Swift 构建系统集成，可自动执行下载、编译和链接依赖项的过程。

使用 Swift Package Manager 构建 NCCalendarPicker 需要 Xcode 11+。

要使用 Swift Package Manager 将 NCCalendarPicker 集成到您的 Xcode 项目中，请将其添加到您的 的依赖项值中 Package.swift：

    dependencies: [
    .package(url: "https://github.com/xiaoyeZhang/NCCalendarPicker.git", .upToNextMajor(from: "0.0.1"))
    ]
