[< Knowledge Base](README.md)

# Overview
## Cache as xcframeworks
<!-- A typical way to use a product of a package (for ex. `pkg/A`) is to add it to the *Link Binary with Libraries* section, and let Xcode takes care of the rest. When compiling the project, such product dependencies are compiled alongside and then later be linked to the consumer's binary. -->

The `xccache` CLI provides some functionalities to build a Swift package target into an xcframework (for more details, check out the [Under the Hood](#under-the-hood) section). This xcframework can be used in the project in many ways. See more: [Declare a binary target in the package manifest](https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages#Declare-a-binary-target-in-the-package-manifest).

The tool manages a special *umbrella package* (at: xccache/packages/umbrella) to manipulate cache dependencies in the project. In case of cache hit, it replaces the original dependency (with source code) with the corresponding prebuilt dependency.

### Cache Fallback
In case of cache miss, it automatically uses the original dependency.

### Cache Validation Model
(1) **Checksum-based**: An xcframework is associated with a checksum of its package. If the checksum does not match -> cache miss.

(2) **Cache miss propagation**: Cache miss in a target results in cache miss in its dependents. For example, if `pkg/A` depends on `pkg/X` and `pkg/X` is cache-missed, then `pkg/A` is also a cache miss regardless of whether there exist a binary (xcframework) that matches the checksum.

## Under the Hood
- [Packaging as an xcframework](under-the-hood/packaging-as-xcframework.md)
