//
//  AnnotationService.swift
//  HelpBYpeople
//
//  Created by Alexey on 12/2/20.
//

import Foundation
import Firebase
import MapKit

class AnnotationService {
    
    static var currentAnnotationProfile: MapAnnotation?
    
    static func observeAnnotationProfile(_ annotationId: String, completion: @escaping ((_ annotationProfile: MapAnnotation?) -> Void)) {
        let annotationRef = Database.database().reference().child("annotations/\(annotationId)")
        
        annotationRef.observe(.value) { (snapshot) in
            var annotationProfile: MapAnnotation?
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String : Any],
                   let author = dict["author"] as? [String : Any],
                   let authorId = author["id"] as? String,
                   let userName = author["userName"] as? String,
                   let photoUrl = author["userPhotoUrl"] as? String,
                   let userUrl = URL(string: photoUrl),
                   let latitude = dict["latitude"] as? Double,
                   let longitude = dict["longitude"] as? Double,
                   let annotPhotoUrl = dict["photoUrl"] as? String,
                   let annotationUrl = URL(string: annotPhotoUrl),
                   let subtitle = dict["subtitle"] as? String,
                   let title = dict["title"] as? String {
                    
                    let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let userProfile = UserProfile(uid: authorId, userName: userName, photoUrl: userUrl)
                    
                    annotationProfile = MapAnnotation(title: title, subtitle: subtitle, imageUrl: annotationUrl, coordinate: coordinates, author: userProfile, authorId: authorId)
                }
                
            }
            completion(annotationProfile)
        }
    }
}

