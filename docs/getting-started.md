[< Documentation](README.md)

# Getting Started

<details>
<summary>Table of Contents</summary>

- [Quick Start](#quick-start)
- [Overview](#overview)
- [Working With Cache](#working-with-cache)
  - [Building Cache](#building-cache)
  - [Using Cache](#using-cache)
  - [Viewing Cachemap Visualization](#viewing-cachemap-visualization)
  - [Switching Between Binary and Source Code](#switching-between-binary-and-source-code)
  - [Rolling Back Cache](#rolling-back-cache)
- [Working With Swift Packages](#working-with-swift-packages)
  - [Building a Swift Package Target](#building-a-swift-package-target)
</details>

## Quick Start

Simply run `xccache` under the root directory of the project. Then, you should see:
- **`xccache.lock`**: containing the info about packages in the project alongside the products being used. You're recommended to track this file in git.
- The `xccache` directory: containing build intermediates for the integration. This directory is similar to the `Pods` directory (in CocoaPods). Do NOT remove this directory. Instead, please ignore it from git.

> [!NOTE]
> If you see product dependencies of a Swift package being removed from the *Link Binary With Libraries* section, it is expected.\
> In return, this plugin adds another `<Target>.xccache` product which includes your product dependencies.

<img src="res/umbrella_product_dependencies.png" width="580px">

## Overview
Refer to this doc: [Overview](overview.md)

## Working With Cache

> [!TIP]
> Use the `--help` option in the CLI to explore available (sub)commands and their supported options/flags.

### Building Cache

To build cache of Swift packages, run `xccache build`.

By default, the tool only builds cache-missed targets. Use the `--target` option to specify the targets to build (comma separated).
```sh
xccache build --target=SwiftyBeaver,SDWebImage
```
The prebuilt xcframeworks are available under `xccache/binaries`, following the structure as below:
```
xccache /-- binaries /-- SwiftyBeaver /-- SwiftyBeaver-<checksum>.xcframework
                                      |-- SwiftyBeaver.xcframework
```

### Using Cache
Run `xccache use` or simply `xccache` to integrate cache to the project. Note that cache, after being built with `xccache build`, is automatically integrated to the project. You don't need to run `xccache use` in this case.

In the package manifest (Package.swift) of the umbrella package (named xccache), you should see a generated JSON string as follows:
```swift
let JSON = """
{
  "targets": {
    "EX.xccache": [
      "SwiftyBeaver/SwiftyBeaver.binary", // <-- Using CACHE (xcframework)
      "Moya/Moya.binary",
      "Alamofire/Alamofire.binary",
      "core-utils/DebugKit",              // <-- Using SOURCE CODE
      "core-utils/ResourceKit",
      "core-utils/Swizzler",
      "ios-maps-sdk/GoogleMapsTarget.binary",
      "ios-maps-sdk/GoogleMaps.binary",
      "SDWebImage/SDWebImage.binary",
      "SnapKit/SnapKit.binary"
    ],
    "EXTests.xccache": []
  }
}
"""
```
This JSON describes the integrated dependencies:
- A target suffixed with `.binary` (ex. `SwiftyBeaver/SwiftyBeaver.binary`) means its cache is available and is integrated in favor of source code.
- A target not ending with `.binary` (ex. `core-utils/Swizzler`) means it's integrated using source code.

In Xcode build log, you should see xcframeworks of the cache-hit targets being processed by Xcode.
<img src="res/xcode_process_xcframeworks.png" width="580px">

### Viewing Cachemap Visualization

Whenever cache is integrated into your project (via `xccache`, `xccache use`, or `xccache build`), the tool generates an html (at `xccache/cachemap.html`) that visualizes the cache dependencies. Open this html in your browser to better understand the depenencies in your project.

<img src="res/cachemap.png" width="600px">

### Switching Between Binary and Source Code

Switching between binary and source code forms can be done easily with a simple action.

To use source code of a target instead of its binary, simply **remove the `.binary` suffix**. For example, changing from `SwiftyBeaver/SwiftyBeaver.binary` to `SwiftyBeaver/SwiftyBeaver` results in this target being compiled with sources. This allows developers to jump between the two modes without the hassle of changing the xcodeproj files.

> [!IMPORTANT]
> After modifying the JSON in Package.swift, remember to trigger resolving package versions again (File -> Packages -> Resolve Package Versions). Xcode doesn't automatically reload packages upon changes in this file.

<video src="https://github.com/user-attachments/assets/61095ed4-b221-405d-b3e9-5f6c9218f58c"></video>

### Rolling Back Cache

Run `xccache rollback`. This returns the project to the original state where product dependencies are specified in the *Link Binary With Libraries* section and `<Target>.xccache` is removed from this section.
> [!WARNING]
> Well, you're advised not to use this action if not necessary.\
> If you want to use source code entirely, consider *purging the cache* instead.

## Working With Swift Packages
### Building a Swift Package Target

Packaging a Swift package target as binary is not as easy as it seems, which involves several steps. This tool offers a convenient way to build such a target into an xcframework with just only one step. Check out build options (ex. configuration, sdk, etc.) with `--help`.
```sh
xccache pkg build --target=<Target>
```
