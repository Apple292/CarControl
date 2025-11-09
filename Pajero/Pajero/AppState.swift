//
//  AppState.swift
//  Pajero
//
//  Created by Aiden Wood on 2/2/2025.
//

import Foundation

public class AppState: ObservableObject {
    public static let shared = AppState()
    @Published var settingOpen: Bool = false
    @Published var logsOpen: Bool = false
    @Published var NetworkStatsenabled: Bool = false
      
      private init() { }
}
