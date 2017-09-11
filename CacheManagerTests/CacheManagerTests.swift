//
//  CacheManagerTests.swift
//  CacheManagerTests
//
//  Created by aybek can kaya on 10/09/2017.
//  Copyright © 2017 aybek can kaya. All rights reserved.
//

import XCTest
@testable import CacheManager

class CacheManagerTests: XCTestCase {
    
    fileprivate let cacheManagerMapFile:String = "SampleMapFile"
    fileprivate let cacheManagerFolder:String = "SampleCacheManager"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        let folderName = String.documentsDirectoryPath()+"/"+cacheManagerFolder
        //removeFolder(folderName: folderName)
    }
    
    private func removeFolder(folderName:String) {
        do { try FileManager.default.removeItem(atPath: folderName) }
        catch let error as NSError { print("Ooops! Something went wrong: \(error)") }
    }
    
    func testCreateMapFile() {
        let _ = CacheList(_mapFile: cacheManagerMapFile, _folderName: cacheManagerFolder)
        let allFiles = Plist.allPlistFiles(directoryName: cacheManagerFolder)
        XCTAssert(allFiles.contains(cacheManagerMapFile))
    }
    
    func testSaveToCacheList() {
        let expectStringSave = expectation(description: "String To Save")
        let listCache = CacheList(_mapFile: cacheManagerMapFile, _folderName: cacheManagerFolder)
        
        // save string
        let str = "Today, weather is so cold."
        listCache.save(key: "StringValue", data: str ,  expireDuration:15) { (filename, error) in
            XCTAssert(error == nil)
            listCache.read(key: "StringValue", completion: { (dctVal, error) in
                XCTAssert(error == nil)
                XCTAssert(dctVal != nil)
                guard let val = dctVal!["StringValue"] as? String else {
                    XCTFail()
                    expectStringSave.fulfill()
                    return
                }
                XCTAssert(str == val)
                expectStringSave.fulfill()
            })
        }
        
       
        waitForExpectations(timeout: 14.0) { (_) -> Void in
        }
    }
    
    func testSaveDictionary() {
         let listCache = CacheList(_mapFile: cacheManagerMapFile, _folderName: cacheManagerFolder)
        let expectDictionarySave = expectation(description: "Dictionary To Save")
        // save dictionary
        let strDct:[String:Any] = ["name": "can","age":33]
        listCache.save(key: "DctValue", data: strDct ,  expireDuration:10) { (filename, error) in
            XCTAssert(error == nil)
            listCache.read(key: "DctValue", completion: { (dctVal, error) in
                XCTAssert(error == nil)
                XCTAssert(dctVal != nil)
                guard let val = dctVal!["DctValue"] as? [String:Any] else {
                    XCTFail()
                    expectDictionarySave.fulfill()
                    return
                }
                XCTAssert(val["name"] as! String == "can")
                expectDictionarySave.fulfill()
            })
        }
        waitForExpectations(timeout: 14.0) { (_) -> Void in
        }
    }
    
    func testSaveArray() {
        let expectArraySave = expectation(description: "Array To Save")
          let listCache = CacheList(_mapFile: cacheManagerMapFile, _folderName: cacheManagerFolder)
        let strArr:[Int] = [1,2,3]
        
        listCache.save(key: "ArrayValue",data: strArr, expireDuration:5) { (filename, error) in
            XCTAssert(error == nil)
            listCache.read(key: "ArrayValue", completion: { (dctVal, error) in
                XCTAssert(error == nil)
                XCTAssert(dctVal != nil)
                guard let val = dctVal!["ArrayValue"] as? [Int] else {
                    XCTFail()
                    expectArraySave.fulfill()
                    return
                }
                XCTAssert(strArr[0] == val[0])
                expectArraySave.fulfill()
            })
        }
        waitForExpectations(timeout: 4.0) { (_) -> Void in
        }
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
