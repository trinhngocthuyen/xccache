import SwiftyBeaver
import Moya
import Alamofire
import CoreUtils_Wrapper
import DebugKit
import ResourceKit
import Swizzler
import DisplayKit
import GoogleMaps
import SDWebImage
import KingfisherWebP
import FirebaseCrashlytics
import FacebookLogin
import Wizard

func swift_playground() {
  print(SwiftyBeaver.self)        // SwiftyBeaver
  print(MoyaError.self)           // Moya
  print(AFError.self)             // Alamofire
  print(DebugKit.self)            // core-utils
  print(CoreUtils_Wrapper.self)   // core-utils
  print(Swizzler.self)            // core-utils
  print(ResourceKit.self)         // core-utils
  print(DisplayKit.self)          // core-utils
  print(GMSAddress.self)          // GoogleMaps
  print(SDImageCacheOptions.self) // SDWebImage)
  print(WebPProcessor.self)       // KingfisherWebP
  print(CrashlyticsReport.self)   // FirebaseCrashlytics
  print(LoginResult.self)         // FacebookLogin
  print(FBLoginButton.self)       // FBSDKLoginKit
}

func macro_playground() {
  print(#hexColor(0xff0000))
}

func playground() {
  swift_playground()
  objc_playground()
  macro_playground()
}
