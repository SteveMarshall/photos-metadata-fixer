import PackageDescription

let package = Package(
    name: "photos-metadata-fixer",
    targets: [
        Target(name: "PhotosMetadataFixerFramework"),
        Target(name: "photos-metadata-fixer",
            dependencies: [
                .Target(name: "PhotosMetadataFixerFramework")
            ]
        )
    ]
)
