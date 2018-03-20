//
//  EventAddressViewController.swift
//  My-Julia
//
//  Created by GCO on 5/4/17.
//  Copyright © 2017 GCO. All rights reserved.
//

import UIKit
import MapKit

class EventAddressViewController: UIViewController {
  
    @IBOutlet weak var mapView: MKMapView!
    var addressStr : String!
    lazy var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.title = addressStr
    }

    override func viewWillAppear(_ animated: Bool) {
        //Get latitude and longitude from address
        self.getEventAddressLocation()
    }

    func getEventAddressLocation() {
        
        // Geocode Address String
//        geocoder.geocodeAddressString(address) { (placemarks, error) in
//            // Process Response
//            self.processResponse(withPlacemarks: placemarks, error: error)
//        }
        
        LocationManager.sharedInstance.getReverseGeoCodedLocation(address: addressStr, completionHandler: { (location:CLLocation?, placemark:CLPlacemark?, error:NSError?) in
            
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            
            if placemark != nil {
                let location = placemark?.location
                
                if let location = location {
                    let coordinate = location.coordinate
                    print(" Coordinate ","\(coordinate.latitude), \(coordinate.longitude)")
                    
                    let annotation: MKPointAnnotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = self.addressStr
                    self.mapView.addAnnotation(annotation)

                    let latDelta: CLLocationDegrees = 0.01
                    let lonDelta: CLLocationDegrees = 0.01
                    let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
                    let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
                    self.mapView.setRegion(region, animated: false)

                } else {
                    print("No Matching Location Found")
                }
                return
            }
            else {
                print("Location can't be fetched")
            }
        })
    }

    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        
        if  error != nil {
            
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                print("Coordinate ","\(coordinate.latitude), \(coordinate.longitude)")
            } else {
            }
        }
    }

    func alertMessage(message:String,buttonText:String,completionHandler:(()->())?) {
        let alert = UIAlertController(title: "Location", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { (action:UIAlertAction) in
            completionHandler?()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
