//
//  FrontbaseDialect.swift
//  
//
//  Created by Johan Carlberg on 2019-10-09.
//

struct FrontbaseDialect: SQLDialect {
    var name: String {
        return "frontbase"
    }

    var identifierQuote: SQLExpression {
        return SQLRaw("\"")
    }

    var literalStringQuote: SQLExpression {
        return SQLRaw("'")
    }

    var autoIncrementClause: SQLExpression {
        return SQLRaw("")
    }
    var autoIncrementFunction: SQLExpression? {
        return SQLRaw("UNIQUE")
    }

    var supportsAutoIncrement: Bool {
        return true
    }

    func bindPlaceholder (at position: Int) -> SQLExpression {
        return SQLRaw ("?")
    }
    
    func literalBoolean(_ value: Bool) -> SQLExpression {
        switch value {
            case true: return SQLRaw("TRUE")
            case false: return SQLRaw("FALSE")
        }
    }

    var supportsIfExists: Bool {
        return false
    }

    var enumSyntax: SQLEnumSyntax {
        return .unsupported
    }

    var supportsDropBehaviour: Bool {
        return true
    }
}
