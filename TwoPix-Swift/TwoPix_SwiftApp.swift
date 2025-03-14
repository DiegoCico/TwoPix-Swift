//
//  TwoPix_SwiftApp.swift
//  TwoPix-Swift
//
//  Created by Diego Cicotoste on 3/14/25.
//

import SwiftUI
import Firebase

@main
struct TwoPixApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AuthView() 
        }
    }
}

