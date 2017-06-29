//
//  SLLocationManger.swift
//  LocationSwift
//
//  Created by snowlu on 2017/6/23.
//  Copyright © 2017年 ZhunKuaiTechnology. All rights reserved.
//

import UIKit
import CoreLocation


extension String {
    
    func substring(s: Int, _ e: Int? = nil) -> String {
        
        let start = s >= 0 ? self.startIndex : self.endIndex
        
        let startIndex = index(start, offsetBy: s)
        
        var end: String.Index
        var endIndex: String.Index
        if(e == nil){
            end = self.endIndex
            endIndex = self.endIndex
        } else {
            end = e! >= 0 ? self.startIndex : self.endIndex

            endIndex = index(end, offsetBy: e!)
        }
        let range = Range<String.Index>(startIndex..<endIndex)
        
        return self.substring(with: range)
        
    }
}


  public final  class SLPlacemark: NSObject {
   
    var  country:String?
    
    var  province:String?{
    
        didSet{
            if (province?.hasSuffix("省"))! {
               
            province =  province?.substring(s: 0, province!.characters.count - 1)
                
            }else if(province?.hasSuffix("市"))!{
              province =  province?.substring(s: 0, province!.characters.count - 1)
            }
        }
    }
    
    var  city:String?{
       
        didSet{
            
            if (city?.hasSuffix("市辖区"))! {
                
                city =  city?.substring(s: 0, (city?.characters.count)! - 3)
            }
            if(city?.hasSuffix("市"))!{
                city =  city?.substring(s: 0, (city?.characters.count)! - 1)
            }
            
            if((city?.hasSuffix("香港特別行政區"))!||(city?.hasSuffix("香港特别行政区"))!){
                city = "香港"
            }
            
            if((city?.hasSuffix("澳門特別行政區"))!||(city?.hasSuffix("澳门特别行政区"))!){
                city = "澳门"
            }
        }
        
    }
    
    var  county:String?
    
    var  address:String?
    
    var placemarkId:NSInteger?
    
    var  type:String?
    
    var latitude:CLLocationDegrees?
    
    var longitude:CLLocationDegrees?
    
    public final func getProvinceAndCity() ->String {
     
        var  provinceName = province
        
        var cityName  = city
        
        
        if provinceName == cityName {
            
            provinceName = ""
        }
        
        if (cityName?.hasSuffix("市辖区"))! {
            
             city =  city?.substring(s: 0, (city?.characters.count)! - 3)
            
        }
        if(cityName?.hasSuffix("市"))!{
             city =  city?.substring(s: 0, (city?.characters.count)! - 1)
        }
        
        if((cityName?.hasSuffix("香港特別行政區"))!||(cityName?.hasSuffix("香港特别行政区"))!){
            cityName = "香港"
        }
        
        if((cityName?.hasSuffix("澳門特別行政區"))!||(cityName?.hasSuffix("澳门特别行政区"))!){
            cityName = "澳门"
        }

        return  (provinceName?.appending(cityName! as String))!
    }
    
    override init() {
        
    }
    
      init(_ placeMark:CLPlacemark) {
        
        super.init()
        //bug
        self.city = placeMark.locality
        
        self.country = placeMark.country
        
        self.county  = placeMark.subLocality
        
        self.province = placeMark.administrativeArea
        
        self.address  = "\(placeMark.thoroughfare) \(placeMark.subThoroughfare)"
    
    }
}
//获取经当前用户信息
public typealias UserLocation = ((_ location: CLLocation?) -> Void)
//获取定位失败
public typealias UserlocationError  = ((_ error : NSError?)-> Void)
//获取地理位置
public typealias LocationPlacemark  = ((_ placemark:SLPlacemark?)-> Void)

public typealias LocationPlacemarkError  = ((_ error : NSError?)-> Void)

private let manger = SLLocationManger()

class SLLocationManger: NSObject ,CLLocationManagerDelegate {
    
    open class var shared: SLLocationManger {
        
        return manger
    }

    private  var  locationManager :CLLocationManager!
    
    private var   geocoder:CLGeocoder!
    
    private var   userlocation : UserLocation?
    
    private var   userLocationError :UserlocationError?
    
    private var   locationPlacemark:LocationPlacemark?
    
     private var   locationPlacemarkError:LocationPlacemarkError?
    
      override init() {
        
        super.init()
        
        locationManager = CLLocationManager()
    
        locationManager.delegate  =  self
        
        locationManager.desiredAccuracy  = kCLLocationAccuracyBest
        
        locationManager.distanceFilter   = 10
        
        if locationManager .responds(to:#selector(locationManager.requestWhenInUseAuthorization)){
            locationManager .requestWhenInUseAuthorization()
        }
        geocoder = CLGeocoder()
    }
    
    public  final func startLocation(){
        locationManager.startUpdatingLocation()
    }
    
    public final func stopLocation(){
        
        locationManager.startUpdatingLocation()
    }
   
    public final func getUserLocation ( _ location: @escaping UserLocation ,_ error :@escaping UserlocationError , _ locationPlacemark: @escaping LocationPlacemark ,_ Placemarkerror :@escaping LocationPlacemarkError){
       
        if CLLocationManager.locationServicesEnabled() == false{
         
            return ;
        }
        
        stopLocation()
        
        startLocation()
        
       self.userlocation = location
        
       self.userLocationError = error
        
       self.locationPlacemarkError = Placemarkerror
        
        self.locationPlacemark = locationPlacemark
        
        
    }
  
    /// 反向地理编码获取地址信息
    public final func getPlacemark (_ coor :CLLocationCoordinate2D , _ locationPlacemark: @escaping LocationPlacemark ,_ Placemarkerror :@escaping LocationPlacemarkError){
    
        self.locationPlacemark = locationPlacemark
        
        self.locationPlacemarkError = Placemarkerror
        
        
        let location:CLLocation = CLLocation.init(latitude: coor.latitude, longitude: coor.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placeMark:CLPlacemark  = placemarks?.first{
                
                
                if self.locationPlacemark != nil {
                    self.locationPlacemark!(SLPlacemark.init(placeMark))
                }
            }else{
                if self.locationPlacemarkError != nil {
                    self.locationPlacemarkError!(error! as NSError)
                }
            }

        }
    
    }
    /// 地理编码获取经纬度
    public final func getLocation (_ address :NSString , _ location : @escaping UserLocation ,_ Placemarkerror :@escaping LocationPlacemarkError){
        
        self.userlocation = location
        
        self.locationPlacemarkError = Placemarkerror
        
        geocoder.geocodeAddressString(address as String) { (placemarks, error) in
            
            if (placemarks?.isEmpty)!  == false {
               
                let palceMark:CLPlacemark = (placemarks?.first)!
                
                if self.userlocation != nil {
                    
                    self.userlocation!(palceMark.location)
                    
                }
                
                
            }else {
                
                if self.locationPlacemarkError != nil {
                    
                    self.locationPlacemarkError!(error as NSError?)
                }
                
            }
        }
    
        
    }
        
    public  final func locationServicesEnabled () ->Bool {
    
        return CLLocationManager.locationServicesEnabled()
    
    }
    
    // CLLocationManagerDelegate

    //当前位置
  internal   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location :CLLocation = locations.last {
            
            if self.userlocation != nil {
                
                self.userlocation!(location)
            }
            
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let placeMark:CLPlacemark  = placemarks?.first{
                
                    if self.locationPlacemark != nil {
                     self.locationPlacemark!(SLPlacemark.init(placeMark))
                        
                    }
                }else{
                    if self.locationPlacemarkError != nil {
                        self.locationPlacemarkError!(error! as NSError)
                    }
                }
            })
            
        }
        
    }
    
    
  internal  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
        if (self.userLocationError != nil) {
            self.userLocationError!(error as NSError)
        }
        
    }

   internal   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("用户未决定")
        case .restricted: // 暂时没啥用
            print("访问受限")
        case .denied: // /定位关闭时和对此APP授权为never时调用
            if CLLocationManager.locationServicesEnabled() {
                print("定位开启,但被拒绝")
                if let settingUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl) && Double(UIDevice.current.systemVersion)! >= 8.0 {
                        //iOS8可直接跳转到设置界面
                        let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，是否前往设置开启", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        })
                        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(settingUrl)
                        })
                        alertVC.addAction(cancelAction)
                        alertVC.addAction(okAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                    }
                } else {
                    let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，请在设置中开启", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                    })
                    alertVC.addAction(cancelAction)
                    let vc = UIApplication.shared.keyWindow?.rootViewController
                    vc?.present(alertVC, animated: true, completion: nil)
                }
                
            } else {
                print("定位关闭,不可用")
                if let settingUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl) && Double(UIDevice.current.systemVersion)! >= 8.0 {
                        //iOS8可直接跳转到设置界面
                        let alertVC = UIAlertController(title: "提示", message: "定位功能被拒绝，是否前往设置开启", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        })
                        let okAction = UIAlertAction(title: "确定", style: .default, handler: { (action) in
                            UIApplication.shared.openURL(settingUrl)
                        })
                        alertVC.addAction(cancelAction)
                        alertVC.addAction(okAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                        
                    } else {
                        let alertVC = UIAlertController(title: "提示", message: "定位服务未开启\n打开方式:设置->隐私->定位服务", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                        })
                        alertVC.addAction(cancelAction)
                        let vc = UIApplication.shared.keyWindow?.rootViewController
                        vc?.present(alertVC, animated: true, completion: nil)
                    }
                    
                }
            }
            
        case .authorizedAlways:
            print("获取前后台定位授权")
        case .authorizedWhenInUse:
            print("获取前台定位授权")
        }
    }
    
    
   
    
    
}
