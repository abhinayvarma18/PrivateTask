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
    lazy var destinationMarker:GMSMarker = {
        let destination = GMSMarker()
        let image = UIImage(named:mapIconImageName)
        destination.icon = image
        destination.map = self.mapView
        destination.appearAnimation = GMSMarkerAnimation.none
      return destination
    }()
    var mapGesture:Bool = false
    let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Map initiation code
        self.mapView?.delegate = self
        
        self.mapView.isUserInteractionEnabled = true
        
        uilgr.minimumPressDuration = 2.0
        
        //self.mapView.add (uilgr)
        
        //IOS 9
        self.mapView.addGestureRecognizer(uilgr)
        
        
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        
    }
    
    @objc func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, to: mapView)
            
            mapView.clear()
            destinationMarker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(newCoordinates.x), longitude: CLLocationDegrees(newCoordinates.y))
            destinationMarker.title = "latitude:\(newCoordinates.x)"
            destinationMarker.snippet = "longitude:\(newCoordinates.y)"
            destinationMarker.map = mapView
            mapView.layoutIfNeeded()
        }
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
        destinationMarker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        destinationMarker.title = "latitude:\(latitude)"
        destinationMarker.snippet = "longitude:\(longitude)"
        destinationMarker.map = mapView
        mapView.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - CLLocationManagerDelegate
extension IMHMainViewController: CLLocationManagerDelegate,GMSMapViewDelegate {
    
    //MARK:Location Access Request and update initial marker on current location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: ZoomConstant, bearing: BearingConstant, viewingAngle: ViewingAngleConstant)
            self.drawMarker(location.coordinate.latitude, location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    //MARK:Map View Movement And Updation Of Center Marker
    // Camera change Position this methods will call every time
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("didchangedcalled")
        var destinationLocation = CLLocation()
        var destinationCoordinate:CLLocationCoordinate2D?
        destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
        destinationCoordinate = destinationLocation.coordinate
        updateLocationoordinates(coordinates: destinationCoordinate!)
    }
    //update location of existing marker on map
    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        destinationMarker.position =  coordinates
        _ = self.mapView(mapView, didTap: destinationMarker)
        CATransaction.commit()
    }
    
    
    //MARK:Tap and LongPress Methods
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //you can handle zooming and camera update here
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        marker.title = "latitude: \(destinationMarker.position.latitude)"
        marker.snippet = "longitude: \(destinationMarker.position.longitude)"
        mapView.selectedMarker?.snippet = marker.snippet
        mapView.selectedMarker?.title = marker.title
        mapView.selectedMarker = marker
        CATransaction.commit()
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
//        mapView.clear()
        destinationMarker.position = coordinate
        destinationMarker.title = "latitude:\(coordinate.latitude)"
        destinationMarker.snippet = "longitude:\(coordinate.longitude)"
        destinationMarker.map = mapView
        self.mapView.camera = GMSCameraPosition(target: coordinate, zoom: ZoomConstant, bearing: BearingConstant, viewingAngle: ViewingAngleConstant)
    }
    
}

