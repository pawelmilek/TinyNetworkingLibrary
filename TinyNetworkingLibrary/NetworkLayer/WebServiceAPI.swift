//
//  WebServiceAPI.swift
//  TinyNetworkingLibrary
//
//  Created by Pawel Milek on 23/06/2018.
//  Copyright © 2018 Pawel Milek. All rights reserved.
//

import Foundation

final class WebServiceAPI {
  static let shared = WebServiceAPI()
  
  private let baseURL = "https://www.googleapis.com/youtube/v3/"
  private let APIKey = "AIzaSyCSByu8DZ-nh_1CHOrqZZLGpf5Go4qBOPM"
  
  private var urlString: String {
    return "\(baseURL)playlistItems?part=snippet&maxResults=25&playlistId=UUuP2vJ6kRutQBfRmdcI92mA&key=\(APIKey)"
  }
  
  private init() {}
}


extension WebServiceAPI {
  
  func getMockData(_ completionHandler: ()->()) {
    completionHandler()
  }
}
