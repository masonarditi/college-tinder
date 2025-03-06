//
//  TinderCloneApp 2.swift
//  TinderClone
//
//  Created by Mason on 3/5/25.
//


@main
struct TinderCloneApp: App {
    @State private var isLoggedIn: Bool
    
    init() {
        FirebaseApp.configure()
        if Auth.auth().currentUser != nil {
            _isLoggedIn = State(initialValue: true)
        } else {
            _isLoggedIn = State(initialValue: false)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                // Now we can pass isLoggedIn
                ContentView(isLoggedIn: $isLoggedIn)
            } else {
                LoginSignUpView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
