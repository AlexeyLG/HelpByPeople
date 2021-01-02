//
//  MapAnnotation.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/26/20.
//

import UIKit
import MapKit
import Contacts

class MapAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let imageUrl: URL
    let coordinate: CLLocationCoordinate2D
    let author: UserProfile
    let id: String
   
    var mapItem: MKMapItem? {
        guard let location = subtitle else { return nil }
        
        let addressDict = [CNPostalAddressStreetKey: location]
        let placemark = MKPlacemark(coordinate: coordinate,
                                    addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
    
        return mapItem
    }
    
    init(title: String?, subtitle: String?, imageUrl: URL, coordinate: CLLocationCoordinate2D, author: UserProfile, id: String) {
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.coordinate = coordinate
        self.author = author
        self.id = id

        super.init()
        

    }
}


