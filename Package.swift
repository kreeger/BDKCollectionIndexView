// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "BDKCollectionIndexView",
	platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "BDKCollectionIndexView",
            targets: ["BDKCollectionIndexView"])
    ],
	targets: [
        .target(
           name: "BDKCollectionIndexView",
           path: "Sources/BDKCollectionIndexView",
           publicHeadersPath: "."
        )
    ]
)
