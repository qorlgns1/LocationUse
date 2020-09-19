//
//  MapViewController.swift
//  LocationUse
//
//  Created by 배기훈 on 2020/09/15.
//  Copyright © 2020 배기훈. All rights reserved.
//

import UIKit
//지도 사용을 위한 프레임워크
import MapKit
//현재 위치를 가져오기 위한 프레임워크
import CoreLocation


class MapViewController: UIViewController {
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    //위치 정보 사용 객체의 참조를 저장할 변수
    var locationManager : CLLocationManager!
    //검색된 위치 정보를 저장할 배열을 생성
    var matchingItems = [MKMapItem]()


    @IBAction func textFieldReturn(_ sender: Any) {
        //키보드 제거
        searchText.resignFirstResponder()
        
        //기존에 존재하던 어노테이션 제거
        mapView.removeAnnotations(mapView.annotations)
        
        //검색된 결과도 삭제
        matchingItems.removeAll()
        
        //검색 요청 객체 생성
        let request = MKLocalSearch.Request()
        //검색어 설정
        request.naturalLanguageQuery = searchText.text
        //검색 범위 설정
        request.region = mapView.region
        
        //실제 검색을 수행해 줄 객체를 생성
        let search = MKLocalSearch(request: request)
        //검색 요청
        search.start(completionHandler: {(response:MKLocalSearch.Response!, error:Error!) in
            if error != nil{
                NSLog("검색 실패")
            }else if response.mapItems.count == 0{
                NSLog("검색 결과 없음")
            }else{
                NSLog("검색 결과 존재")
                //검색 결과 순회
                for item in response.mapItems as [MKMapItem]{
                    //배열에 검색된 내용을 추가
                    self.matchingItems.append(item as MKMapItem)
                    
                    //지도에 출력할 어노테이션 생성
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    //지도에 출력
                    self.mapView.addAnnotation(annotation)
                }
            }
                   let MapResultTableViewController = self.storyboard?.instantiateViewController(identifier: "MapResultTableViewController") as! MapResultTableViewController
                   MapResultTableViewController.mapItems = self.matchingItems
                   self.navigationController?.pushViewController(MapResultTableViewController, animated: true)
        })
        
       
    }
    
    @IBAction func zoom(_ sender: Any) {
        //현재 위치 가져오기
        let userLocation = mapView.userLocation
        // 현재위치의 좌표, 남/북 2000미터인 스팬으로 구성된 MKCoordinateRegion 객체를 생성
        let region = MKCoordinateRegion.init(center:userLocation.location!.coordinate,
                                             latitudinalMeters:500, longitudinalMeters:500)
        mapView.setRegion(region, animated: true)

    }
    @IBAction func type(_ sender: Any) {
        if mapView.mapType == MKMapType.standard {
            mapView.mapType = MKMapType.satellite
        }else if mapView.mapType == MKMapType.satellite{
            mapView.mapType = MKMapType.hybrid
        }else if mapView.mapType == MKMapType.hybrid{
            mapView.mapType = MKMapType.hybridFlyover
        }else if mapView.mapType == MKMapType.hybridFlyover{
            mapView.mapType = MKMapType.mutedStandard
        }else {
            mapView.mapType = MKMapType.standard
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "지도 출력"
        
        //위치 정보 객체 생성
        locationManager = CLLocationManager()
        //위치정보 사용 권한을 생성 -
        //requestWhenInUseAuthorization : 실행중일 때만 사용
        //requestAlwaysAuthorization : 항상 사용
        locationManager.requestWhenInUseAuthorization()

        //현재 위치를 지도에 표시하도록 설정
        mapView.showsUserLocation = true
        
        //맵 뷰의 Delegate 설정
        mapView.delegate = self
    }
    
}

extension MapViewController : MKMapViewDelegate {
    //사용자의 위치 정보가 갱신된 경우 호출되는 메소드
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            mapView.centerCoordinate = userLocation.location!.coordinate
    }
}
