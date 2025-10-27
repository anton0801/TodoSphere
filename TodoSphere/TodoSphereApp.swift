import SwiftUI
import AppTrackingTransparency
import Firebase
import FirebaseMessaging
import UserNotifications

@main
struct TodoSphereApp: App {
    
    @StateObject private var taskManager = TaskManager()
    @UIApplicationDelegateAdaptor(TodoSphereAppDelegate.self) var todoSphereAppDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(taskManager)
        }
    }
    
}

class TodoSphereAppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        if let notifPayload = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            retriveAndSend(notifPayload)
        }
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
            }
        }
        return true
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, err in
            if let _ = err {
            }
            UserDefaults.standard.set(token, forKey: "fcm_token")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    // Notification handling
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        retriveAndSend(notification.request.content.userInfo)
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        retriveAndSend(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        retriveAndSend(userInfo)
        completionHandler(.newData)
    }
    
    
    private func retriveAndSend(_ payload: [AnyHashable: Any]) {
        var dataPushParam: String?
        if let link = payload["url"] as? String {
            dataPushParam = link
        } else if let info = payload["data"] as? [String: Any], let link = info["url"] as? String {
            dataPushParam = link
        }
        
        if let retrivedData = dataPushParam {
            
            UserDefaults.standard.set(retrivedData, forKey: "temp_url")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                NotificationCenter.default.post(name: NSNotification.Name("LoadTempURL"), object: nil, userInfo: ["tempUrl": retrivedData])
            }
        }
    }
    
}
