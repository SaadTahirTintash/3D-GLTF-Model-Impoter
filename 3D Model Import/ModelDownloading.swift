//
//  ModelDownloading.swift
//  3D Model Import
//
//  Created by Tintash on 06/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//


import Foundation
import SSZipArchive
import GLTFSceneKit

protocol ModelDownloading: URLDownloading {}

extension ModelDownloading {
    
    func downloadModel(fileName: String, success: @escaping((URL)->Void), failure: @escaping((String)->Void)) {
        
        //TODO: Caching
        
        //Create a url session to download zip file from link
        guard let fileUrl = URL(string: fileName) else {
            return
        }
        
        //Download Resource from the url in a temporary folder
        downloadResource(from: fileUrl, success: { (localUrl) in
            
            //Creating a specific filename for gltf folder
            let gltfFileNameWithExtension           = fileName.components(separatedBy: "/").last
            guard let gltfFileNameWithoutExtension  = gltfFileNameWithExtension?.components(separatedBy: ".").first else {
                failure("Couldn't find the specified component from the given filename")
                return
            }
            
            //Create an unzip file directory for unzipping the folder at localUrl
            guard let unzipFileDirectory = self.unzipPath(from: gltfFileNameWithoutExtension) else {
                failure("Couldn't create an unzipped Directory at this path")
                return
            }
            
            
            //success is nil means the file was found in cache
            //don't unzip it, just read from the directory
            //if not nil then unzip file
            if let localUrl = localUrl {
                //Unzip the file from downloaded location e.g. local url to destination e.g. unzip file directory
                let isSuccessful = SSZipArchive.unzipFile(atPath: localUrl.path, toDestination: unzipFileDirectory)
                
                //Check for success
                guard isSuccessful else {
                    failure("Unzzipping Failed!")
                    return
                }
            }
            
            //Create an unzip file directory url
            guard let unzipFileDirectoryUrl = URL(string: unzipFileDirectory) else {
                failure("URL Creation Failed!")
                return
            }
            
            //Find the gltf file from the directory url
            guard let modelUrl = self.findContents(of: unzipFileDirectoryUrl, with: "gltf") else {
                return
            }
            
            success(modelUrl)
        }) { (errorMsg) in
            print(errorMsg)
        }
    }
    
    func unzipPath (from fileName: String) -> String? {
        
        let pathWithComponent = createModelDirectory(for: fileName)
        do {
            if FileManager.default.fileExists(atPath: pathWithComponent) {
                print("File already Exists")
            } else {
                try FileManager.default.createDirectory(atPath: pathWithComponent, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            return nil
        }
        return pathWithComponent
    }
    
    func createModelDirectory(for file: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as NSString
        let pathWithComponent = path.appendingPathComponent("Models/\(file)")
        return pathWithComponent
    }
    
    func findContents(of directory: URL, with fileExtension: String) -> URL? {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
            
            let modelFiles = directoryContents.filter { $0.pathExtension.lowercased() == fileExtension }
            guard modelFiles.count > 0 else {
                print("No \(fileExtension) model Files Found!")
                return nil
            }
            return modelFiles.first
        }
        catch (let error) {
            print("error reading contents of - \(directory) : \(error)")
            return nil
        }
    }
    
    func contentsOf(folder: URL) -> [URL]? {
        
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
            let urls = contents.map { return folder.appendingPathComponent($0) }
            print(urls)
            return urls
        } catch {
            return nil
        }
    }
}
