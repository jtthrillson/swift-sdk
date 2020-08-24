//
//  Created by Tapash Majumder on 7/30/20.
//  Copyright © 2020 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

class TaskProcessorTests: XCTestCase {
    func testAPICallForTrackEventWithPersistence() throws {
        let apiKey = "test-api-key"
        let email = "user@example.com"
        let eventName = "CustomEvent1"
        let dataFields = ["var1": "val1", "var2": "val2"]
        
        let expectation1 = expectation(description: #function)
        let auth = Auth(userId: nil, email: email, authToken: nil)
        let config = IterableConfig()
        let networkSession = MockNetworkSession()
        let internalAPI = IterableAPIInternal.initializeForTesting(apiKey: apiKey, config: config, networkSession: networkSession)
        
        let requestCreator = RequestCreator(apiKey: apiKey,
                                            auth: auth,
                                            deviceMetadata: internalAPI.deviceMetadata)
        guard case let Result.success(trackEventRequest) = requestCreator.createTrackEventRequest(eventName, dataFields: dataFields) else {
            XCTFail("Could not create trackEvent request")
            return
        }
        
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endPoint: config.apiEndpoint,
                                                    auth: auth,
                                                    deviceMetadata: internalAPI.deviceMetadata,
                                                    iterableRequest: trackEventRequest)
        let data = try JSONEncoder().encode(apiCallRequest)
        
        // persist data
        let taskId = IterableUtil.generateUUID()
        try persistenceProvider.mainQueueContext().create(task: IterableTask(id: taskId,
                                                                             type: .apiCall,
                                                                             scheduledAt: Date(),
                                                                             data: data,
                                                                             requestedAt: Date()))
        try persistenceProvider.mainQueueContext().save()
        
        // load data
        let found = try persistenceProvider.mainQueueContext().findTask(withId: taskId)!
        
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: internalAPI.networkSession)
        try processor.process(task: found).onSuccess { _ in
            let body = networkSession.getRequestBody() as! [String: Any]
            TestUtils.validateMatch(keyPath: KeyPath(.email), value: email, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(.dataFields), value: dataFields, inDictionary: body)
            expectation1.fulfill()
        }
        
        try persistenceProvider.mainQueueContext().delete(task: found)
        try persistenceProvider.mainQueueContext().save()
        
        wait(for: [expectation1], timeout: 15.0)
    }

    func testNetworkAvailable() throws {
        let expectation1 = expectation(description: #function)
        let task = try createSampleTask()!
        
        let networkSession = MockNetworkSession(statusCode: 200)
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    expectation1.fulfill()
                case .failureWithNoRetry(detail: _):
                    XCTFail("not expecting failure with no retry")
                case .failureWithRetry(retryAfter: _, detail: _):
                    XCTFail("not expecting failure with retry")
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 15.0)
    }

    func testNetworkUnavailable() throws {
        let expectation1 = expectation(description: #function)
        let task = try createSampleTask()!
        
        let networkError = IterableError.general(description: "The Internet connection appears to be offline.")
        let networkSession = MockNetworkSession(statusCode: 0, data: nil, error: networkError)
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    XCTFail("not expecting success")
                case .failureWithNoRetry(detail: _):
                    XCTFail("not expecting failure with no retry")
                case .failureWithRetry(retryAfter: _, detail: _):
                    expectation1.fulfill()
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 15.0)
    }

    func testUnrecoverableError() throws {
        let expectation1 = expectation(description: #function)
        let task = try createSampleTask()!
        
        let networkSession = MockNetworkSession(statusCode: 401, data: nil, error: nil)
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    XCTFail("not expecting success")
                case .failureWithNoRetry(detail: _):
                    expectation1.fulfill()
                case .failureWithRetry(retryAfter: _, detail: _):
                    XCTFail("not expecting failure with retry")
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 15.0)
    }

    private func createSampleTask() throws -> IterableTask? {
        let apiKey = "test-api-key"
        let email = "user@example.com"
        let eventName = "CustomEvent1"
        let dataFields = ["var1": "val1", "var2": "val2"]
        
        let auth = Auth(userId: nil, email: email, authToken: nil)
        let requestCreator = RequestCreator(apiKey: apiKey,
                                            auth: auth,
                                            deviceMetadata: deviceMetadata)
        guard case let Result.success(trackEventRequest) = requestCreator.createTrackEventRequest(eventName, dataFields: dataFields) else {
            XCTFail("Could not create trackEvent request")
            return nil
        }
        
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endPoint: Endpoint.api,
                                                    auth: auth,
                                                    deviceMetadata: deviceMetadata,
                                                    iterableRequest: trackEventRequest)
        let data = try JSONEncoder().encode(apiCallRequest)
        
        // persist data
        let taskId = IterableUtil.generateUUID()
        try persistenceProvider.mainQueueContext().create(task: IterableTask(id: taskId,
                                                                             type: .apiCall,
                                                                             scheduledAt: Date(),
                                                                             data: data,
                                                                             requestedAt: Date()))
        try persistenceProvider.mainQueueContext().save()

        return try persistenceProvider.mainQueueContext().findTask(withId: taskId)
    }

    private let deviceMetadata = DeviceMetadata(deviceId: IterableUtil.generateUUID(),
                                                platform: JsonValue.iOS.jsonStringValue,
                                                appPackageName: Bundle.main.appPackageName ?? "")

    private lazy var persistenceProvider: IterablePersistenceContextProvider = {
        let provider = CoreDataPersistenceContextProvider()
        try! provider.mainQueueContext().deleteAllTasks()
        try! provider.mainQueueContext().save()
        return provider
    }()
}