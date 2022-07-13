//
//  FilmoGraphTests.swift
//  TestsForManagingRequests
//
//  Created by Сергей Веретенников on 14/06/2022.
//

import XCTest
import Alamofire
@testable import FilmoGraph

class TestsForManagingRequests: XCTestCase {
    
    let request = AF.request("https://api.rawg.io/api/platforms?key=7f01c67ed4d2433bb82f3dd38282088c&page=1")
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRequestsShouldBeCanceledAndDeleted() {
        URLResquests.shared.runningRequests.removeAll()
        var testRequests = [UUID?]()
        var count = 0
        while count < 5 {
            count += 1
            let uuid = UUID()
            URLResquests.shared.addTasksToArray(uuid: uuid, task: request)
            testRequests.append(uuid)
        }
        URLResquests.shared.cancelRequests(requests: testRequests)
        
        XCTAssert(URLResquests.shared.runningRequests.count == 0, "Count of requests after array delete should be equal zero")
    }
    
    func testOneRequestShouldBeCanceledAndDeleted() {
        URLResquests.shared.runningRequests.removeAll()
        var testRequests = [UUID?]()
        
        let uuid = UUID()
        URLResquests.shared.addTasksToArray(uuid: uuid, task: AF.request("https://api.rawg.io/api/platforms?key=7f01c67ed4d2433bb82f3dd38282088c&page=1"))
        testRequests.append(uuid)
        
        URLResquests.shared.cancelRequests(requests: testRequests)
        
        XCTAssert(URLResquests.shared.runningRequests.count == 0, "Count of requests should be equal zero")
    }
    
    func testTotalRequestsShouldBeEqualOne() {
        URLResquests.shared.runningRequests.removeAll()
        let uuid = UUID()
        
        URLResquests.shared.addTasksToArray(uuid: uuid, task: request)
        
        XCTAssert(URLResquests.shared.runningRequests.count == 1, "Count of requests should be equal one after adding")
    }
}
