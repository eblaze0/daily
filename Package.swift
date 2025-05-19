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
        // Dependencies go here
        // We'll add Supabase SDK later
    ],
    targets: [
        .target(
            name: "DailyFitnessApp",
            dependencies: [],
            path: ".",
            exclude: ["README.md", "Package.swift"]
        ),
        .testTarget(
            name: "DailyFitnessAppTests",
            dependencies: ["DailyFitnessApp"],
            path: "Tests"
        ),
    ]
) 