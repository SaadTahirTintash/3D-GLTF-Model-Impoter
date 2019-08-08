//
//  WLCacheManager.swift
//  3D Model Import
//
//  Created by Tintash on 08/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//

import Foundation

struct WLCacheManager {
    
    static let shared = WLCacheManager()
    
    var resourceUrl : NSCache<NSString,NSURL> = NSCache<NSString,NSURL>()
    
    func getResourceUrl(_ urlString: String) -> URL? {
        guard let url = resourceUrl.object(forKey: urlString as NSString) else {
            return nil
        }
        return url as URL
    }
    
    func setResourceUrl(_ urlString: String, url: URL) {
        resourceUrl.setObject(url as NSURL, forKey: urlString as NSString)
    }
}
