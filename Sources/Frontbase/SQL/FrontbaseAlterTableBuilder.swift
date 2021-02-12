extension SQLAlterTableBuilder where Connectable.Connection.Query.AlterTable == FrontbaseAlterTable {
    /// Renames the table.
    ///
    ///     conn.alter(table: Bar.self).rename(to: "foo").run()
    ///
    /// - parameters:
    ///     - to: New table name.
    /// - returns: Self for chaining.
    public func rename(to tableName: FrontbaseTableIdentifier) -> Self {
        alterTable.value = .rename(tableName)
        return self
    }

    /// Adds a new column to the table. Only one column can be added per `ALTER` statement.
    ///
    ///     conn.alter(table: Planet.self).addColumn(for: \.name, type: .text, .notNull).run()
    ///
    /// - parameters:
    ///     - keyPath: Swift `KeyPath` to property that should be added.
    ///     - type: Name of type to use for this column.
    ///     - constraints: Zero or more column constraints to add.
    /// - returns: Self for chaining.
    public func addColumn<T, V>(
        for keyPath: KeyPath<T, V>,
        type dataType: FrontbaseDataType,
        _ constraints: FrontbaseColumnConstraint...
        ) -> Self where T: FrontbaseTable {
        return addColumn(.columnDefinition(.keyPath(keyPath), dataType, constraints.sorted()))
    }

    /// Adds a new column to the table. Only one column can be added per `ALTER` statement.
    ///
    ///     conn.alter(table: Planet.self).addColumn(...).run()
    ///
    /// - parameters:
    ///     - columnDefinition: Column definition to add.
    /// - returns: Self for chaining.
    public func addColumn(_ columnDefinition: FrontbaseColumnDefinition) -> Self {
        alterTable.value = .addColumn(columnDefinition)
        return self
    }
}
