[< Knowledge Base](../README.md)

# Under the Hood: Packaging as an xcframework

The steps to create an xcframework out of a collection of Swift sources are:
- (1) Creating a framework slice (ex. for iOS iphone simulator - `arm64-apple-ios-simulator`). The result of this step is a framework bundle, ex. `SwiftyBeaver.framework`.
- (2) Creating an xcframework out of framework slices using `xcodebuild -create-xcframework`.

There are some tricky actions in step (1) so that the framework bundle meets requirements in step (2). For example, in case of Swift frameworks, `xcodebuild -create-xcframework` requires a swiftinterface in the swiftmodule.

## Creating a Framework Slice

By default, building a Swift package target (with `swift build`) does not produce a `.framework` bundle. We have to package it outselve from .o files, headers, swiftmodules, etc.

```
A.framework
  |-- A (binary)
  |-- Info.plist
  |
  |-- Headers /
  |-- Modules /
        |-- module.modulemap
        |-- A.swiftmodule /
              |-- arm64-apple-ios-simulator.swiftinterface
              |-- arm64-apple-ios-simulator.swiftdoc
              ...
```
Steps to create a framework:
- (1) Run `swift build --target A ...` to build the target. Build artifacts are stored under `.build/debug`.
- (2) Create the framework binary using `libtool` from `.o` files in `.build/debug/A.build`:
```sh
libtool -static -o A.framework/A .build/debug/A.build/**/*.o
```
- (3) Copying swiftmodules & swiftinterfaces in `.build/debug/A.build` and `.build/debug/Modules` to `A.framework/Modules`.\
Also, creating the modulemap `module.modulemap` under `A.framework/Modules` so that this framework is visible to ObjC code.
- (4) Copying headers (if any) to `A.framework/Headers`.
- (5) Copying the resource bundle (if any) (ex. in `.build/debug/A_A.bundle`) to the framework bundle.

## Creating an xcframework from Framework Slices

```sh
xcodebuild -create-xcframework \
  -framework arm64-apple-ios-simulator/SwiftyBeaver.framework \
  -framework arm64-apple-ios/SwiftyBeaver.framework \
  -output SwiftyBeaver.xcframework
```
