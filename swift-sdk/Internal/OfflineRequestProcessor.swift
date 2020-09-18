//
//  Created by Tapash Majumder on 8/24/20.
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
struct OfflineRequestProcessor: RequestProcessorProtocol {
    init(apiKey: String,
         authProvider: AuthProvider,
         authManager: IterableInternalAuthManagerProtocol?,
         endPoint: String,
         deviceMetadata: DeviceMetadata,
         taskRunner: IterableTaskRunner = IterableTaskRunner(),
         notificationCenter: NotificationCenterProtocol
         ) {
        self.apiKey = apiKey
        self.authProvider = authProvider
        self.authManager = authManager
        self.endPoint = endPoint
        self.deviceMetadata = deviceMetadata
        self.taskRunner = taskRunner
        notificationListener = NotificationListener(notificationCenter: notificationCenter)
    }
    
    func start() {
        ITBInfo()
        taskRunner.start()
    }
    
    func stop(){
        ITBInfo()
        taskRunner.stop()
    }
    
    @discardableResult
    func register(registerTokenInfo: RegisterTokenInfo,
                  notificationStateProvider: NotificationStateProviderProtocol,
                  onSuccess: OnSuccessHandler? = nil,
                  onFailure: OnFailureHandler? = nil) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createRegisterTokenRequest(registerTokenInfo: registerTokenInfo,
                                                      notificationsEnabled: true)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func disableDeviceForCurrentUser(hexToken: String,
                                     withOnSuccess onSuccess: OnSuccessHandler? = nil,
                                     onFailure: OnFailureHandler? = nil) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createDisableDeviceRequest(forAllUsers: false, hexToken: hexToken)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func disableDeviceForAllUsers(hexToken: String,
                                  withOnSuccess onSuccess: OnSuccessHandler?,
                                  onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createDisableDeviceRequest(forAllUsers: true, hexToken: hexToken)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func updateUser(_ dataFields: [AnyHashable: Any],
                    mergeNestedObjects: Bool,
                    onSuccess: OnSuccessHandler?,
                    onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createUpdateUserRequest(dataFields: dataFields, mergeNestedObjects: mergeNestedObjects)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func updateEmail(_ newEmail: String,
                     onSuccess: OnSuccessHandler?,
                     onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createUpdateEmailRequest(newEmail: newEmail)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackPurchase(_ total: NSNumber,
                       items: [CommerceItem],
                       dataFields: [AnyHashable: Any]?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackPurchaseRequest(total,
                                                      items: items,
                                                      dataFields: dataFields)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber?,
                       messageId: String,
                       appAlreadyRunning: Bool,
                       dataFields: [AnyHashable: Any]?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackPushOpenRequest(campaignId,
                                                      templateId: templateId,
                                                      messageId: messageId,
                                                      appAlreadyRunning: appAlreadyRunning,
                                                      dataFields: dataFields)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(event: String,
               dataFields: [AnyHashable: Any]?,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Future<SendRequestValue, SendRequestError> {
        ITBInfo()
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackEventRequest(event,
                                                   dataFields: dataFields)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func updateSubscriptions(info: UpdateSubscriptionsInfo,
                             onSuccess: OnSuccessHandler?,
                             onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createUpdateSubscriptionsRequest(info.emailListIds,
                                                            unsubscribedChannelIds: info.unsubscribedChannelIds,
                                                            unsubscribedMessageTypeIds: info.unsubscribedMessageTypeIds,
                                                            subscribedMessageTypeIds: info.subscribedMessageTypeIds,
                                                            campaignId: info.campaignId,
                                                            templateId: info.templateId)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackInAppOpen(_ message: IterableInAppMessage,
                        location: InAppLocation,
                        inboxSessionId: String?,
                        onSuccess: OnSuccessHandler?,
                        onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppOpenRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                     location: location,
                                                                                                     inboxSessionId: inboxSessionId))
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackInAppClick(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         clickedUrl: String,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppClickRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                      location: location,
                                                                                                      inboxSessionId: inboxSessionId),
                                                        clickedUrl: clickedUrl)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackInAppClose(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         source: InAppCloseSource?,
                         clickedUrl: String?,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppCloseRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                      location: location,
                                                                                                      inboxSessionId: inboxSessionId),
                                                        source: source,
                                                        clickedUrl: clickedUrl)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(inboxSession: IterableInboxSession,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInboxSessionRequest(inboxSession: inboxSession)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(inAppDelivery message: IterableInAppMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppDeliveryRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                         location: nil))
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func inAppConsume(_ messageId: String,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createInAppConsumeRequest(messageId)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func inAppConsume(message: IterableInAppMessage,
                      location: InAppLocation,
                      source: InAppDeleteSource?,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppConsumeRequest(inAppMessageContext: InAppMessageContext.from(message: message, location: location),
                                                          source: source)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    // MARK: DEPRECATED
    
    @discardableResult
    func trackInAppOpen(_ messageId: String,
                        onSuccess: OnSuccessHandler?,
                        onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppOpenRequest(messageId)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackInAppClick(_ messageId: String,
                         clickedUrl: String,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Future<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppClickRequest(messageId, clickedUrl: clickedUrl)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    private let apiKey: String
    private weak var authProvider: AuthProvider?
    private weak var authManager: IterableInternalAuthManagerProtocol?
    private let endPoint: String
    private let deviceMetadata: DeviceMetadata
    private let notificationListener: NotificationListener
    private let taskRunner: IterableTaskRunner
    
    private func createRequestCreator(authProvider: AuthProvider) -> RequestCreator {
        return RequestCreator(apiKey: apiKey, auth: authProvider.auth, deviceMetadata: deviceMetadata)
    }
    
    private func sendIterableRequest(requestGenerator: (RequestCreator) -> Result<IterableRequest, IterableError>,
                                     successHandler onSuccess: OnSuccessHandler?,
                                     failureHandler onFailure: OnFailureHandler?,
                                     identifier: String) -> Future<SendRequestValue, SendRequestError> {
        guard let authProvider = authProvider else {
            fatalError("authProvider is missing")
        }
        
        let requestCreator = createRequestCreator(authProvider: authProvider)
        guard case let Result.success(iterableRequest) = requestGenerator(requestCreator) else {
                return SendRequestError.createErroredFuture(reason: "Could not create request")
        }

        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endPoint: endPoint,
                                                    auth: authProvider.auth,
                                                    deviceMetadata: deviceMetadata,
                                                    iterableRequest: iterableRequest)
        
        do {
            let taskId = try IterableTaskScheduler().schedule(apiCallRequest: apiCallRequest,
                                                              context: IterableTaskContext(blocking: true))
            let result = notificationListener.futureFromTask(withTaskId: taskId)
            return RequestProcessorUtil.apply(successHandler: onSuccess,
                                       andFailureHandler: onFailure,
                                       andAuthManager: authManager,
                                       toResult: result,
                                       withIdentifier: identifier)
        } catch let error {
            ITBError(error.localizedDescription)
            return SendRequestError.createErroredFuture(reason: error.localizedDescription)
        }
    }
    
    private class NotificationListener: NSObject {
        init(notificationCenter: NotificationCenterProtocol) {
            self.notificationCenter = notificationCenter
            super.init()
            self.notificationCenter.addObserver(self,
                                                selector: #selector(onTaskFinishedWithSuccess(notification:)),
                                                name: .iterableTaskFinishedWithSuccess, object: nil)
            self.notificationCenter.addObserver(self,
                                                selector: #selector(onTaskFinishedWithNoRetry(notification:)),
                                                name: .iterableTaskFinishedWithNoRetry, object: nil)
        }
        
        deinit {
            self.notificationCenter.removeObserver(self)
        }
        
        func futureFromTask(withTaskId taskId: String) -> Future<SendRequestValue, SendRequestError> {
            ITBInfo()
            let result = Promise<SendRequestValue, SendRequestError>()
            pendingTasksMap[taskId] = result
            return result
        }

        @objc
        private func onTaskFinishedWithSuccess(notification: Notification) {
            ITBInfo()
            if let taskSendRequestValue = IterableNotificationUtil.notificationToTaskSendRequestValue(notification) {
                let taskId = taskSendRequestValue.taskId
                ITBInfo("task: \(taskId) finished with success")
                if let promise = pendingTasksMap[taskId] {
                    promise.resolve(with: taskSendRequestValue.sendRequestValue)
                    pendingTasksMap.removeValue(forKey: taskId)
                } else {
                    ITBError("could not find promise for taskId: \(taskId)")
                }
            } else {
                ITBError("Could not find taskId for notification")
            }
        }

        @objc
        private func onTaskFinishedWithNoRetry(notification: Notification) {
            ITBInfo()
            if let taskSendRequestError = IterableNotificationUtil.notificationToTaskSendRequestError(notification) {
                let taskId = taskSendRequestError.taskId
                ITBInfo("task: \(taskId) finished with no retry")
                if let promise = pendingTasksMap[taskId] {
                    promise.reject(with: taskSendRequestError.sendRequestError)
                    pendingTasksMap.removeValue(forKey: taskId)
                } else {
                    ITBError("could not find promise for taskId: \(taskId)")
                }
            } else {
                ITBError("Could not find taskId for notification")
            }
        }

        private let notificationCenter: NotificationCenterProtocol
        private var pendingTasksMap = [String: Promise<SendRequestValue, SendRequestError>]()
    }
}