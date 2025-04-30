# xccache (Yet another caching tool, but with SPM support)

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/trinhngocthuyen/xccache/blob/main/LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/xccache.svg)](https://rubygems.org/gems/xccache)

## 🎯 Motivation
Caching frameworks is a popular technique to tackle project build time in many large-scale projects. A few outstanding tools in this category are cocoapods-binary-cache, Rugby, and XCRemoteCache. Rugby and cocoapods-binary-cache are particularly tailored for CocoaPods-based projects while XCRemoteCache works for a more general project structure. However, all three of them has the same limitation: **lacking support for SPM/Swift packages**.

This **xccache** tool attempts to bridge that gap.\
The long-term vision of this initiative is to make it a unified caching tool for iOS projects, including CocoaPods-based structures.

## 🔧 Installation
Via [Bundler](https://bundler.io): Add the gem `xccache` to the Gemfile of your project.

```rb
gem "xccache"
```

Via [RubyGems](https://rubygems.org):
```sh
$ gem install xccache
```

## 🚀 Getting Started
Check out this doc: [Getting Started](docs/getting-started.md)

TLDR: Simply run `xccache` to set it up. Run `xccache --help` to explore the usages.

## 🤝 Contribution
Refer to the [contributing guidelines](CONTRIBUTING.md) for details.

## ⚖️ License
The tool is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## ✍️ Acknowledgement
- [Cytoscape.js](https://github.com/cytoscape/cytoscape.js) for the cachemap visualization

## ⭐ Support
If you find this project interesting and useful, keep me going by leaving a star ⭐, sharing the project, or [buying me a coffee](https://buymeacoffee.com/trinhngocthuyen) 🫶.
