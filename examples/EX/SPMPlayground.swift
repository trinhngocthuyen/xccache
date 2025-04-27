import SwiftyBeaver
import Moya
import Alamofire
import DebugKit
import ResourceKit
import Swizzler
import GoogleMaps
import SDWebImage
import KingfisherWebP

struct Playground {
  init() {
    print(SwiftyBeaver.self)        // SwiftyBeaver
    print(MoyaError.self)           // Moya
    print(AFError.self)             // Alamofire
    print(DebugKit.self)            // core-utils
    print(Swizzler.self)            // core-utils
    print(ResourceKit.self)         // core-utils
    print(GMSAddress.self)          // GoogleMaps
    print(SDImageCacheOptions.self) // SDWebImage)
    print(WebPProcessor.self)       // KingfisherWebP
  }
}
