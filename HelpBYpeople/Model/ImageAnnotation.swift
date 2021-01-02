//
//  ImageAnnotation.swift
//  HelpBYpeople
//
//  Created by Alexey on 11/26/20.
//

import MapKit
import Kingfisher

class ImageAnnotationView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
      
        willSet {
            guard let mapAnnotation = annotation as? MapAnnotation else { return }

            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 48, height: 48)))
            mapsButton.setBackgroundImage(UIImage(named: "Map.png"), for: .normal)
            
            rightCalloutAccessoryView = mapsButton
        
            let mapsImageView = UIImageView(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width: 48, height: 48)))
    
            mapsImageView.kf.setImage(with: mapAnnotation.imageUrl)
            
            leftCalloutAccessoryView = mapsImageView
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = mapAnnotation.subtitle
            detailCalloutAccessoryView = detailLabel
        }
    }
}
