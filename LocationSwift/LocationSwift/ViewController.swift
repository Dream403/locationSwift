//
//  ViewController.swift
//  LocationSwift
//
//  Created by snowlu on 2017/6/23.
//  Copyright © 2017年 ZhunKuaiTechnology. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    
  SLLocationManger.shared.getUserLocation({ (location) in
    
    print("\(location!)")
    
  }, { (error) in
      print("\(error!)")
    
    
  }, { (placemark) in
    
       print("\(String(describing: placemark?.city))")
    
  }) { (placemarkError) in
    
       print("\(placemarkError!)")
        }
    

        

  
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

