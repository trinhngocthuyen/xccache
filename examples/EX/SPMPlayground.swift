import SwiftyBeaver
import Moya
import Alamofire

struct Playground {
  init() {
    print(SwiftyBeaver.self) // SwiftyBeaver
    print(MoyaError.self) // Moya
    print(AFError.self) // Alamofire
  }
}
