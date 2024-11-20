//
//  Extensions.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 07/05/23.
//

import Foundation
import UIKit

extension String {
    
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DATE_FORMAT
        return dateFormatter.date(from: self)
    }
    
    func getImageURL() -> URL? {
        let fullURLString = "\(Constants.IMAGE_BASE_URL)\(self)"
        return URL(string: fullURLString)
    }
}

extension UIView {
    
    func addBlurEffect(with blurStyle: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}

extension UIViewController {
    func showErrorAlert(with description: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = .label
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            handler()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoginAlert(with description: String, actionTitle: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: description, preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = .label
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: { _ in
            handler()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
