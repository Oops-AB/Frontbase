//
//  FrontbaseConnectionSource.swift
//  
//
//  Created by Johan Carlberg on 2019-10-09.
//

import NIO
import Logging

public final class FrontbaseConnectionSource: ConnectionPoolSource {
    public typealias Connection = FrontbaseConnection
    
    private let storage: FrontbaseConnection.Storage
    private let threadPool: NIOThreadPool

    public init (configuration: FrontbaseConfiguration,
                 threadPool: NIOThreadPool) {
        self.storage = configuration.storage
        self.threadPool = threadPool
    }

    public func makeConnection (logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<FrontbaseConnection> {
        return FrontbaseConnection.open (storage: self.storage, threadPool: self.threadPool, logger: logger, on: eventLoop)
    }
}

public struct FrontbaseConfiguration {

    public var storage: FrontbaseConnection.Storage

    public init (storage: FrontbaseConnection.Storage) {
        self.storage = storage
    }
}

extension FrontbaseConnection: @retroactive ConnectionPoolItem { }


private extension ObjectIdentifier {
    var unique: String {
        let raw = "\(self)"
        let parts = raw.split (separator: "(")
        switch parts.count {
        case 2:
            return parts[1].split (separator: ")").first.flatMap (String.init) ?? raw
        default:
            return raw
        }
    }
}
