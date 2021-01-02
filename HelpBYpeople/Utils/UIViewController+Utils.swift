//
//  UIViewController+Utils.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/23/20.
//

import UIKit

extension UIViewController {
    
    // errrors & alerts
    
    func showError(title: String = L10n("Error"), _ message: String) {
        let alert = UIAlertController(title: title, message: L10n(message), preferredStyle: .alert)
        let okAction = UIAlertAction(title: L10n("Ok"), style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertLocation() {
        let alert = UIAlertController(title: L10n("gps.off"), message: L10n("turn.gps.on"), preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: L10n("settings"), style: .default) { (alert) in
            if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: L10n("cancel"), style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    func presentPhotoActionMenuViewController(completeHandler: ((UIImage?) -> Void)?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(identifier: "PhotoActionMenuViewController") as? PhotoActionMenuViewController else { return }
        
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        viewController.completeHandler = completeHandler
        
        present(viewController, animated: true, completion: nil)
    }
    
}
