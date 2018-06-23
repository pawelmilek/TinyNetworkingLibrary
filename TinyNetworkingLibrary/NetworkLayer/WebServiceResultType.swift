//
//  WebServiceResultType.swift
//  TinyNetworkingLibrary
//
//  Created by Pawel Milek on 23/06/2018.
//  Copyright © 2018 Pawel Milek. All rights reserved.
//

import Foundation

enum WebServiceResultType<M, E> where E: Error {
  case success(M)
  case failure(E)
}
