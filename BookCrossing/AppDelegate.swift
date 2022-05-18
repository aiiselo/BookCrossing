//
//  AppDelegate.swift
//  BookCrossing
//
//  Created by Олеся Мартынюк on 18.05.2022.
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var value: String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        self.value = "test" // in any callback use your published property
        return true
    }
}
