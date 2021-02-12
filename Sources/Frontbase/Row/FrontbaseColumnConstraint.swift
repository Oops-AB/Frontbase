/// Frontbase specific implementation of `SQLColumnConstraint`.

public struct FrontbaseColumnConstraint: SQLColumnConstraint
{
    public typealias Identifier = FrontbaseIdentifier
    public typealias Algorithm = FrontbaseColumnConstraintAlgorithm

    /// See `SQLColumnConstraint`.
    public static func constraint(_ algorithm: Algorithm, _ identifier: Identifier?) -> FrontbaseColumnConstraint {
        return .init(identifier: identifier, algorithm: algorithm)
    }

    /// See `SQLColumnConstraint`.
    public var identifier: Identifier?

    /// See `SQLColumnConstraint`.
    public var algorithm: Algorithm

    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        if let identifier = self.identifier {
            return "CONSTRAINT " + identifier.serialize(&binds) + " " + algorithm.serialize(&binds)
        } else {
            return algorithm.serialize(&binds)
        }
    }
}

extension FrontbaseColumnConstraint: Comparable {

    public static func == (lhs: FrontbaseColumnConstraint, rhs: FrontbaseColumnConstraint) -> Bool {
        return lhs.algorithm == rhs.algorithm
    }

    public static func < (lhs: FrontbaseColumnConstraint, rhs: FrontbaseColumnConstraint) -> Bool {
        return !(lhs == rhs) && (lhs.algorithm < rhs.algorithm)
    }
}
