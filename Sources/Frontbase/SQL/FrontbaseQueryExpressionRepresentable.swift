/// Types conforming to this protocol can implement custom logic for converting to
/// a `FrontbaseQuery.Expression`. Conformance to this protocol will be checked when using
/// `FrontbaseQueryExpressionEncoder` and `FrontbaseQueryEncoder`.
///
/// By default, types will encode to `FrontbaseQuery.Expression.data(...)`.
public protocol FrontbaseQueryExpressionRepresentable {
    /// Custom `FrontbaseQuery.Expression` to encode to. 
    var frontbaseQueryExpression: FrontbaseExpression { get }
}
