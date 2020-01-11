//
//  OMDB_Image_AppTests.swift
//  OMDB iOS Client AppTests
//
//  Created by radhakrishnan on 01/10/19.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import XCTest
@testable import OMDB_iOS_Client_App

class APIServiceTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchService() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expect = XCTestExpectation(description: "callback")
        ServiceManager.fetchPhotosForSearchText(searchText: "Batman", pageNo: 1) { (error, models, page) in
            expect.fulfill()
            XCTAssertEqual( error, nil)
            XCTAssertEqual( models!.count, 10)
            XCTAssertEqual( page?.currentPage, 1)
            for model in models! {
                XCTAssertNotNil(model.year)
                XCTAssertNotNil(model.poster)
                XCTAssertNotNil(model.imdbID)
                XCTAssertNotNil(model.title)
                XCTAssertNotNil(model.type)
            }
        }
        wait(for: [expect], timeout: 3.0)
    }
    
    func testImageDowloadService() {
        let expect = XCTestExpectation(description: "callback")
        ServiceManager.fetchDataForURL(URL: "https://google.com") { (error, data) in
            expect.fulfill()
            XCTAssertEqual( error, nil)
            XCTAssertNotNil(data)
        }
        wait(for: [expect], timeout: 3.0)
    }

}
