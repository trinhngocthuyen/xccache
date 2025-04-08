import SwiftyBeaver
import Moya
import Alamofire
import Swizzler

struct Playground {
  init() {
    print(SwiftyBeaver.self) // SwiftyBeaver
    print(MoyaError.self) // Moya
    print(AFError.self) // Alamofire
    print(Swizzler.self) // core-utils
  }
}
