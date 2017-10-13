//
//  YandexMapView2.swift
//  Pods-YandexMapView_Example
//
//  Created by Evgeniy Safronov on 13.10.17.
//

import Foundation
import WebKit

public class YandexMapWebKitView: UIView, WKNavigationDelegate {
    public var onMapLoaded: (() -> Void)?
    public var onMapError: ((String) -> Void)?
    public var onMarkerClicked: ((Int) -> Void)?
    
    private var webView: WKWebView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: frame, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        addSubview(webView)
    }
    
    public func start() {
        let podBundle = Bundle(for: YandexMapView.self)
        let bundleUrl = podBundle.url(forResource: "YandexMapView", withExtension: "bundle")
        let bundle = Bundle(url: bundleUrl!)!
        let htmlFile = bundle.path(forResource: "MapView", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: .utf8)
        webView.loadHTMLString(html!, baseURL: nil)
    }
    
    public func clear() {
        webView.evaluateJavaScript("clear()", completionHandler: nil)
    }
    
    public func showMarker(id: Int, latitude: Double, longitude: Double, iconContent: String = "", baloonTitle: String = "", baloonBody: String = "", preset: String = "islands#icon") {
        let js = "showMarker(\(id), \(latitude), \(longitude), '\(iconContent)', '\(baloonTitle)', '\(baloonBody)', '\(preset)')"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    public func setMapType(type: MapType) {
        let typeName: String
        switch type {
        case .satellite: typeName = "'yandex#satellite'"
        case .scheme: typeName = "'yandex#map'"
        case .hybrid: typeName = "'yandex#hybrid'"
        }
        webView.evaluateJavaScript("setType(\(typeName))", completionHandler: nil)
    }
    
    public func setCenter(latitude: Double, longitude: Double, animated: Bool = false) {
        let js = "setCenter(\(latitude), \(longitude), \(animated ? 300 : 0))"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    public func setZoom(zoom: Int) {
        webView.evaluateJavaScript("setZoom(\(zoom))", completionHandler: nil)
    }
    
    public func setBounds(northWestLat: Double, northWestLong: Double, southEastLat: Double, southEastLong: Double) {
        let js = "setBounds(\(northWestLat), \(northWestLong), \(southEastLat), \(southEastLong))"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onMapError?("Не удалось загрузить карту")
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let request = navigationAction.request
        
        guard request.url != nil else {
            decisionHandler(.allow)
            return
        }
        
        let components = NSURLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        
        let host = components.host
        let scheme = components.scheme
        let queryItems = components.queryItems
        
        
        if host == "yandex.ru" {
            UIApplication.shared.openURL(request.url!)
            decisionHandler(.cancel)
            return
        }
        
        guard scheme == "callback" else {
            decisionHandler(.allow)
            return
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
        
        decisionHandler(.cancel)
    }
}
