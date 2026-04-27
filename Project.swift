import ProjectDescription

let deploymentTargets: DeploymentTargets = .iOS("26.0")

let baseSettings: SettingsDictionary = [
    "SWIFT_VERSION": "6.0",
    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
]

let appInfoPlist: [String: Plist.Value] = [
    "CFBundleDisplayName": "Rook",
    "CFBundleShortVersionString": "1.0.0",
    "CFBundleVersion": "1",
    "UILaunchScreen": [:],
    "UIApplicationSceneManifest": [
        "UIApplicationSupportsMultipleScenes": false,
    ],
    "UISupportedInterfaceOrientations": [
        "UIInterfaceOrientationPortrait",
    ],
]

let project = Project(
    name: "Rook",
    organizationName: "Rook Games",
    options: .options(
        defaultKnownRegions: ["en"],
        developmentRegion: "en"
    ),
    settings: .settings(
        base: baseSettings,
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "Rook",
            destinations: .iOS,
            product: .app,
            bundleId: "com.rookgames.rook",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: appInfoPlist),
            sources: ["Rook/Sources/**"],
            resources: ["Rook/Resources/**"],
            dependencies: [
                .external(name: "CasePaths"),
                .external(name: "Dependencies"),
                .external(name: "DependenciesMacros"),
                .external(name: "IdentifiedCollections"),
                .external(name: "IssueReporting"),
                .external(name: "Sharing"),
                .external(name: "SwiftNavigation"),
                .external(name: "SwiftUINavigation"),
                .external(name: "Tagged"),
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "Rook",
            shared: true,
            buildAction: .buildAction(targets: ["Rook"]),
            runAction: .runAction(configuration: .debug, executable: "Rook")
        ),
    ]
)
