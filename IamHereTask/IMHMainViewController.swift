//
//  ViewController.swift
//  MainHuNa
//
//  Created by ABHINAY on 09/04/18.
//  Copyright © 2018 ABHINAY. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class IMHMainViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var destinationMarker:GMSMarker!
    var mapGesture:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Map initiation code
        self.mapView?.delegate = self
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.isMyLocationEnabled = true
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapView?.isUserInteractionEnabled = false
        self.locationManager.stopUpdatingLocation()
    }
    
    func drawMarker(_ latitude:CLLocationDegrees, _ longitude: CLLocationDegrees) {
        mapView.clear()
        destinationMarker = GMSMarker()
        destinationMarker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        destinationMarker.title = "latitude:\(latitude) and longitude:\(longitude)"
        destinationMarker.snippet = "latitude:\(latitude) and longitude:\(longitude)"
        destinationMarker.map = mapView
        mapView.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


// MARK: - CLLocationManagerDelegate
extension IMHMainViewController: CLLocationManagerDelegate,GMSMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
            self.drawMarker(location.coordinate.latitude, location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {
        if destinationMarker == nil
        {
            destinationMarker = GMSMarker()
            destinationMarker.position = coordinates
            let image = UIImage(named:"map-marker-icon")
            destinationMarker.icon = image
            destinationMarker.map = self.mapView
            destinationMarker.appearAnimation = GMSMarkerAnimation.none
        }
        else
        {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            destinationMarker.position =  coordinates
            CATransaction.commit()
        }
    }
    
    // Camera change Position this methods will call every time
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("didchangedcalled")
        var destinationLocation = CLLocation()
        var destinationCoordinate:CLLocationCoordinate2D?
        destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
        destinationCoordinate = destinationLocation.coordinate
        updateLocationoordinates(coordinates: destinationCoordinate!)
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //you can handle zooming and camera update here
        marker.title = "latitude: \(marker.position.latitude)"
        marker.snippet = "longitude: \(marker.position.longitude)"
        mapView.selectedMarker = marker
        return true
    }
}

