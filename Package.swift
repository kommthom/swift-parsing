// swift-tools-version:6.0
import PackageDescription

let package = Package(
	name: "swift-parsing",
	platforms: [
		.iOS(.v18),
		.macOS(.v15),
		.tvOS(.v16),
		.watchOS(.v8),
	],
	products: [
		.library(
			name: "Parsing",
			targets: ["Parsing"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
		.package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.5.5"),
		.package(url: "https://github.com/google/swift-benchmark", from: "0.1.1"),
		.package(name: "Thoms.Foundation", path: "../Thoms.Foundation")
	],
	targets: [
		.target(
			name: "Parsing",
			dependencies: [
				.product(
					name: "CasePaths",
					package: "swift-case-paths"
				),
				.product(
					name: "Thoms.Foundation",
					package: "Thoms.Foundation"
				)
			]
		),
		.testTarget(
			name: "ParsingTests",
			dependencies: [
				"Parsing"
			]
		),
		.executableTarget(
			name: "swift-parsing-benchmark",
			dependencies: [
				"Parsing",
				.product(name: "Benchmark", package: "swift-benchmark"),
			]
		),
	]
)
