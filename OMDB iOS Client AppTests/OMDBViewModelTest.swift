//
//  OMDBTest.swift
//  OMDB iOS Client AppTests
//
//  Created by radhakrishnan on 01/10/19.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import XCTest
@testable import OMDB_iOS_Client_App

class OMDBViewModelTest: XCTestCase {
    
    var viewModel: OMDBViewModel?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = OMDBViewModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
    }
    
    func testLoadPhotosViewModel() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let expect = XCTestExpectation(description: "callback")
        viewModel!.reloadTableViewClosure = { () in
            expect.fulfill()
            XCTAssertEqual(self.viewModel!.numberOfCells, 10)
            XCTAssertNotNil(self.viewModel!.getCellViewModel(at: IndexPath(row: 0, section: 0)).photoUrl)
            
        }
        viewModel!.searchPhotos(text: "Batman")
        wait(for: [expect], timeout: 3.0)
        
    }

    func testStartOperation() {
        let expect = XCTestExpectation(description: "callback")
        let model = OMDBModel(titleString: "Test", imdbIDString: "Test", typeString: "Test", posterString: "Test", yearString: "1994") //OMDBModel(photoIdString: "48790129107", farmInt: 66, secretString: "001dc60320", serverString: "65535", titleString: "DSCN4300")
        viewModel!.reloadTableViewIndexClosure = { (index) in
            expect.fulfill()
            XCTAssertEqual(IndexPath(row: 0, section: 0), index)
        }
        viewModel?.startOperations(for: model, at: IndexPath(row: 0, section: 0))
        wait(for: [expect], timeout: 3.0)
    }
}
