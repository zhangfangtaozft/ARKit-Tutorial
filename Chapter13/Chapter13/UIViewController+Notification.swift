//
//  UIViewController+Notification.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/9/9.
//  Copyright © 2019 Frank. All rights reserved.
//

import UIKit
import UserNotifications

extension UIViewController {
    func showAlert(with id: String, title: String, message: String) {
        if UIApplication.shared.applicationState == .active {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            content.sound = UNNotificationSound.default
            let notification = UNNotificationRequest(identifier: id, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
        }
    }
}
