# Frontbase for Vapor

## Prerequisites

The Frontbase C libraries must be installed in order to use this package.  
Follow the [README of the CFBCAccess repo](https://github.com/Oops-AB/CFBCAccess/README.md) to get started.

## Using Frontbase

This section outlines how to import the Frontbase package for use in a Vapor project.

Include the Frontbase package in your project's `Package.swift` file.

```swift
import PackageDescription

let package = Package(
    name: "Project",
    dependencies: [
        .package (url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package (url: "https://github.com/Oops-AB/Frontbase.git", from: "1.0.0"),
    ],
    targets: [ ... ]
)
```

The Frontbase package adds Frontbase access to your project, either directly or by using the Fluent ORM.

# Examples

## Setting up the Database

```swift
import Frontbase

	// Configure a Frontbase database
	let frontbase = FrontbaseDatabase (name: "Universe", onHost: "localhost", username: "_system", password: "secret")

	/// Register the configured Frontbase database to the database config.
	var databases = DatabasesConfig()
	databases.add (database: frontbase, as: .frontbase)
	services.register (databases)
	services.register (Databases.self)
)
```

## Querying using Fluent ORM

```swift
	router.get ("planets", Int.parameter) { req -> Future<View> in
        let galaxyID = try req.parameters.next (Int.self)
        return req.withNewConnection (to: .frontbase) { conn in
            return conn.select()
                .column (.column (\Planet.id))
                .column (.column (\Planet.name))
                .from (Planet.self)
                .where (\Planet.galaxyId == galaxyID)
                .orderBy (\Planet.name)
                .all (decoding: Planet.self)
	    }.flatMap { (rows: [Planet]) -> Future<View> in
	        return try req.view().render ("planets", [
	        	"planets": rows
	        ])
	    }
	}
```

## Raw SQL

```swift
	router.get ("planets", Int.parameter) { req -> Future<View> in
        let galaxyID = try req.parameters.next (Int.self)
        return req.withNewConnection (to: .frontbase) { conn in
	        return conn.raw("SELECT id, name FROM Planet WHERE galaxyID = ? ORDER BY name;")
                .bind (galaxyID)
	            .all (decoding: Planet.self)
	    }.flatMap { (rows: [Planet]) -> Future<View> in
	        return try req.view().render ("planets", [
	        	"planets": rows
	        ])
	    }
	}
```

## Contributors

