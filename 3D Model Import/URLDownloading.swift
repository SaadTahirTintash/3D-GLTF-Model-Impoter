//
//  URLDownloading.swift
//  3D Model Import
//
//  Created by Tintash on 06/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//

import Foundation


protocol URLDownloading {
    typealias success = (URL)   -> Void
    typealias failure = (String) -> Void
}

extension URLDownloading {
    
    func downloadResource(from fileUrl: URL, success: @escaping(success), failure: @escaping(failure)) {
        
        //TODO: Caching
        let task = URLSession.shared.downloadTask(with: fileUrl) { (localUrl, response, error) in
            guard let localUrl = localUrl else {
                guard let error = error else {
                    failure("Unknown Error!")
                    return
                }
                failure(error.localizedDescription)
                return
            }
            success(localUrl)
        }
        
        task.resume()        
    }
}
