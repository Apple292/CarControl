//
//  AppDelegate.swift
//  Pajero
//
//  Created by Aiden Wood on 4/3/2025.
//

import UIKit
import UserNotifications


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request authorization
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                if granted {
                    print("Notification permission granted")
                    DispatchQueue.main.async {
                        // Register with APNs
                        application.registerForRemoteNotifications()
                    }
                } else {
                    print("Notification permission denied: \(String(describing: error))")
                }
            }
        )
        
        // Check if launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            print("App launched from notification: \(notification)")
            handleNotification(notification)
        }
        
        return true
    }
    
    
    // MARK: - Core Data
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.shared.saveContext()
    }
    
    // MARK: - APNs Registration
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // Send to your server
        // sendTokenToServer(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    
    
    // MARK: - Notification Handling
    
    // App in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received notification in foreground: \(userInfo)")
        
        // Process notification data
        if let aps = userInfo["aps"] as? [String: Any] {
            print("APS content: \(aps)")
        }
        
        // Show the notification in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // User tapped notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("User tapped notification: \(userInfo)")
        
        handleNotification(userInfo as? [String: AnyObject] ?? [:])
        
        completionHandler()
    }
    
    // App in background
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Background notification received: \(userInfo)")
        
        // Process data
        if let aps = userInfo["aps"] as? [String: Any] {
            print("APS content: \(aps)")
        }
        
        handleNotification(userInfo as? [String: AnyObject] ?? [:])
        
        completionHandler(.newData)
    }
    
    // MARK: - Helper Methods
    
    private func handleNotification(_ userInfo: [String: AnyObject]) {
        // Extract custom data
        if let customData = userInfo["custom_data"] as? String {
            print("Custom data: \(customData)")
        }
        
        // Extract category to determine action
        if let category = userInfo["category"] as? String {
            switch category {
            case "message":
                navigateToMessages()
            case "update":
                checkForUpdates()
            default:
                break
            }
        }
    }
    
    private func navigateToMessages() {
        // Navigate to messages screen
        print("Would navigate to messages screen")
    }
    
    private func checkForUpdates() {
        // Check for updates
        print("Would check for updates")
    }
    
    
    // MARK: - UISceneSession Lifecycle (for iOS 13+)
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // If launched from notification in iOS 13+
        if let userActivity = options.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("Launched from notification via user activity")
        }
        
        if let notificationResponse = options.notificationResponse {
            let userInfo = notificationResponse.notification.request.content.userInfo
            print("Launched from notification in iOS 13+: \(userInfo)")
        }
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
