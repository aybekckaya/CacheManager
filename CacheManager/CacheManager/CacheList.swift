//
//  CacheManager.swift
//  CacheManager
//
//  Created by aybek can kaya on 10/09/2017.
//  Copyright © 2017 aybek can kaya. All rights reserved.
//

import UIKit

/**
 CacheManager
 
 *** Network responselarını cache içerisine almak için kullanılır.
 *** Cache süresi var (default: 7 days ) değiştirilebilir nitelikte
 *** max Number of cache files diye birşey olacak (default:20) eğer plist dosyaları bu sayıyı aşarsa , expire date i en yakın olan dosya silinecek.
 *** plist dosyaları unique id ile oluşturulacak.
 *** init anında cache dosyası oluşturulacak . dosya içinde cacheMap olacak
 *** CacheMap is dictionaries : {“http://endpoint.com/…”: [filename:”1233kdj.plist” , expireDate:”13233443”]}
 
 */
class CacheList: NSObject {
    
    struct MapFile {
        var key:String = ""
        var expireDate:UInt = 0
        var filename:String = ""
        
        func toDictionary()->[String:Any] {
            return ["key":key , "expireDate":expireDate , "filename":filename]
        }
    }

    enum CacheListError:Error {
        case couldNotFoundMapWithKey
       
        func errorComponent()->Error {
            switch self {
            case .couldNotFoundMapWithKey:
                return NSError(domain: "could not found map with key", code: 10000, userInfo: nil) as Error
            }
        }
        
    }
    
    
    fileprivate var mapFile:String = "CacheMap"
    fileprivate var folderName:String = "CacheLists"
    
    fileprivate var duration:UInt = 7*24*60*60 // seven days
    fileprivate var maxNumberOfCacheFiles:Int = 20
    
    var folderPath:String {
        get { return cacheFolderPath() }
    }
    
    init(_mapFile:String = "CacheMap" , _folderName:String = "CacheLists") {
        super.init()
        mapFile = _mapFile
        folderName = _folderName
        createMapFile()
    }
    
    fileprivate func cacheFolderPath()->String {
        return String.documentsDirectoryPath()+"/"+folderName+"/"
    }
    
    private func createMapFile() {
        let _ = Plist(_name: mapFile, _source: .documentsDirectory, _folderPath: folderName)
    }
    
    func read(key:String , completion:@escaping (_ data:[String:Any]?, _ error:Error?)->Void) {
        removeExpiredFiles()
        let mapListContents = cacheMaps()
        
        // if mapfile with specified key not found then break
        guard let mapFile = mapListContents.first(where: { $0.key == key }) else {
            completion(nil, CacheListError.couldNotFoundMapWithKey.errorComponent())
            return
        }
       
       let listCache = Plist(_name: mapFile.filename, _source: .documentsDirectory, _folderPath: folderName)
        listCache.read(key: key) { (data, error) in
            completion(data,error)
        }
    }
    
    func save(key:String , data:Any , expireDuration:UInt? = nil ,  completion:@escaping (_ filename:String?, _ error:Error?)->Void) {
        // eğer aynı key ile bir dosya varsa onun üzerine yaz .
        if expireDuration != nil { duration = expireDuration! }
        var uniqueID:String = UUID().uuidString
        var maps:[MapFile] = cacheMaps()
        if let mapFile = maps.first(where: { $0.key == key }) {
            uniqueID = mapFile.filename
        }
        removeExpiredFiles()
        maps = cacheMaps()
        if maps.count > maxNumberOfCacheFiles {
            if let firstMap = maps.sorted(by: { return $0.expireDate < $1.expireDate })
            .first {removeCache(filename: firstMap.filename, mapKey: firstMap.key)}
        }
        
        // map dosyasına yaz bu listeyi .
        let listMap = Plist(_name: mapFile, _source: .documentsDirectory, _folderPath: folderName)
        let expireDate:UInt = UInt(Date().timeIntervalSince1970) + UInt(duration)
        let cacheMapList = MapFile(key: key, expireDate: expireDate, filename: uniqueID)
        listMap.save(key: key, data:cacheMapList.toDictionary() ) { error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            // unique id türet ve gelen datayı bu id ile kaydet .
            let listCache = Plist(_name: uniqueID, _source: .documentsDirectory, _folderPath: self.folderName)
            listCache.save(key: key, data: data) { error in
                guard error == nil else {
                    listMap.removeKey(key: key)
                    completion(nil,error)
                    return
                }
                completion(uniqueID, nil)
            }
        }
        
    }
    
    
    
    fileprivate func removeExpiredFiles() {
        let currentTimeInSeconds:UInt = UInt(Date().timeIntervalSince1970)
        let mapsToRemove = cacheMaps().filter{ $0.expireDate < currentTimeInSeconds }
        mapsToRemove.forEach{
            removeCache(filename: $0.filename, mapKey: $0.key)
        }
    }
    
    fileprivate func removeCache(filename:String, mapKey:String) {
        let listToRemove = Plist(_name: filename, _source: .documentsDirectory, _folderPath: folderName)
        listToRemove.removePlist()
        let list = Plist(_name: mapFile, _source: .documentsDirectory, _folderPath: folderName)
        list.removeKey(key: mapKey)
    }
    
    
    fileprivate func cacheMaps()->[MapFile] {
        let list = Plist(_name: mapFile, _source: .documentsDirectory, _folderPath: folderName)
        guard let contents = list.contents() else { return [] }
        let mapFiles:[MapFile] = contents.keys.flatMap{key in
            guard let dataStr = contents[key] as? String , let json = dataStr.decodeJSON() , let innerDct = json[key] as? [String:Any], let _key = innerDct["key"] as? String , let _expireDate:UInt = innerDct["expireDate"] as? UInt , let _filename:String = innerDct["filename"] as? String else { return nil }
            let mapSt = MapFile(key: _key, expireDate: _expireDate, filename: _filename)
            return mapSt
        }
        
        return mapFiles
    }
    
}

// Testable Extensions
extension CacheList {
    /*
     if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
     // Code only executes when tests are running
     print("testOnRun")
     }
     */
    
    
    
}




