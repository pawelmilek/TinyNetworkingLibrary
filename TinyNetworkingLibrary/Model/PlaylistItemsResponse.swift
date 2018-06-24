//
//  PlaylistItemsResponse.swift
//  TinyNetworkingLibrary
//
//  Created by Pawel Milek on 23/06/2018.
//  Copyright © 2018 Pawel Milek. All rights reserved.
//

import Foundation

struct PlaylistItemsResponse {
  private let pageInfo: PageInfo
  private(set) var items: [PlaylistItem]
  private(set) var nextPageToken: String?
  private var prevPageToken: String?
  
  var totalResult: Int {
    return pageInfo.totalResults
  }
  
  var resultPerPage: Int {
    return pageInfo.resultsPerPage
  }
}

// MARK: - Append more data
extension PlaylistItemsResponse {
  
  mutating func append(_ playlistItems: PlaylistItemsResponse) {
    nextPageToken = playlistItems.nextPageToken
    prevPageToken = playlistItems.prevPageToken
    items.append(contentsOf: playlistItems.items)
  }
  
  
  var itemsMetadata: (titles: String, count: Int, total: Int) {
    let allItemsTitle = items.compactMap { $0.snippet.title }.joined(separator: "\n")
    let allItemsCount = items.count
    let totalItems = totalResult
    
    return (allItemsTitle, allItemsCount, totalItems)
  }
  
}




// MARK: - Decodable protocol
extension PlaylistItemsResponse: Decodable {
  
  enum CodingKeys: String, CodingKey {
    case pageInfo
    case items
    case nextPageToken
    case prevPageToken
  }
  
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.pageInfo = try container.decode(PageInfo.self, forKey: .pageInfo)
    self.items = try container.decode([PlaylistItem].self, forKey: .items)
    self.nextPageToken = try container.decodeIfPresent(String.self, forKey: .nextPageToken)
    self.prevPageToken = try container.decodeIfPresent(String.self, forKey: .prevPageToken)
  }
  
}
