// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisApp",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "JarvisApp",
            path: "Sources/JarvisApp",
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/JarvisApp/Info.plist",
                ])
            ]
        )
    ]
)
