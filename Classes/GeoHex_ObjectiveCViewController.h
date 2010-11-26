//
//  GeoHex_ObjectiveCViewController.h
//  GeoHex-ObjectiveC
//
//  Created by Matthew Gillingham on 11/26/10.
//  Copyright 2010 Tonchidot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GeoHex_ObjectiveCViewController : UIViewController {
	IBOutlet MKMapView *mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end

