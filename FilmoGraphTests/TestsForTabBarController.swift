//
//  TestsForTabBarController.swift
//  FilmoGraphTests
//
//  Created by Сергей Веретенников on 13/07/2022.
//

import XCTest
@testable import FilmoGraph


class TestsForTabBarController: XCTestCase {

    let sut = TabBar()
    
    override func setUp()  {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGenresShouldNotBeNil() {
        
        var genreses: Genres?
        let exp = expectation(description: #function)
        
        sut._fetchGameGenres { genres in
            genreses = genres
            exp.fulfill()
        }
        
        waitForExpectations(timeout: .infinity) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            XCTAssertNotNil(genreses)
        }
    }
    
    func testTotalGenresesCountShouldBeMoreThan0() {
        
        let exp = expectation(description: #function)
        
        sut._fetchGameGenres { genres in
            exp.fulfill()
        }
        
        waitForExpectations(timeout: .infinity) { error in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let genres = GlobalProperties.shared.genres else { return }
            XCTAssertTrue(genres.value.count ?? 0 > 0, "")
        }
    }
    
    func testMainTableViewModelShouldNotBeNilAfterFetch() {
        
        var mainModel: MainTableViewModel?
        let exp = expectation(description: #function)
        
        sut._fetchGameModel { mainViewModel in
            mainModel = mainViewModel as? MainTableViewModel
            exp.fulfill()
        }
        
        waitForExpectations(timeout: .infinity) { error in
            if let error = error {
                print(error)
            }
            
            XCTAssertNotNil(mainModel)
        }
    }
    
}
