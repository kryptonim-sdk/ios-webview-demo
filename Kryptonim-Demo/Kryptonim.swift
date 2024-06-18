import Foundation

struct Kryptonim {

  static let notification = Notification.Name(rawValue: "kryptonim.result")

  static func sendNotification(url: URL) {
    if
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      components.scheme == "kryptonim-demo"
    {
      let notification = Notification(name: Kryptonim.notification, object: url, userInfo: nil)
      NotificationCenter.default.post(notification)
    }
  }

  struct Configuration {
    var url: String
    var amount: String?
    var currency: String?

    func buildUrlWithParameters() -> URL {
      var urlComponents = URLComponents(string: url)!

      var queryItems: [URLQueryItem] = []
      queryItems.appendIfNotNil(buildQueryItem(name: "amount", value: amount))
      queryItems.appendIfNotNil(buildQueryItem(name: "currency", value: currency))
      if !queryItems.isEmpty { urlComponents.queryItems = queryItems }

      return urlComponents.url!
    }
   
    private func buildQueryItem(name: String, value: String?) -> URLQueryItem? {
      guard let value = value else { return nil }
      return .init(name: name, value: value)
    }
  }

}
