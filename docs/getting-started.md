[< Knowledge Base](README.md)

# 🚀 Getting Started

<details>
<summary>Table of Contents</summary>

- [Quick Start](#quick-start)
- [Understanding the Tool](#understanding-the-tool)
- [Working With Cache](#working-with-cache)
  - [Building Cache](#building-cache)
  - [Using Cache](#using-cache)
  - [Viewing Cachemap Visualization](#viewing-cachemap-visualization)
  - [Switching Between Binary and Source Code](#switching-between-binary-and-source-code)
  - [Rolling Back Cache](#rolling-back-cache)
  - [Multiplatform Cache](#multiplatform-cache)
  - [Per-Configuration Cache](#per-configuration-cache)
  - [Sharing Remote Cache](#sharing-remote-cache)
- [Working With Swift Packages](#working-with-swift-packages)
  - [Building a Swift Package Target](#building-a-swift-package-target)
- [Managing Dependencies](#managing-dependencies)
  - [Adding a Dependency](#adding-a-dependency)
  - [Removing a Dependency](#removing-a-dependency)
- [Configuration](#configuration)
</details>

## Quick Start

Simply run `xccache` under the root directory of the project. Then, you should see:
- **`xccache.lock`**: containing the info about packages in the project alongside the products being used. You're recommended to track this file in git.
- The `xccache` directory: containing build intermediates for the integration. This directory is similar to the `Pods` directory (in CocoaPods). Do NOT remove this directory. Instead, please ignore it from git.

> [!NOTE]
> If you see product dependencies of a Swift package being removed from the *Link Binary With Libraries* section, it is expected.\
> In return, this plugin adds another `<Target>.xccache` product which includes your product dependencies.

<img src="res/umbrella_product_dependencies.png" width="580px">

## Understanding the Tool
Read the overview: [here](overview.md).

Following are some docs about what happens under the hood:
- [Packaging as an xcframework](under-the-hood/packaging-as-xcframework.md)
- [Ensuring `Bundle.module` When Accessing Resources](under-the-hood/ensuring-bundle-module.md)
- [Macro as Binary](under-the-hood/macro-as-binary.md)

## Working With Cache

> [!TIP]
> Use the `--help` option in the CLI to explore available (sub)commands and their supported options/flags.

### Building Cache

To build cache of Swift packages, run `xccache build`.

By default, the tool only builds cache-missed targets. To build specify targets, specify them in the arguments, for example:
```sh
xccache build SwiftyBeaver SDWebImage
```
The prebuilt xcframeworks are available under `xccache/binaries`, following the structure as below:
```
xccache /-- binaries /-- SwiftyBeaver /-- SwiftyBeaver-<checksum>.xcframework
                                      |-- SwiftyBeaver.xcframework
```
To build dependencies if cache-missed, use the `--recursive` option. For example, to build cache of `FirebaseCrashlytics` (including its dependencies):
```sh
xccache build FirebaseCrashlytics --recursive
```

### Using Cache
Run `xccache use` or simply `xccache` to integrate cache to the project. Note that cache, after being built with `xccache build`, is automatically integrated to the project. You don't need to run `xccache use` in this case.

In the package manifest (Package.swift) of the umbrella package (named xccache), you should see a generated JSON string as follows:
```swift
let JSON = """
{
  "EXTests.xccache": [],
  "EX.xccache": [
    "core-utils/DebugKit",           // <-- Using CACHE (xcframework)
    "core-utils/ResourceKit",
    "core-utils/Swizzler.binary",    // <-- Using SOURCE CODE
    "firebase-ios-sdk/FirebaseCrashlytics.binary",
    "ios-maps-sdk/GoogleMaps.binary",
    "KingfisherWebP/KingfisherWebP.binary",
    "Moya/Moya.binary",
    "SDWebImage/SDWebImage.binary",
    "SnapKit/SnapKit-Dynamic.binary",
    "SwiftyBeaver/SwiftyBeaver.binary"
  ]
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

<img src="res/cachemap.png" width="700px">

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
> If you want to use source code entirely, consider *purging the cache* (`xccache cache clean --all`) instead.

### Multiplatform Cache

An xcframework can include slices for multiple platforms. Use the `--sdk` option to specify the sdk (iphonesimulator, iphoneos, etc.) to use. If not specified, it uses the [`default_sdk`](configuration#default_sdk) configuration in the config if exist. Otherwise, it defaults to `iphonesimulator`.

When building cache, the tool **merges existing slices with the newly created** to reduce unnecessary builds for multiplatform support. This behavior is controlled by the `--merge-slices` flag (default: `true`). To disable it, ie. replacing the existing xcframework if exists, specify `--no-merge-slices`.

```sh
xccache build SwiftyBeaver --sdk=iphonesimulator
xccache build SwiftyBeaver --sdk=iphoneos # <-- here, xcframework contains both sdks: iphonesimulator and iphoneos

xccache build SwiftyBeaver --sdk=macos --no-merge-slices # <-- here, xcframework contains only macos sdk
```

### Per-Configuration Cache

Cache of different build configurations (debug/release) is hosted in separate directories `~/.xccache/<configuration>`. The build configuration is defaulted to `debug`. To specify a different build configuration, use the `--config` argument.
```sh
xccache build SwiftyBeaver --config=release
xccache --config=release
```

### Sharing Remote Cache
Cache can be shared among team with remote cache, using Git or S3.
```sh
xccache remote pull # <-- pull cache
xccache remote push # <-- push cache
```

Refer to the [remote configuration](configuration#remote) for the setup.

## Working With Swift Packages
### Building a Swift Package Target

Packaging a Swift package target as binary is not as easy as it seems, which involves several steps. This tool offers a convenient way to build such a target into an xcframework with just only one step. Check out build options (ex. configuration, sdk, etc.) with `--help`.
```sh
xccache pkg build <Target>
```

## Managing Dependencies
### Adding a Dependency

To add a new package, or new product dependencies (in the *Link Binary With Libraries* section), you can just add it the way you usually do (via Xcode), then just run `xccache` again.
After that, you should see the changes reflected in xccache.lock.

<img src="res/lockfile_add_new_dep.png" width="500px">

Alternatively, you can directly modify the lockfile with the changes above, and run `xccache`. This way, you can avoid modifying the xcodeproj file.

### Removing a Dependency

Just directly update the lockfile:
- Remove it from the dependencies section
- Remove it from the packages section if not in use

```json
  ...
  "dependencies": {
    "EX": [
      "Moya/Moya",
      "SwiftyBeaver/SwiftyBeaver", # <-- Remove this if not in use
      ...
    ]
  },
  "packages": [
    { # <-- Remove this if not in use
      "repositoryURL": "https://github.com/SwiftyBeaver/SwiftyBeaver",
      "requirement": {
        "kind": "upToNextMajorVersion",
        "minimumVersion": "2.1.1"
      }
    }
    ...
  ]
```

## Configuration
Check out this doc: [Configuration](configuration.md)
