//
//  ViewController.swift
//  TinyNetworkingLibrary
//
//  Created by Pawel Milek on 23/06/2018.
//  Copyright © 2018 Pawel Milek. All rights reserved.
//

import UIKit

class TinyNetworkingLibraryViewController: UIViewController {
  @IBOutlet weak var firstFetchButton: UIButton! {
    didSet {
      firstFetchButton.layer.cornerRadius = firstFetchButton.frame.size.height / 2
      firstFetchButton.isEnabled = true
    }
  }
  
  @IBOutlet weak var nextFetchButton: UIButton! {
    didSet {
      nextFetchButton.layer.cornerRadius = nextFetchButton.frame.size.height / 2
      nextFetchButton.isEnabled = false
    }
  }
  
  @IBOutlet weak var jsonResponseTextView: UITextView! {
    didSet {
      jsonResponseTextView.isEditable = false
      jsonResponseTextView.text = ""
    }
  }
  
  @IBOutlet weak var resultLabel: UILabel! {
    didSet {
      resultLabel.text = ""
    }
  }
  
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
  private let webServiceShared = WebService.shared
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
  }
}


// MARK: Fetching data
private extension TinyNetworkingLibraryViewController {
  
  func fetchPlaylistItems() {
    webServiceFetchingGroup.enter()

    startLoadingIndicator()
    firstFetchButton.isEnabled = false
    nextFetchButton.isEnabled = false
    
    let request = YoutubePlaylistItemsRequest.make()
    webServiceShared.fetch(PlaylistItemsResponse.self, with: request) { [weak self] response in
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
    
    let nextPageRequest = YoutubePlaylistItemsRequest.make(nextPage: nextPageToken)
    webServiceShared.fetch(PlaylistItemsResponse.self, with: nextPageRequest) { [weak self] response in
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
    ActivityIndicator.shared.startAnimating(at: view)
  }
  
  func stopLoadingIndicator() {
    ActivityIndicator.shared.stopAnimating()
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
