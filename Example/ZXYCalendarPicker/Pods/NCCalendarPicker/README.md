# NCCalendarPicker

## 安装

Swift Package Manager

Swift Package Manager是一个用于管理 Swift 代码分发的工具。它与 Swift 构建系统集成，可自动执行下载、编译和链接依赖项的过程。

使用 Swift Package Manager 构建 NCCalendarPicker 需要 Xcode 11+。

要使用 Swift Package Manager 将 NCCalendarPicker 集成到您的 Xcode 项目中，请将其添加到您的 的依赖项值中Package.swift：

dependencies: [
    .package(url: "https://github.com/xiaoyeZhang/NCCalendarPicker.git", .upToNextMajor(from: "0.0.1"))
]
