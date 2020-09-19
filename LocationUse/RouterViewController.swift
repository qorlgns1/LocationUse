//
//  RouterViewController.swift
//  LocationUse
//
//  Created by 배기훈 on 2020/09/15.
//  Copyright © 2020 배기훈. All rights reserved.
//
import UIKit
import MapKit

class RouterViewController: UIViewController {
    @IBOutlet weak var routeMapView: MKMapView!
    
    var destination : MKMapItem?
    
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    //Flyover 관련 변수 선언
    let distance: CLLocationDistance = 650
    let pitch: CGFloat = 65
    let heading = 0.0
    var camera: MKMapCamera?

    
    
    @IBAction func animateCamera(_ sender: Any) {
        UIView.animate(withDuration: 20, animations: {
            self.camera!.heading += 100
            self.camera!.pitch = 25
            self.routeMapView.camera = self.camera!
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routeMapView.delegate = self
        routeMapView.showsUserLocation = true

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestLocation()
        
        routeMapView.mapType = .hybridFlyover
            
            var coordinate : CLLocationCoordinate2D?
            if userLocation != nil{
                coordinate = userLocation!.coordinate
            }else{
                coordinate = CLLocationCoordinate2D.init(latitude: 37.4, longitude: 127.027621)
            }
            
            camera = MKMapCamera.init(lookingAtCenter: coordinate!, fromDistance: distance, pitch: pitch, heading: heading)
            routeMapView.camera = camera!

        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension RouterViewController : MKMapViewDelegate,CLLocationManagerDelegate{
    //위치 정보가 업데이트 되었을 때 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //업데이트 된 위치 정보를 저장
        userLocation = locations[0]
        //지도 갱신하는 사용자 정의 메소드 호출
        self.getDirections()
    }
    
    //위치 정보가 업데이트 실패 했을 때 호출되는 메소드
    func locationManager(_ manager: CLLocationManager, didFailWithError error : Error) {
        NSLog(error.localizedDescription)
    }

    //맵 뷰에 출력을 해주는 메소드
    func mapView(_ mapView:MKMapView, rendererFor overlay:MKOverlay)->MKOverlayRenderer{
        
        let renderer = MKPolylineRenderer(overlay:overlay)
        
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 7
        return renderer
    }

    //사용자 정의 메소드
    func showRoute(_ response : MKDirections.Response){
        for route in response.routes{
            //경로 표시
            routeMapView.addOverlay(route.polyline,
                                level:MKOverlayLevel.aboveRoads)
            //움직일 때 마다 경로를 콘솔에 출력
            for step in route.steps{
                NSLog(step.instructions)
            }
        }
        
        if let coordinate = userLocation?.coordinate{
            //사용자 위치 정보를 기준으로 지도를 다시 표시
            let region = MKCoordinateRegion(center:coordinate,
                    latitudinalMeters: 5000,
                    longitudinalMeters:5000)
            //지도에 표시
            routeMapView.setRegion(region, animated: true)
        }
    }
    
    //사용자 정의 메소드
    func getDirections(){
        //요청 객체 생성 - 경로 탐색
        let request = MKDirections.Request()
        //위치 설정
        request.source = MKMapItem.forCurrentLocation()
        
        //목적지 설정
        if let destination = self.destination{
            request.destination = destination
        }
        
        //옵션 설정
        request.requestsAlternateRoutes = false
        
        //요청을 이용해서 경로 객체를 생성
        let directions = MKDirections(request: request)
        //경로 계산하는 메소드 호출
        directions.calculate(completionHandler: {(response, error) in
            if error != nil{
                NSLog("경로 탐색 실패")
            }else{
                //response가 nil 이면 예외가 발생
                //self.showRoute(response!)
                
                //response가 nil 이면 코드를 수행하지 않음
                if let response = response{
                    self.showRoute(response)
                }
            }
        })
    }
}
