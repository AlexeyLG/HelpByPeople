//
//  PhotoActionMenuViewController.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/26/20.
//

import UIKit

class PhotoActionMenuViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet private weak var galleryButton: UIButton!
    @IBOutlet private weak var cameraButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var menuBottomConstraint: NSLayoutConstraint!

    //MARK: - Actions
    
    @IBAction func galeryOrCameraButtonDidTap(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
        picker.delegate = self
        
        if sender == galleryButton {
            picker.sourceType = .photoLibrary
        } else if sender == cameraButton {
            picker.sourceType = .camera
        } else {
            fatalError("Sender \(sender) is not identified")
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        toggleMenu()
    }
    
    //MARK: - Properties
    
    var completeHandler: ((UIImage?) -> Void)?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryButton.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 15)
        cameraButton.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 15)
        cancelButton.roundCorners(radius: 15)
        
        galleryButton.setTitle(L10n("Gallery"), for: .normal)
        galleryButton.setTitleColor(.red, for: .normal)
        cameraButton.setTitle(L10n("Camera"), for: .normal)
        
        if Platform.isSimulator {
            cameraButton.isEnabled = false
        } else {
            cameraButton.isEnabled = true
            cameraButton.setTitleColor(.red, for: .normal)
        }
        
        cancelButton.setTitle(L10n("Cancel"), for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toggleMenu()
    }
    
    //MARK: - Utils
    
    func toggleMenu() {
        let present = menuBottomConstraint.priority == UILayoutPriority.defaultHigh
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.menuBottomConstraint.priority = present ? .defaultLow : .defaultHigh
            self.view.layoutIfNeeded()
        },
        completion: { [unowned self] _ in
            if !present {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @objc func didTapBackground() {
        toggleMenu()
    }
}

//MARK: - UIImagePickerControllerDelegate

extension PhotoActionMenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            completeHandler?(image)
        } else {
            completeHandler?(info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
        toggleMenu()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        toggleMenu()
    }
}
