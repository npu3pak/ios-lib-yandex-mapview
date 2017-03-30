//
//  ViewController.swift
//  YandexMapView
//
//  Created by Евгений Сафронов on 01/23/2017.
//  Copyright (c) 2017 Евгений Сафронов. All rights reserved.
//

import UIKit
import YandexMapView

class ViewController: UIViewController {
    @IBOutlet var mapView: YandexMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.onMapLoaded = onMapLoaded
    }
    
    func onMapLoaded() {
        mapView.showMarker(id: 0, latitude: 54.632389, longitude: 39.749153, baloonTitle: "Заголовок", baloonBody: "Комментарий", preset: "islands#icon")
        mapView.setCenter(latitude: 54.632389, longitude: 39.749153)
        mapView.setZoom(zoom: 14)
    }
}

