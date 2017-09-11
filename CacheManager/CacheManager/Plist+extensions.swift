//
//  Plist+extensions.swift
//  CacheManager
//
//  Created by aybek can kaya on 10/09/2017.
//  Copyright © 2017 aybek can kaya. All rights reserved.
//

import Foundation

protocol JsonConvertible {
    func toJsonString()->String?
}

extension JsonConvertible {
    func toJsonString()->String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            return jsonString
        } catch {
            return nil
        }
    }
}

extension Array:JsonConvertible {}
extension Dictionary:JsonConvertible {}

extension String {
    
    func decodeJSON()->[String:Any]? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        do{
            let jsonParsed = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            return jsonParsed as? [String:Any]
        }catch {
            print("err: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func documentsDirectoryPath()->String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    }
    
    func fileExistAtPath()->Bool {
        return FileManager.default.fileExists(atPath: self)
    }
    
    func directoryExists()->Bool {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: self, isDirectory:&isDir) {
            if isDir.boolValue {
                return true
            } else {
                fatalError("String:\(self) is not a directory path")
            }
        }
        return false
    }
    
    
    
    func removeFile() {
        do {
            try FileManager.default.removeItem(atPath: self)
        }catch {
            print("error : \(error.localizedDescription)")
        }
    }
    
    
    func allFilesInDirectory()->[String] {
        
        var documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsUrl.appendPathComponent(self)
        var contents:[String] = []
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            contents = directoryContents.map{ $0.absoluteString }
            return contents
        } catch  {
            return contents
        }
    }
    
    
    func createDir() {
        guard !self.directoryExists() else { return }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pt = self+"/"
        let dataPath = documentsDirectory.appendingPathComponent(pt)
        
        do {
            try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
}
