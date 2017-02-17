import UIKit

public enum MapType {
    case satellite
    case scheme
    case hybrid
}

public class YandexMapView: UIWebView, UIWebViewDelegate {
    public var onMapLoaded: (() -> Void)?
    public var onMapError: ((String) -> Void)?
    public var onMarkerClicked: ((Int) -> Void)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        
        start()
    }
    
    public func start() {
        let podBundle = Bundle(for: YandexMapView.self)
        let bundleUrl = podBundle.url(forResource: "YandexMapView", withExtension: "bundle")
        let bundle = Bundle(url: bundleUrl!)!
        let htmlFile = bundle.path(forResource: "MapView", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: .utf8)
        loadHTMLString(html!, baseURL: nil)
    }
    
    public func clear() {
        stringByEvaluatingJavaScript(from: "clear()")
    }
    
    public func showMarker(id: Int, latitude: Double, longitude: Double, title: String) {
        stringByEvaluatingJavaScript(from: "showMarker(\(id), \(latitude), \(longitude), '\(title)')")
    }
    
    public func setMapType(type: MapType) {
        let typeName: String
        switch type {
        case .satellite: typeName = "yandex#satellite"
        case .scheme: typeName = "yandex#map"
        case .hybrid: typeName = "yandex#hybrid"
        }
        stringByEvaluatingJavaScript(from: "setType(\(typeName))")
    }
    
    public func setCenter(latitude: Double, longitude: Double, animated: Bool = false) {
        stringByEvaluatingJavaScript(from: "setCenter(\(latitude), \(longitude), \(animated ? 300 : 0))")
    }
    
    public func setZoom(zoom: Int) {
        stringByEvaluatingJavaScript(from: "setZoom(\(zoom))")
    }
    
    public func setBounds(northWestLat: Double, northWestLong: Double, southEastLat: Double, southEastLong: Double) {
        stringByEvaluatingJavaScript(from: "setBounds(\(northWestLat), \(northWestLong), \(southEastLat), \(southEastLong))")
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        onMapError?("Не удалось загрузить карту")
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print(request)
        
        guard request.url != nil else {
            return true
        }
        
        let components = NSURLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        
        let host = components.host
        let scheme = components.scheme
        let queryItems = components.queryItems
        
        
        if host == "yandex.ru" {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        
        guard scheme == "callback" else {
            return true
        }
        
        switch host! {
        case "mapLoaded":
            onMapLoaded?()
        case "mapUnavailable":
            onMapError?("Карта недоступна")
        case "markerClicked":
            if let paramValue = queryItems?[0].value {
                if let markerId = Int(paramValue) {
                    onMarkerClicked?(markerId)
                }
            }
        default: break
        }
        
        return false
    }
}
