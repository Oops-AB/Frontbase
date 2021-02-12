/// See `SQLQuery`.
public typealias FrontbaseBinaryOperator = GenericSQLBinaryOperator

/// See `SQLQuery`.
public typealias FrontbaseColumnIdentifier = GenericSQLColumnIdentifier<
    FrontbaseTableIdentifier, FrontbaseIdentifier
>

/// See `SQLQuery`.
public typealias FrontbaseCreateIndex = GenericSQLCreateIndex<
    FrontbaseIndexModifier, FrontbaseIdentifier, FrontbaseColumnIdentifier
>

/// See `SQLQuery`.
public typealias FrontbaseDelete = GenericSQLDelete<
    FrontbaseTableIdentifier, FrontbaseExpression
>

/// See `SQLQuery`.
public typealias FrontbaseDirection = GenericSQLDirection

/// See `SQLQuery`.
public typealias FrontbaseDistinct = GenericSQLDistinct

/// See `SQLQuery`.
public typealias FrontbaseExpression = GenericSQLExpression<
    FrontbaseLiteral, FrontbaseBind, FrontbaseColumnIdentifier, FrontbaseBinaryOperator, FrontbaseFunction, FrontbaseQuery
>

/// See `SQLQuery`.
public typealias FrontbaseForeignKey = GenericSQLForeignKey<
    FrontbaseTableIdentifier, FrontbaseIdentifier, FrontbaseForeignKeyAction
>

/// See `SQLQuery`.
public typealias FrontbaseForeignKeyAction = GenericSQLForeignKeyAction

/// See `SQLQuery`.
public typealias FrontbaseGroupBy = GenericSQLGroupBy<FrontbaseExpression>

/// See `SQLQuery`.
public typealias FrontbaseIdentifier = GenericSQLIdentifier

/// See `SQLQuery`.
public typealias FrontbaseIndexModifier = GenericSQLIndexModifier

/// See `SQLQuery`.
public typealias FrontbaseInsert = GenericSQLInsert<
    FrontbaseTableIdentifier, FrontbaseColumnIdentifier, FrontbaseExpression
>

/// See `SQLQuery`.
public typealias FrontbaseJoin = GenericSQLJoin<
    FrontbaseJoinMethod, FrontbaseTableIdentifier, FrontbaseExpression
>

/// See `SQLQuery`.
public typealias FrontbaseJoinMethod = GenericSQLJoinMethod

/// See `SQLQuery`.
public typealias FrontbaseLiteral = GenericSQLLiteral<FrontbaseDefaultLiteral, FrontbaseBoolLiteral>

/// See `SQLQuery`.
public typealias FrontbaseOrderBy = GenericSQLOrderBy<FrontbaseExpression, FrontbaseDirection>

/// See `SQLQuery`.
public typealias FrontbaseSelectExpression = GenericSQLSelectExpression<FrontbaseExpression, FrontbaseIdentifier, FrontbaseTableIdentifier>

/// See `SQLQuery`.
public typealias FrontbaseTableConstraintAlgorithm = GenericSQLTableConstraintAlgorithm<
    FrontbaseIdentifier, FrontbaseExpression, FrontbaseCollation, FrontbaseForeignKey
>

/// See `SQLQuery`.
public typealias FrontbaseTableConstraint = GenericSQLTableConstraint<
    FrontbaseIdentifier, FrontbaseTableConstraintAlgorithm
>

/// See `SQLQuery`.
public typealias FrontbaseTableIdentifier = GenericSQLTableIdentifier<FrontbaseIdentifier>

/// See `SQLQuery`.
public typealias FrontbaseUpdate = GenericSQLUpdate<
    FrontbaseTableIdentifier, FrontbaseIdentifier, FrontbaseExpression
>
