//
//  WebServiceResource.swift
//  TinyNetworkingLibrary
//
//  Created by Pawel Milek on 23/06/2018.
//  Copyright © 2018 Pawel Milek. All rights reserved.
//

import Foundation

struct WebServiceResource<M, E> where E: Error {
  let url: URL
  let parse: (Data) -> WebServiceResultType<M, E>?
}
