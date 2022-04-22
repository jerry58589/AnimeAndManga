//
//  AnimeAndMangaTests.swift
//  AnimeAndMangaTests
//
//  Created by JerryLo on 2022/4/16.
//

import XCTest
@testable import AnimeAndManga

class AnimeAndMangaTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func test_getAnimeRequest() {
        var params = [String: AnyObject]()
        params["page"] = "1" as AnyObject

        let expectation = XCTestExpectation(description: "response")

        APIManager.shared.runCommand(apiType: .OPENAPI_GET_ANIME, params: params, completion: { response in
            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNotNil(response.data)
            XCTAssertNil(response.error)
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 3)
     }
    
    func test_getMangaRequest() {
        var params = [String: AnyObject]()
        params["page"] = "1" as AnyObject
 
        let expectation = XCTestExpectation(description: "response")

        APIManager.shared.runCommand(apiType: .OPENAPI_GET_ANIME, params: params, completion: { response in
            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNotNil(response.data)
            XCTAssertNil(response.error)
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 3)
     }
 
    
//    func test_getUserDefault() {
////        let vm = AnimeMangaVM()
//
////        UserDefaultManager.shared.getMangaFavoriteList()
////        xct
//        
//        
//        
//        
//    }


}
