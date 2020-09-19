//
//  ViewController.swift
//  LocationUse
//
//  Created by 배기훈 on 2020/09/14.
//  Copyright © 2020 배기훈. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    //위치 정보 사용을 위한 인스턴스 생성
    var locationManager: CLLocationManager = CLLocationManager()
    //시작 위치를 지정할 인스턴스 변수 생성
    var startLocation: CLLocation!

    
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    @IBOutlet weak var lblAltitude: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBAction func locationInformation(_ sender: Any) {
        let btn = sender as! UIButton
        if(btn.title(for:.normal) == "위치정보수집시작"){
            locationManager.startUpdatingLocation()
            locationManager.pausesLocationUpdatesAutomatically = true
            btn.setTitle("위치정보수집종료", for: .normal)
        }else{
            locationManager.stopUpdatingLocation()
            btn.setTitle("위치정보수집시작", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
    }


}

extension ViewController : CLLocationManagerDelegate{
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          
          let latestLocation: CLLocation = locations[locations.count - 1]
          
          lblLatitude.text = String(format: "%.4f", latestLocation.coordinate.latitude)
          lblLongitude.text = String(format: "%.4f",latestLocation.coordinate.longitude)
          lblAltitude.text = String(format: "%.4f", latestLocation.altitude)
          if startLocation == nil {
              startLocation = latestLocation
          }
          
          let distanceBetween: CLLocationDistance = latestLocation.distance(from: startLocation)
          
          lblDistance.text = String(format: "%.2f", distanceBetween)
          
          print("Latitude = \(latestLocation.coordinate.latitude)")
          print("Longitude = \(latestLocation.coordinate.longitude)")
          
      }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error.localizedDescription)
    }
}

