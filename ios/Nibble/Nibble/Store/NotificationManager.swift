//
//  NotificationManager.swift
//  Nibble — Sprout Snacks
//
//  Gentle, opt-in local reminders ("time to log lunch?"). No server involved.
//

import Foundation
import UserNotifications

enum NotificationManager {

    static func requestAuthorization(_ completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async { completion?(granted) }
            }
    }

    /// Three soft nudges across the day. Kept supportive in tone.
    static func scheduleMealReminders() {
        requestAuthorization { granted in
            guard granted else { return }
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()

            let nudges: [(hour: Int, minute: Int, body: String)] = [
                (9,  0,  "Good morning! Want to log breakfast? 🌅"),
                (13, 0,  "Time to log lunch? Your Sprout is curious. 🥪"),
                (19, 0,  "Dinner check-in — log whenever you're ready. 🍽️")
            ]

            for n in nudges {
                let content = UNMutableNotificationContent()
                content.title = "Nibble"
                content.body = n.body
                content.sound = .default

                var comps = DateComponents()
                comps.hour = n.hour
                comps.minute = n.minute
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                let request = UNNotificationRequest(identifier: "nibble.meal.\(n.hour)",
                                                    content: content, trigger: trigger)
                center.add(request)
            }
        }
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
