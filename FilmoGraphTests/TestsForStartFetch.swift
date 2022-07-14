//
//  TestsForStartFetch.swift
//  FilmoGraphTests
//
//  Created by Сергей Веретенников on 14/07/2022.
//

import XCTest
@testable import FilmoGraph

class TestsForStartFetch: XCTestCase {

    let sut = StartFetch.shared
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testViewModelAfterFetchShouldHaveProperties() {
        
        var testModel: MainTableViewModel?
        let exp = expectation(description: #function)
        
        sut.fetchGameListForMainView { mainModel in
            testModel = mainModel as? MainTableViewModel
            exp.fulfill()
        }
        
        waitForExpectations(timeout: .infinity) { error in
            if let error = error {
                print(error)
            }
            
            XCTAssertTrue(testModel?.games.value.count ?? 0 > 0, "Count after fetch should be not equal 0")
            XCTAssertNotNil(testModel?.nextPage)
        }
    }
    
    func testCurrentRequestsShouldBeMoreThan0WhenFetchingGoes() {
        
        var countOfRequests = 0
        
        sut.fetchGameListForMainView { _ in }
        countOfRequests = sut._checkRequestsInStartFetch()?.count ?? 0
        
        XCTAssertTrue(countOfRequests > 0)
    }
    
    func testCountOfRequestsInStartFetchAfterFetchShouldBeNil() {
        
        let exp = expectation(description: #function)
        var requests: [UUID?]?
        
        sut.fetchGameListForMainView { [unowned self] _ in
            requests = sut._checkRequestsInStartFetch()
            exp.fulfill()
        }
        
        waitForExpectations(timeout: .infinity) { error in
            XCTAssertNil(requests, "Requests shouldn't be save in memory")
        }
        
    }
}
