// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DailyFitnessApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DailyFitnessApp",
            targets: ["DailyFitnessApp"]),
    ],
    dependencies: [
        // Supabase Swift SDK
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "DailyFitnessApp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "Auth", package: "supabase-swift"),
                .product(name: "Storage", package: "supabase-swift"),
                .product(name: "Functions", package: "supabase-swift"),
                .product(name: "Realtime", package: "supabase-swift")
            ],
            path: ".",
            exclude: ["README.md", "Package.swift", "supabase_schema.sql"]
        ),
        .testTarget(
            name: "DailyFitnessAppTests",
            dependencies: ["DailyFitnessApp"],
            path: "Tests"
        ),
    ]
) 