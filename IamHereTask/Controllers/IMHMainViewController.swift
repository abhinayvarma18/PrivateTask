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
/////roundf( use
class IMHMainViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    lazy var destinationMarker:GMSMarker = {
        let destination = GMSMarker()
        let image = UIImage(named:MapIconImageName)
        destination.icon = image
        destination.map = self.mapView
        destination.appearAnimation = GMSMarkerAnimation.none
      return destination
    }()
    var mapGesture:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Map initiation code
        self.mapView?.delegate = self
        
        self.mapView.isUserInteractionEnabled = true
        
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
        self.updateDestinationMarker(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
    //MARK:whenever draw function is called
    func updateDestinationMarker(_ coordinate:CLLocationCoordinate2D) {
        //mapView.clear()
        destinationMarker.position = coordinate
        self.destinationMarker.title = "latitude:\(coordinate.latitude)"
        self.destinationMarker.snippet = "longitude:\(coordinate.longitude)"
        self.destinationMarker.map = mapView
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
        CATransaction.setAnimationDuration(AnimationTime)
        destinationMarker.position =  coordinates
        if (self.mapView.selectedMarker?.isTappable ?? false) {
            _ = self.mapView(mapView, didTap: destinationMarker)
        }
        CATransaction.commit()
    }
    
    
    //MARK:Tap and LongPress Methods
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //you can handle zooming and camera update here
        
        //CATransaction.begin()
        //CATransaction.setAnimationDuration(1.0)
        marker.title = "latitude: \(destinationMarker.position.latitude)"
        marker.snippet = "longitude: \(destinationMarker.position.longitude)"
        mapView.selectedMarker?.snippet = marker.snippet
        mapView.selectedMarker?.title = marker.title
        mapView.selectedMarker = marker
        //CATransaction.commit()
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
//        mapView.clear()
        CATransaction.begin()
        CATransaction.setAnimationDuration(AnimationTime)
        destinationMarker.position = coordinate
        destinationMarker.title = "latitude:\(coordinate.latitude)"
        destinationMarker.snippet = "longitude:\(coordinate.longitude)"
        destinationMarker.map = mapView
        self.mapView.camera = GMSCameraPosition(target: coordinate, zoom: ZoomConstant, bearing: BearingConstant, viewingAngle: ViewingAngleConstant)
        CATransaction.commit()
    }
    
}

//let customMarker = CustomAnnotationView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.white, tag: customMarkerView.tag)

//marker.iconView = customMarker



