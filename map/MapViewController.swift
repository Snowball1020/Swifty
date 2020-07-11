//
//  ViewController.swift
//  map
//
//  Created by Yuki Miyazawa on 2020-07-09.
//  Copyright © 2020 Yuki Miyazawa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var textFieldForAddress: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var getDirectionButton: UIButton!
    
    var locationManager = CLLocationManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()


       // Annotations - Dictionary
        let locations = [
            ["title": "New York, NY",  "description":"" , "latitude": 40.713054, "longitude": -74.007228],
            ["title": "Chicago, IL",  "description":"",   "latitude": 41.883229, "longitude": -87.632398],
            ["title": "Georgian College, ON", "description":"Our School" ,   "latitude": 44.4074, "longitude": -79.6567],
        ]
        
        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.title = location["title"] as? String
            annotation.subtitle = location["description"] as? String
            annotation.coordinate = CLLocationCoordinate2D(latitude: location["latitude"] as! Double, longitude: location["longitude"] as! Double)
            mapView.addAnnotation(annotation)
        }
         
        //Display the user location (Default is: Apple HQ)
        mapView.showsUserLocation = true
        
        //Set up MapKit
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
    }
    
    //When Get Direction button tapped
    @IBAction func getDirectionTapped(_ sender: Any) {
        getAddress()
    }
    
    //getAddres function converts Text that user typed in to Coordinate
    func getAddress(){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textFieldForAddress.text!) { (placemark, error) in
            guard let placemark = placemark, let location = placemark.first?.location else{
                print("No Location Found")
                return
            }
//            print(location)
            self.mapThis(destinationCord: location.coordinate)
        }
    }
    
    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     //   print("User Location \(locations)")
    }
    
    //mapThis function get the current location and destination, then highlight the route uoto the destination
    func mapThis(destinationCord:CLLocationCoordinate2D){
        let souceCordinate = (locationManager.location?.coordinate)!
        let soucePlacemark = MKPlacemark(coordinate: souceCordinate)
        let destPlacemark = MKPlacemark(coordinate: destinationCord)
        
        let souceItem = MKMapItem(placemark: soucePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = souceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: destinationRequest)
        direction.calculate { (response, error) in
            guard let response = response else{
                if let error = error {
                    print("Could not find the way to get there (Maybe the destination is somewwhere you can not reach by car)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

            
        }
                
    }
    
    //
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
}

//38.897957
//-77.036560
