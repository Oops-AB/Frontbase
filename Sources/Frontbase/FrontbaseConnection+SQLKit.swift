//
//  FrontbaseConnection+SQLKit.swift
//  
//
//  Created by Johan Carlberg on 2019-10-09.
//

extension FrontbaseConnection: SQLDatabase {
    public var dialect: SQLDialect {
        return FrontbaseDialect()
    }
    
    public func execute (sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer (database: self)
        query.serialize (to: &serializer)
        let binds: [FrontbaseData]
        do {
            binds = try serializer.binds.map { encodable in
                return try FrontbaseDataEncoder().encode (encodable)
            }
        } catch {
            return self.eventLoop.makeFailedFuture (error)
        }
        return self.query (serializer.sql, binds) { row in
            onRow (row)
        }
    }
}

extension FrontbaseConnection {
    public func sql() -> SQLDatabase {
        self
    }
}
