//
//  Created by Tapash Majumder on 7/30/20.
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

enum IterableTaskError: Error {
    case general(String?)
    
    static func createErroredFuture<T>(reason: String? = nil) -> Future<T, IterableTaskError> {
        Promise<T, IterableTaskError>(error: IterableTaskError.general(reason))
    }
}

extension IterableTaskError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .general(description):
            return description ?? "general error"
        }
    }
}