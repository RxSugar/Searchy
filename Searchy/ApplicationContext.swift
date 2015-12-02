import Foundation

struct ApplicationContext {
    let networkLayer = URLSessionNetworkLayer()
    let imageProvider:ImageProvider
    
    init() {
        imageProvider = ImageProvider(networkLayer: networkLayer)
    }
}