[< 🏠 Github](https://github.com/trinhngocthuyen/xccache)

# 📚 XCCache Knowledge Base
![xccache](res/xccache.png)
Yet another caching tool for Xcode projects but with SPM support

## 🎯 Motivation
Caching frameworks is a popular technique to tackle project build time in many large-scale projects. A few outstanding tools in this category are cocoapods-binary-cache, Rugby, and XCRemoteCache. Rugby and cocoapods-binary-cache are particularly tailored for CocoaPods-based projects while XCRemoteCache works for a more general project structure. However, all three of them has the same limitation: **lacking support for SPM/Swift packages**.

This **xccache** tool attempts to bridge that gap.\
The long-term vision of this initiative is to make it a unified caching tool for iOS projects, including CocoaPods-based structures.

## 📑 Documentation

Check out these docs to understand more about xccache:

- [🔧 How to Install](how-to-install.md)
- [📝 Overview](overview.md)
- [🚀 Getting Started](getting-started.md)
- [📖 Under the Hood](under-the-hood)
  - [Packaging as an xcframework](under-the-hood/packaging-as-xcframework.md)
  - [Ensuring `Bundle.module` When Accessing Resources](under-the-hood/ensuring-bundle-module.md)
  - [Macro as Binary](under-the-hood/macro-as-binary.md)
- [🩺 Troubleshooting](troubleshooting.md)

## 🤝 Contribution
Refer to the [contributing guidelines](/CONTRIBUTING.md) for details.

## ⚖️ License
The tool is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## ✍️ Acknowledgement
- [Cytoscape.js](https://github.com/cytoscape/cytoscape.js) for the cachemap visualization

## ⭐ Support
If you find this project interesting and useful, keep me going by leaving a star ⭐, sharing the project, or [buying me a coffee](https://buymeacoffee.com/trinhngocthuyen) 🫶.
