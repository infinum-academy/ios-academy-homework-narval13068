//
//  PromiseKit+KeyPath.swift
//  TVShows
//
//  Created by Rino Čala on 17/07/2019.
//  Copyright © 2019 Infinum Academy. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import CodableAlamofire

extension Alamofire.DataRequest {
    
    public func responseDecodable<T: Decodable>(_ type: T.Type, keyPath: String, queue: DispatchQueue? = nil, decoder: JSONDecoder = JSONDecoder()) -> Promise<T> {
        return Promise { seal in
            responseDecodableObject(queue: queue, keyPath: keyPath, decoder: decoder, completionHandler: { (response: DataResponse<T>) in
                switch response.result {
                case .success(let value):
                    seal.fulfill(value)
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
}
