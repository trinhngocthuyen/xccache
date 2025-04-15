import SwiftyBeaver
import Moya
import Alamofire
import ResourceKit
import Swizzler
import GoogleMaps
import SDWebImage

struct Playground {
  init() {
    print(SwiftyBeaver.self)        // SwiftyBeaver
    print(MoyaError.self)           // Moya
    print(AFError.self)             // Alamofire
    print(Swizzler.self)            // core-utils
    print(ResourceKit.self)         // core-utils
    print(GMSAddress.self)          // GoogleMaps
    print(SDImageCacheOptions.self) // SDWebImage
  }
}
