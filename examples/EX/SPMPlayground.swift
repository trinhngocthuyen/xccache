import SwiftyBeaver
import Moya
import Alamofire
import DebugKit
import ResourceKit
import Swizzler
import GoogleMaps
import SDWebImage
import KingfisherWebP
import FirebaseCrashlytics
import CoreUtils_Wrapper

struct Playground {
  init() {
    print(SwiftyBeaver.self)        // SwiftyBeaver
    print(MoyaError.self)           // Moya
    print(AFError.self)             // Alamofire
    print(DebugKit.self)            // core-utils
    print(CoreUtils_Wrapper.self)   // core-utils
    print(Swizzler.self)            // core-utils
    print(ResourceKit.self)         // core-utils
    print(GMSAddress.self)          // GoogleMaps
    print(SDImageCacheOptions.self) // SDWebImage)
    print(WebPProcessor.self)       // KingfisherWebP
    print(CrashlyticsReport.self)   // FirebaseCrashlytics
  }
}
