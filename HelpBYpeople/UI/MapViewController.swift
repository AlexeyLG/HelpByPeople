//
//  MapViewController.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/25/20.
//

import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private let regionInMeters: Double = 22000
    static let locationBelarus = CLLocation(latitude: 53.7169, longitude: 27.9776)
    var annotations = [MapAnnotation]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        checkLocationServices()
        
        if let currentLocation = locationManager.location {
            mapView.restrictMapToUser(currentLocation)
        } else {
            mapView.restrictMap(MapViewController.locationBelarus)
        }
        
        tabBarItem.title = L10n("Map")
        
        observeAnnotations()
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
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("Error location authorization")
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        self.mapView.addAnnotation(annotation)
    }
    
    func observeAnnotations() {
        let annotationsRef = Database.database().reference().child("annotations")
        
        annotationsRef.observe(.value) { (snapshot) in
            
            let annotation = snapshot.children.compactMap { (child) -> MapAnnotation? in
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String : Any],
                   let author = dict["author"] as? [String : Any],
                   let uid = author["uid"] as? String,
                   let userName = author["userName"] as? String,
                   let photoUrl = author["userPhotoUrl"] as? String,
                   let userUrl = URL(string: photoUrl),
                   let latitude = dict["latitude"] as? Double,
                   let longitude = dict["longitude"] as? Double,
                   let annotPhotoUrl = dict["photoUrl"] as? String,
                   let annotationUrl = URL(string: annotPhotoUrl),
                   let subtitle = dict["subtitle"] as? String,
                   let title = dict["title"] as? String {
                    
                    let userProfile = UserProfile(uid: uid, userName: userName, photoUrl: userUrl)
                    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    let annotation = MapAnnotation(title: title, subtitle: subtitle, imageUrl: annotationUrl, coordinate: coordinates, author: userProfile, id: uid)
                    
                    return annotation
                }
                return nil
            }
            self.mapView.addAnnotations(annotation)
        }
    }

    @IBAction func addBarButtonDidTap(_ sender: Any) {
        performSegue(withIdentifier: "goHelpVC", sender: self)
    }
    
}

    // MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapAnnotation else { return nil }

        let identifier = "MapAnnotationView"
        var view: ImageAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? ImageAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = ImageAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let mapAnnotanion = view.annotation as? MapAnnotation else { return }

        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        mapAnnotanion.mapItem?.openInMaps(launchOptions: launchOptions)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
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
        showError("locationManager.error")
    }
  
}
    
    //MARK: - Location Utilyties

private extension MKMapView {
    
    func restrictMapToUser(_ location: CLLocation) {
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 10000,
                                        longitudinalMeters: 10000)
        setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
    }
    
    func restrictMap(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 470000,
                                        longitudinalMeters: 580000)
        setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
    }
}
