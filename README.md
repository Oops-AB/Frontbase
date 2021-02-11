# Frontbase for Vapor

## Prerequisites

This package is Swift wrapper for *FBCAccess* – the official C library for Frontbase –, which must be installed separately before using it in Swift projects.

_Note: the database itself does not need to be running, only the header and library files matter._

### Install Frontbase

Download an appropriate installer from the Frontbase [download page](http://www.frontbase.com/cgi-bin/WebObjects/FBWebSite).

### Setup Frontbase for pkgConfig

Swift requires a [pkgConfig](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#pkgconfig) configuration to find the header and library files.

Run the provided `setupFBCAccess.sh` script to install the required configuration file. It will `sudo`, so use an account that's in `sudoers`.

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

