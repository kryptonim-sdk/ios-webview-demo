import SwiftUI

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
    .onReceive(NotificationCenter.default.publisher(for: Kryptonim.notification)) { notification in
      guard let url = notification.object as? URL else { return }
      let urlString = url.absoluteString
      if urlString == "kryptonim-demo://kryptonim.purchase.success" {
        print("SUCCESS")
      } else if urlString == "kryptonim-demo://kryptonim.purchase.failure" {
        print("FAILURE")
      }
    }
  }
  
  private func buildKryptonimUrl() -> URL {
    var configuration = Kryptonim.Configuration(url: "https://intg-kryptonim.devone.cc/iframe-form")
    configuration.amount = "0.5"
    configuration.currency = "USDC"
    return configuration.buildUrlWithParameters()
  }

}

#Preview {
  DemoView()
}

