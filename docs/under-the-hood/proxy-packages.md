[< Knowledge Base](../README.md)

# Under the Hood: Proxy Packages

The introduction of proxy packages were highlighted in this discussion: [Cache Re-design (v2)](https://github.com/trinhngocthuyen/xccache/discussions/83#discussion-8346379)

Each resolved package has an accompanying package called proxy package. This package has a very similar manifest to the resolved package. Both share the same checkout sources. The proxy package manifest is derived from its counterpart.

```
umbrella
├── .build/checkouts
    ├── SwiftyBeaver / -- Package.swift
    │     ├── Package.swift
    │     ├── Sources
    │
    └── Alamofire

proxy
├── .proxies
    ├── SwiftyBeaver
    │     ├── Package.swift (updated)
    │     ├── src (symlink to umbrella/.build/checkouts/SwiftyBeaver)
    │
    └── Alamofire
```
Dependencies of a proxy package are proxy packages

Take Moya as an example. It depends on Alamofire, a remote git repo as follows.
```swift
let package = Package(
  name: "Moya",
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0"))
  ]
)
```
When translating to the proxy model, the manifest should be like this:
```swift
let package = Package(
  name: "Moya",
  dependencies: [
    .package(path: "../Alamofire")
  ]
)
```
Proxy packages reside adjacent to each other in the directory structure.
```
umbrella

proxy
├── .proxies
│   ├── Alamofire
│   │     └── Package.swift
│   ├── Moya
│   │     └── Package.swift
│   └── SwiftyBeaver
│         └── Package.swift
│
└── Package.swift (to be integrated to the project)
```

When having cache, the targets declaration in the manifest is altered to use the xcframework.
```swift
let package = Package(
  name: "Alamofire",
  products: [
    .library(
      name: "Alamofire",
      targets: ["Alamofire"]
    ),
  ],
  targets: [
    .binaryTarget( // <-- HERE
      name: "Alamofire",
      path: "../../../binaries/Alamofire/Alamofire.xcframework"
    )
  ]
)
```
