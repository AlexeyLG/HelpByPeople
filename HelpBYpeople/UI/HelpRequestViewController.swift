//
//  HelpRequestViewController.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/24/20.
//

import UIKit
import MapKit
import Firebase

class HelpRequestViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var incNameTextField: UITextField!
    @IBOutlet weak var incDescriptionTextField: UITextField!
    @IBOutlet weak var incPhotoImageView: UIImageView!
    @IBOutlet weak var addIncPhotoButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var createAnnotationIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findAddressTextField: UITextField!
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private let regionInMeters: Double = 22000
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        incNameTextField.delegate = self
        incDescriptionTextField.delegate = self
        findAddressTextField.delegate = self
        
        checkLocationServices()
        mapView.restrictMap(MapViewController.locationBelarus)

        navigationItem.title = L10n("help.request")
        incNameTextField.placeholder = L10n("incident.name")
        incDescriptionTextField.placeholder = L10n("incident.description")
        addIncPhotoButton.setTitle(L10n("add.photo"), for: .normal)
        findAddressTextField.placeholder = L10n("enter.address")
        
        createAnnotationIndicator.isHidden = true
        
        //UITapGestureRecognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        
        let tapGestureRecodnizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        incPhotoImageView.isUserInteractionEnabled = true
        incPhotoImageView.addGestureRecognizer(tapGestureRecodnizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
       }
    
    @objc private func presentPhotoActionMenu() {
        presentPhotoActionMenuViewController() { [weak self] image in
            self?.incPhotoImageView.image = image
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        presentPhotoActionMenu()
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        createAnnotation()
    }
    
    @IBAction func addIncPhotoDidTap(_ sender: Any) {
        presentPhotoActionMenu()
    }
    
    @IBAction func findButtonDidTap(_ sender: Any) {
        setCameraToAddress()
    }
    
    @IBAction func userLocationButtonDidTap(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    // MARK: - Private | Location Helpers
    
    func askLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            showAlertLocation()
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
           startTrackingUserLocation()
        case .restricted, .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("Error location authorization")
        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Private | Firebase save
    
    private func createAnnotation() {
        guard let title = incNameTextField.text,
              let subtitle = incDescriptionTextField.text,
              let image = incPhotoImageView.image ?? UIImage(named: "no-photo.png"),
              !title.isEmpty, !subtitle.isEmpty
        else { return }
        
        createAnnotationIndicator.isHidden = false
        createAnnotationIndicator.startAnimating()
        
        let annotationId = UUID().uuidString
        
        self.uploadImageAnnotation(image, annotationId: annotationId) { (url) in
            
            guard let url = url else { return }
            
            self.saveAnnotation(annotationId: annotationId, title: title, subtitle: subtitle, annotationImageURL: url, latitude: self.getCenterLocation(for: self.mapView).coordinate.latitude, longitude: self.getCenterLocation(for: self.mapView).coordinate.longitude) { (success) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Annotation did not created")
                    self.createAnnotationIndicator.stopAnimating()
                    self.createAnnotationIndicator.isHidden = true
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func saveAnnotation(annotationId: String, title: String, subtitle: String, annotationImageURL: URL, latitude: CLLocationDegrees, longitude: CLLocationDegrees,  completion: @escaping ((_ success: Bool) -> Void)) {
        
        guard let userProfile = UserService.currentUserProfile else { return }
        
        let dataBaseRef = Database.database().reference().child("annotations/\(annotationId)")
        
        let annotationObject = [
            "author" : [
                "uid" : userProfile.uid,
                "userName" : userProfile.userName,
                "userPhotoUrl" : userProfile.photoUrl.absoluteString
            ],
            "title" : title,
            "subtitle" : subtitle,
            "photoUrl" : annotationImageURL.absoluteString,
            "latitude" : latitude,
            "longitude" : longitude,
            "annotationId" : annotationId
        ] as [String : Any]
        
        dataBaseRef.setValue(annotationObject) { (error, ref) in
            completion(error == nil)
        }
    }
    
    private func uploadImageAnnotation(_ image: UIImage, annotationId: String, completion: @escaping (_ url: URL?) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef("annotations/\(annotationId)").putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                storageRef("annotations/\(annotationId)").downloadURL { (url, error) in
                    completion(url)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    private func getLocationFromAddress(from address: String, completion: @escaping (_ location: CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(location)
        }
    }
    
    private func setCameraToAddress() {
        guard let address = findAddressTextField.text else { return }
        getLocationFromAddress(from: address) { (location) in
            guard let firstLocation = self.locationManager.location?.coordinate,
                  let latitude = location?.latitude,
                  let longitude = location?.longitude else { return }
            
            let mapCamera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), fromEyeCoordinate: firstLocation, eyeAltitude: 900.0)
            
            self.mapView.setCamera(mapCamera, animated: true)
        }
    }

}

// MARK: - CLLocationManagerDelegate

extension HelpRequestViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            mapView.showsUserLocation = true
        default:
            print("we can't determine location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

    // MARK: - MKMapViewDelegate

extension HelpRequestViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if error != nil {
                self.showError("geocodeLocation.error")
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.showError("no.placemark")
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}

    //MARK: - Location Utilyties

private extension MKMapView {
    
    func restrictMap(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 470000,
                                        longitudinalMeters: 580000)
        setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        
    }
}

// MARK: - UITextFieldDelegate

extension HelpRequestViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == incNameTextField {
            incDescriptionTextField.becomeFirstResponder()
        } else if textField == incDescriptionTextField {
            self.view.endEditing(true)
        } else if textField == findAddressTextField {
            self.view.endEditing(true)
            setCameraToAddress()
        }
        return true
    }
}
