[< Documentation](README.md)

# Getting Started

## Quick Start

Simply run `xccache` under the root directory of the project. Then, you should see:
- **`xccache.lock`**: containing the info about packages in the project alongside the products being used.
- The `xccache` directory: containing build intermediates for the integration. This directory is similar to the `Pods` directory (in CocoaPods). Do NOT remove this directory. Instead, please ignore it from git.

> [!NOTE]
> If you see product dependencies of a Swift package being removed from the "Link Binary With Libraries" section, it is expected.
> In return, this plugin adds another `<Target>.xccache` product which includes your product dependencies

## Overview
TBU
