import SwiftUI

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
