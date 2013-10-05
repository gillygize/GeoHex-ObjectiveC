//
//  GeoHex_ObjectiveCViewController.m
//  GeoHex-ObjectiveC
//
//  Created by Matthew Gillingham on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeoHex_ObjectiveCViewController.h"
#import "GeoHexV2.h"
#import "GeoHexV3.h"

@implementation GeoHex_ObjectiveCViewController

@synthesize mapView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	MKCoordinateRegion zoom = mapView.region;
	zoom.span.latitudeDelta = 0.01;
	zoom.span.longitudeDelta = 0.01;
	[mapView setRegion:zoom animated:NO];
	
	CLLocationCoordinate2D c = CLLocationCoordinate2DMake(33.80911,-117.92107);
	[mapView setCenterCoordinate:c];

	GeoHexV2 *geoHex = [[GeoHexV2 alloc] initFromCode:@"pcjMgNK"];
	
	CLLocationCoordinate2D coordinates[6];
	NSArray *locations = [geoHex locations];
	int i = 0;
	
	for (CLLocation *location in locations) {
		coordinates[i] = location.coordinate;
		
		i++;
		
		if (i >= 6) {
			break;
		}
	}
	
	MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:6];
	[mapView addOverlay:polygon];
	
	[geoHex release];
    
    GeoHexV3 *geoHex3 = [[GeoHexV3 alloc] initFromCode:@"RU00667382"];
    
    CLLocationCoordinate2D coordinates3[6];
	NSArray *locations3 = [geoHex3 locations];
	i = 0;
	
	for (CLLocation *location3 in locations3) {
		coordinates3[i] = location3.coordinate;
		
		i++;
		
		if (i >= 6) {
			break;
		}
	}
	
	MKPolygon *polygon3 = [MKPolygon polygonWithCoordinates:coordinates3 count:6];
	[mapView addOverlay:polygon3];
	
	[geoHex3 release];

}

#pragma mark MKMapViewDelegate methods

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
	MKPolygonView *view = [[[MKPolygonView alloc] initWithOverlay:overlay] autorelease];
	view.lineWidth = 1;
	view.fillColor = [UIColor clearColor];
	view.strokeColor = [UIColor blackColor];
	return view;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mapView release];
    [super dealloc];
}

@end
