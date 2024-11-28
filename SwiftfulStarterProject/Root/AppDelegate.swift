//
//  AppDelegate.swift
//  SwiftfulStarterProject
//
//  
//
import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    var builder: Builder!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        var config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: false)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        if Utilities.isUITesting {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            config = .mock(isSignedIn: isSignedIn)
        }
        
        config.configure()
        let dependencies = Dependencies(config: config)
        self.dependencies = dependencies
        self.builder = CoreBuilder(interactor: CoreInteractor(container: dependencies.container))
        return true
    }    
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            // Mock build does NOT run Firebase
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}
