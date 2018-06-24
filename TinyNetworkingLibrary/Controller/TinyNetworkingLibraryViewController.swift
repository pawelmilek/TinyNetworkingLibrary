//
//  ViewController.swift
//  TinyNetworkingLibrary
//
//  Created by Pawel Milek on 23/06/2018.
//  Copyright © 2018 Pawel Milek. All rights reserved.
//

import UIKit

class TinyNetworkingLibraryViewController: UIViewController {
  @IBOutlet weak var firstFetchButton: UIButton!
  @IBOutlet weak var nextFetchButton: UIButton!
  @IBOutlet weak var jsonResponseTextView: UITextView!
  @IBOutlet weak var resultLabel: UILabel!
  
  private lazy var loadingIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(indicator)
    indicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
    indicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
    indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    return indicator
  }()
  
  
  private let webServiceFetchingGroup = DispatchGroup()
  private let webServiceShared = WebServiceAPI.shared
  private var playlistItemsResponse: PlaylistItemsResponse?
  
  private lazy var fetchedDispatchWorkItem = DispatchWorkItem(qos: .userInteractive, flags: .inheritQoS, block: {
    let allItemsTitle = self.playlistItemsResponse?.itemsMetadata.titles
    let totalCount = self.playlistItemsResponse?.itemsMetadata.count ?? 0
    let totalResult = self.playlistItemsResponse?.itemsMetadata.total ?? 0
    
    self.jsonResponseTextView.text = allItemsTitle
    self.resultLabel.text = "\(String(describing: totalCount))/\(String(describing: totalResult))"
    self.firstFetchButton.isEnabled = true
    self.nextFetchButton.isEnabled = true
  })
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    firstFetchButton.layer.cornerRadius = firstFetchButton.frame.size.height / 2
    nextFetchButton.layer.cornerRadius = nextFetchButton.frame.size.height / 2
    firstFetchButton.isEnabled = true
    nextFetchButton.isEnabled = false
    
    jsonResponseTextView.isEditable = false
    jsonResponseTextView.text = ""
    resultLabel.text = ""
  }
}


// MARK: Actions
extension TinyNetworkingLibraryViewController {
  
  @IBAction func fetchFirst50ItemsButtonPressed(_ sender: UIButton) {
    jsonResponseTextView.text = ""
    fetchPlaylistItems()
  }
  
  @IBAction func fetchNext50ItemsButtonPressed(_ sender: UIButton) {
    fetchNextPageOfPlaylistItems()
  }
  
}


// MARK: Fetching data
private extension TinyNetworkingLibraryViewController {
  
  func fetchPlaylistItems() {
    webServiceFetchingGroup.enter()

    startLoadingIndicator()
    firstFetchButton.isEnabled = false
    nextFetchButton.isEnabled = false
    
    let playlistItemsResource = WebServiceResource<PlaylistItemsResponse>(url: webServiceShared.playlistItemsURL)
    webServiceShared.fetch(resource: playlistItemsResource) { [weak self] response in
      switch response {
      case .success(let data):
        self?.playlistItemsResponse = data

      case .failure(let error):
        error.handle()
      }
      
      self?.stopLoadingIndicator()
      self?.webServiceFetchingGroup.leave()
    }
    
    webServiceFetchingGroup.notify(queue: .main) {
      DispatchQueue.main.async(execute: self.fetchedDispatchWorkItem)
    }
  }
  
  
  func fetchNextPageOfPlaylistItems() {
    guard let nextPageToken = playlistItemsResponse?.nextPageToken else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.title = "No more items" }
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { self.title = nil }
      return
    }

    webServiceFetchingGroup.enter()
    
    startLoadingIndicator()
    firstFetchButton.isEnabled = false
    nextFetchButton.isEnabled = false
    
    let nextPagePlaylistItemsResource = WebServiceResource<PlaylistItemsResponse>(url: webServiceShared.nextPagePlaylistItemsURL(at: nextPageToken))
    webServiceShared.fetch(resource: nextPagePlaylistItemsResource) { [weak self] response in
      guard let strongSelf = self else { return }
      
      switch response {
      case .success(let data):
        strongSelf.playlistItemsResponse?.append(data)
        
      case .failure(let error):
        error.handle()
      }
      
      self?.stopLoadingIndicator()
      self?.webServiceFetchingGroup.leave()
    }
    
    webServiceFetchingGroup.notify(queue: .main) {
      DispatchQueue.main.async(execute: self.fetchedDispatchWorkItem)
    }
  }
}


// MARK: Start/Stop loading Indicator
private extension TinyNetworkingLibraryViewController {

  func startLoadingIndicator() {
    DispatchQueue.main.async {
      self.loadingIndicator.startAnimating()
    }
  }
  
  func stopLoadingIndicator() {
    DispatchQueue.main.async {
      self.loadingIndicator.stopAnimating()
    }
  }
}
