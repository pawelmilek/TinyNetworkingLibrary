//
//  ViewController.swift
//  TinyNetworkingLibrary
//
//  Created by Pawel Milek on 23/06/2018.
//  Copyright © 2018 Pawel Milek. All rights reserved.
//

import UIKit

class TinyNetworkingLibraryViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}


// MARK: Actions
extension TinyNetworkingLibraryViewController {
  
  @IBAction func executeRequestButtonPressed(_ sender: UIButton) {
    
    let youtubeListItems = WebServiceResource<
    
    WebServiceAPI.shared.getMockData {
      print("")
    }
  }
  
}
