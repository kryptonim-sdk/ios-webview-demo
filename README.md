# Kryptonim integration via browser

This example demonstrates how to implement Kryptonim in your iOS app using a browser (SafariViewController). The documentation covers both SwiftUI and UIKit, though the demo app is in SwiftUI. For integrating Kryptonim using the SDK (recommended), check [here](https://github.com/kryptonim-sdk/ios).

Full API documentation can be found [here](https://www.kryptonim.com/api-documentation).

## Steps

1. Create URL with desired parameters and pass it to SafariViewController.
2. Show SafariViewController.
3. Optionally handle callback.

## Details

### Build URL
You need to build a URL with the desired parameters for the transaction. Users won't need to manually enter this information during the purchasing process, such as wallet address or fiat currency amount. All parameters can be found [here](https://www.kryptonim.com/api-documentation).

```swift
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

extension Array {
  mutating func appendIfNotNil(_ element: Element?) {
    if let element = element {
      self.append(element)
    }
  }
}
```

### Open SafariViewController
Next, you need to show `SFSafariViewController` to user.

##### SwiftUI
```swift
struct DemoView: View {
  @State private var showSafari = false

  var body: some View {
    Button {
      self.showSafari = true
    } label: {
      Text("Open Kryptonim")
    }
    .fullScreenCover(isPresented: $showSafari) {
      SafariView(url: buildKryptonimUrl())
    }
  }
  
  private func buildKryptonimUrl() -> URL {
    var configuration = Kryptonim.Configuration(url: "https://intg-kryptonim.devone.cc/iframe-form")
    configuration.amount = "0.5"
    configuration.currency = "USDC"
    return configuration.buildUrlWithParameters()
  }
```

##### UIKit
```swift
class ViewController: UIViewController {
  private let button = UIButton()
    
    override func viewDidLoad() {
      super.viewDidLoad()

      button.setTitle("Open Kryptonim", for: .normal)
      button.addTarget(self, action: #selector(openKryptonim), for: .touchUpInside)
      button.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(button)
        
      NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ])
    }

    private func openKryptonim() {
      var configuration = Configuration(url: "https://intg-kryptonim.devone.cc/iframe-form")
      configuration.amount = "0.5"
      configuration.currency = "USDC"

      let url = configuration.buildUrlWithParameters()
      let safariVC = SFSafariViewController(url: url)
      present(safariVC, animated: true)
  }
}
```

### Handle callback
If you want to take action after the purchase is finished (either success or failure), you can use the successUrl and failureUrl parameters when building the URL. You need to construct these URL parameters using your app's URL scheme (details below). Kryptonim will call this URL after the purchase, and you will need to handle it in your app.

##### Register URL scheme
Add your app's URL scheme to `Info.plist`. In the code snippet below, we use `kryptonim-demo` as the URL scheme, so your successUrl and failureUrl parameters should start with `kryptonim-demo://`. In the examples below, we use `kryptonim-demo://kryptonim.purchase.success` and `kryptonim-demo://kryptonim.purchase.failure`.
```
<key>CFBundleURLTypes</key>
<array>
  <dict>
  <key>CFBundleTypeRole</key>
  <string>Editor</string>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>kryptonim-demo</string>
  </array>
  </dict>
</array>
```

##### Handle URL open
##### SwiftUI
You can handle this in the `App` file using `.onOpenURL` method and, for example, using `NotificationCenter`.
When Kryptonim tries to open URL defined in the `successUrl` or `failureUrl` parameters, notification will be sent.
```swift
@main
struct Kryptonim_DemoApp: App {
  var body: some Scene {
    WindowGroup {
      DemoView()
        .onOpenURL { url in
          Kryptonim.sendNotification(url: url)
        }
    }
  }
}

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
}
```
Then, you can listen to this notification where you want to take action. For example, in the view that showed `SFSafariViewController` using `.onReceive`.

```swift
.onReceive(NotificationCenter.default.publisher(for: Kryptonim.notification)) { notification in
  guard let url = notification.object as? URL else { return }
  let urlString = url.absoluteString
  if urlString == "kryptonim-demo://kryptonim.purchase.success" {
    print("SUCCESS")
  } else if urlString == "kryptonim-demo://kryptonim.purchase.failure" {
    print("FAILURE")
  }
}
```

##### UIKit
You should handle it in `SceneDelegate` - `func scene(_:, openURLContexts:)`
```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
  guard let url = URLContexts.first?.url else { return }
  Kryptonim.sendNotification(url: url)
}
```
Then, you can listen to this notification where you want to take action.
```swift
NotificationCenter.default.addObserver(forName: rampNotificationName, object: nil, queue: .main) { notification in
  guard let url = notification.object as? URL else { return }
  let urlString = url.absoluteString
  if urlString == "kryptonim-demo://kryptonim.purchase.success" {
    print("SUCCESS")
  } else if urlString == "kryptonim-demo://kryptonim.purchase.failure" {
    print("FAILURE")
  }
}
  ```
