//
//  GeoHex_ObjectiveCViewController.m
//  GeoHex-ObjectiveC
//
//  Created by Matthew Gillingham on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeoHex_ObjectiveCViewController.h"
#import "GeoHex.h"

@implementation GeoHex_ObjectiveCViewController

@synthesize mapView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	MKCoordinateRegion zoom = mapView.region;
	zoom.span.latitudeDelta = 0.01;
	zoom.span.longitudeDelta = 0.01;
	[mapView setRegion:zoom animated:NO];
	
	CLLocationCoordinate2D c = CLLocationCoordinate2DMake(33.80911,-117.92107);
	[mapView setCenterCoordinate:c];

	GeoHex *geoHex = [[GeoHex alloc] initFromCode:@"pcjMgNK"];
	
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
