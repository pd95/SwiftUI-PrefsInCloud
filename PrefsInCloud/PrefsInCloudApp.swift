//
//  PrefsInCloudApp.swift
//  PrefsInCloud
//
//  Created by Philipp on 14.04.2024.
//

import SwiftUI

let gBackgroundColorKey = "backgroundColor"

@main
struct PrefsInCloudApp: App {
    @AppStorage(gBackgroundColorKey) var chosenColorValue: Int = 0

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: chosenColorValue) { oldValue, newValue in
                    print("Background color changed to ", newValue)
                    print("Synching value with iCloud")
                    NSUbiquitousKeyValueStore.default.set(chosenColorValue, forKey: gBackgroundColorKey)
                }
                .task {
                    await setupCloudNotifications()
                }
        }
    }

    private func setupCloudNotifications() async {
        print(#function)
        // Create a background task to observe notifications
        Task {
            for await userInfo in NotificationCenter.default
                .notifications(named: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
                .compactMap({ notification in
                    notification.userInfo
                })
            {
                guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { continue }
                switch reasonForChange {
                case NSUbiquitousKeyValueStoreServerChange:
                    print("\(#function): Server change")
                case NSUbiquitousKeyValueStoreInitialSyncChange:
                    print("\(#function): Initial Sync change")
                case NSUbiquitousKeyValueStoreQuotaViolationChange:
                    print("\(#function): Quota Violation change")
                case NSUbiquitousKeyValueStoreAccountChange:
                    print("\(#function): Account change")
                default:
                    print("\(#function): Unsupported change iCloud KVS change reason: \(reasonForChange)")
                    continue
                }

                // Check if any of the keys we care about were updated, and if so use the new value stored under that key.
                guard let keys =
                    userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }

                guard keys.contains(gBackgroundColorKey) else { return }

                if reasonForChange == NSUbiquitousKeyValueStoreAccountChange {
                    // User changed account, so fall back to use UserDefaults (last color saved).
                    continue
                }

                let possibleColorIndexFromiCloud =
                    NSUbiquitousKeyValueStore.default.longLong(forKey: gBackgroundColorKey)

                if let validColorIndex = ColorIndex(rawValue: Int(possibleColorIndexFromiCloud)) {
                    withAnimation {
                        chosenColorValue = validColorIndex.rawValue
                    }
                    print("set chosenColorValue to ", validColorIndex, chosenColorValue)
                    continue
                }

                /** The value isn't something we can understand.
                     The best way to handle an unexpected value depends on what the value represents, and what your app does.
                      good rule of thumb is to ignore values you can not interpret and not apply the update.
                 */
                Swift.debugPrint("WARNING: Invalid \(gBackgroundColorKey) value,")
                Swift.debugPrint("of \(possibleColorIndexFromiCloud) received from iCloud. This value will be ignored.")
            }
        }

        // allow previously started task to catch on
        await Task.yield()

        print("synching with iCloud")
        // Request cloud synchronization
        if NSUbiquitousKeyValueStore.default.synchronize() == false {
            fatalError("This app was not built with the proper entitlement requests.")
        }
    }
}
