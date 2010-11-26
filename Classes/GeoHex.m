//
//	GeoHex.m
//  GeoHex-ObjectiveC
//
//  Created by Matthew Gillingham on 11/22/10.
//  Copyright 2010 Tonchidot. All rights reserved.
//

#import "GeoHex.h"

#define h_key	@"abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define h_base	20037508.3
#define h_deg	M_PI*(30.0/180.0)
#define h_k		tan(h_deg)

@interface GeoHex ()

/**
 * A utility method to return the character located at a specific index.
 * @property	anIndex	The desired index
 * @property	aString	The string whose index we should return
 * @return	An NSString with a length of one character contain the character at the given index of the given string.
 */
-(NSString *)charAtIndex:(int)anIndex ofString:(NSString *) aString;

/**
 * A utility method to return the index where a given character is located.
 * @property	aChar	Should be an NSString with a length of a single character
 * @property	aString	The string in which we search for the character
 * @return	An NSString with a length of one character which contains the character at the given index of the given string.
 */
-(int)indexOfChar:(NSString *) aChar inString:(NSString *) aString;
@end

@implementation GeoHex

@synthesize code;
@synthesize coordinate;
@synthesize position;

#pragma mark Class methods

+(CLLocationCoordinate2D)locationFromPoint:(MKMapPoint) aPoint {
	double lon = (aPoint.x / h_base) * 180.0;
	double lat = (aPoint.y / h_base) * 180.0;
	lat = 180.0 / M_PI * (2 * atan(exp( lat * M_PI / 180)) - M_PI/2);
	return CLLocationCoordinate2DMake(lat,lon);
}


+(MKMapPoint)pointFromLocation:(CLLocationCoordinate2D) aLocation {
	double x = aLocation.longitude * h_base / 180.0;
	double y = log( tan((90.0+aLocation.latitude) * M_PI / 360.0))/(M_PI / 180.0);
	y *= h_base / 180.0;
	return MKMapPointMake(x,y);
}

+(double)hexSizeForLevel: (int) aLevel {
	return h_base/pow(2, aLevel)/3;
}

+(NSArray *)geoHexListByStepsCenteredAroundGeoHex:(GeoHex *) centralGeoHex withLayers: (int) numberOfLayers {
	//TODO: What if the user specifies more layers than it possible at the given level? (eg. requesting
	// 10 layers of GeoHexes at Level 0)  There is current behavior is undefined.
	
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:numberOfLayers];
	MKMapPoint mapPoint;
	MKMapPoint centerPoint = MKMapPointMake(centralGeoHex.position.x, centralGeoHex.position.y);
	
	for(int i = 0; i < numberOfLayers; i++) {
		[list addObject:[NSMutableArray array]];
	}
	
	[[list objectAtIndex:0] addObject:centralGeoHex];
	
	for (int i = 0; i < numberOfLayers; i++){
		for(int j = 0; j < numberOfLayers; j++){
            if (i > 0 || j > 0) {
				if (i >= j) {
					mapPoint = MKMapPointMake(centerPoint.x + i, centerPoint.y + j);
					[[list objectAtIndex:i] addObject:[[[GeoHex alloc] initFromPoint:mapPoint withLevel:centralGeoHex.level] autorelease]];
					
				} else {
					mapPoint = MKMapPointMake(centerPoint.x + i, centerPoint.y + j);
					[[list objectAtIndex:j] addObject:[[[GeoHex alloc] initFromPoint:mapPoint withLevel:centralGeoHex.level] autorelease]];
				}
				
				if (i >= j) {
					mapPoint = MKMapPointMake(centerPoint.x - i, centerPoint.y - j);
					[[list objectAtIndex:i] addObject:[[[GeoHex alloc] initFromPoint:mapPoint withLevel:centralGeoHex.level] autorelease]];
				} else {
					mapPoint = MKMapPointMake(centerPoint.x - i, centerPoint.y - j);
					[[list objectAtIndex:j] addObject:[[[GeoHex alloc] initFromPoint:mapPoint withLevel:centralGeoHex.level] autorelease]];
				}
				
				if (i > 0 && j > 0 && (i + j <= numberOfLayers - 1)) {
					mapPoint = MKMapPointMake(centerPoint.x - i, centerPoint.y + j);
					[[list objectAtIndex:i+j] addObject:[[[GeoHex alloc] initFromPoint:mapPoint withLevel:centralGeoHex.level] autorelease]];
					
					mapPoint = MKMapPointMake(centerPoint.x + i, centerPoint.y - j);
					[[list objectAtIndex:i+j] addObject:[[[GeoHex alloc] initFromPoint:mapPoint withLevel:centralGeoHex.level] autorelease]];			
				}
            }
		}
	}
	
	return list;
}

+(NSArray *)geoHexListByCoordinatePathFrom: (CLLocationCoordinate2D) startCoordinate to:(CLLocationCoordinate2D) endCoordinate atLevel:(int)aLevel {
	//TODO: Investigate if we can condense the code with a call to stepsFrom:to:
	GeoHex *zone0 = [[GeoHex alloc] initFromLocation:startCoordinate withLevel:aLevel];
	GeoHex *zone1 = [[GeoHex alloc] initFromLocation:endCoordinate withLevel:aLevel];
		
	int startx = zone0.position.x;
	int starty = zone0.position.y;
	int endx = zone1.position.x;
	int endy = zone1.position.y;
	int x = endx - startx;
	int y = endy - starty;
	
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:10];

	int xabs = abs(x);
	int yabs = abs(y);
	
	int xqad = 0;
	int yqad = 0;
	
	if(xabs)
		xqad = x/xabs;
	if(yabs)
		yqad = y/yabs;
	
	int m = 0;
	
	if(xqad == yqad){
	    if (yabs > xabs) {
			m = x; 
		} else {
			m = y;
		}
	}
	
	int mabs = abs(m);
	
	int steps = xabs + yabs - mabs + 1;
	
	MKMapPoint start_xy = [GeoHex pointFromLocation:startCoordinate];
	
	int start_x = floor(start_xy.x);
	int start_y = floor(start_xy.y);
	
	MKMapPoint end_xy = [GeoHex pointFromLocation:endCoordinate];

	int end_x = floor(end_xy.x);
	int end_y = floor(end_xy.y);
	
	double h_size = [GeoHex hexSizeForLevel:aLevel];
	
	double unit_x = 6 * h_size;
	double unit_y = 6 * h_size * h_k;
	int pre_x = 0;
	int pre_y = 0;
	int cnt = 0;
	
	for(int i = 0; i <= steps*2; i++){
	    int lon_grid = start_x + (end_x - start_x)*i/(steps*2);
	    int lat_grid = start_y + (end_y - start_y)*i/(steps*2);
	    double h_pos_x = (lon_grid + lat_grid / h_k) / unit_x;
	    double h_pos_y = (lat_grid - h_k * lon_grid) / unit_y;
	    int h_x_0 = floor(h_pos_x);
	    int h_y_0 = floor(h_pos_y);
	    double h_x_q = h_pos_x - h_x_0;
	    double h_y_q = h_pos_y - h_y_0;
	    int h_x = round(h_pos_x);
	    int h_y = round(h_pos_y);
				
		if (h_y_q > -h_x_q + 1) {
			if((h_y_q < 2 * h_x_q) && (h_y_q > 0.5 * h_x_q)){
				h_x = h_x_0 + 1;
				h_y = h_y_0 + 1;
			}
		} else if (h_y_q < -h_x_q + 1) {
			if ((h_y_q > (2 * h_x_q) - 1) && (h_y_q < (0.5 * h_x_q) + 0.5)){
				h_x = h_x_0;
				h_y = h_y_0;
			}
		}
	    if(pre_x!=h_x||pre_y!=h_y){
			cnt++;
			[list addObject:[[[GeoHex alloc] initFromPoint:MKMapPointMake(h_x, h_y) withLevel:aLevel] autorelease]];			
	    }
	    pre_x = h_x;
	    pre_y = h_y;    
	}
	
	return list;
}

+(int)stepsFrom:(GeoHex *) startGeoHex to:(GeoHex *) endGeoHex {
	int x = floor(endGeoHex.position.x - startGeoHex.position.x);
	int y = floor(endGeoHex.position.y - startGeoHex.position.y);
	
	int xabs = abs(x);
	int yabs = abs(y);
	
	int xqad = 0;
	int yqad = 0;
	
	if(xabs != 0) 
		xqad = x/xabs;

	if(yabs != 0)
		yqad = y/yabs;
	
	int m = 0;
	
	if (xqad==yqad) {
	    if (yabs > xabs) 
			m = x;
		else
			m = y;
	}
	
	int mabs = abs(m);
	int steps = xabs + yabs - mabs + 1;
	return steps;
}

+(NSString *) version {
	return kGeoHexVersion;
}

#pragma mark Initializer methods

-(id)initFromLocation:(CLLocationCoordinate2D) aLocation withLevel:(int)aLevel
{
	if ((self = [super init])) {
		double h_size = [GeoHex hexSizeForLevel:aLevel];
		
		MKMapPoint z_xy = [GeoHex pointFromLocation:aLocation];
		
		double lon_grid = z_xy.x;
		double lat_grid = z_xy.y;
		double unit_x = 6*h_size;
		double unit_y = 6*h_size*h_k;
		
		double h_pos_x = (lon_grid + lat_grid/h_k)/unit_x;
		double h_pos_y = (lat_grid - h_k*lon_grid)/unit_y;
		
		double h_x_0 = floor(h_pos_x);
		double h_y_0 = floor(h_pos_y);
		
		double h_x_q = h_pos_x - h_x_0;
		double h_y_q = h_pos_y - h_y_0;
		
		double  h_x = round(h_pos_x);
		double  h_y = round(h_pos_y);
		
		double  h_max= round(h_base/unit_x + h_base/unit_y);
		
		if(h_y_q>-h_x_q+1){
			if((h_y_q<2*h_x_q)&&(h_y_q>0.5*h_x_q)){
				h_x = h_x_0 + 1;
				h_y = h_y_0 + 1;
			}
		} else if(h_y_q<-h_x_q+1){
			if((h_y_q>(2*h_x_q)-1)&&(h_y_q<(0.5*h_x_q)+0.5)){
				h_x = h_x_0;
				h_y = h_y_0;
			}
		}
		
		double h_lat = (h_k*h_x*unit_x + h_y*unit_y)/2.0;
		double h_lon = (h_lat - h_y*unit_y)/h_k;
		
		MKMapPoint xyloc = MKMapPointMake(h_lon, h_lat);
		CLLocationCoordinate2D z_loc = [GeoHex locationFromPoint:xyloc];
		
		double z_loc_x = z_loc.longitude;
		
		if(h_base - h_lon <h_size){
			z_loc_x = 180;
			double h_xy = h_x;
			h_x = h_y;
			h_y = h_xy;
		}
		
		double h_x_p =0;
		double h_y_p =0;
		
		if(h_x<0) h_x_p = 1;
		if(h_y<0) h_y_p = 1;
		
		
		int h_x_abs = abs(h_x)*2+h_x_p;
		int h_y_abs = abs(h_y)*2+h_y_p;
		
		//		double h_x_100000 = floor(h_x_abs/777600000);
		double h_x_10000 = floor((h_x_abs%77600000)/1296000);
		double h_x_1000 = floor((h_x_abs%1296000)/216000);
		double h_x_100 = floor((h_x_abs%216000)/3600);
		double h_x_10 = floor((h_x_abs%3600)/60);
		double h_x_1 = floor((h_x_abs%3600)%60);
		
		//		double h_y_100000 = floor(h_y_abs/777600000);
		double h_y_10000 = floor((h_y_abs%77600000)/1296000);
		double h_y_1000 = floor((h_y_abs%1296000)/216000);
		double h_y_100 = floor((h_y_abs%216000)/3600);
		double h_y_10 = floor((h_y_abs%3600)/60);
		double h_y_1 = floor((h_y_abs%3600)%60);
		
		NSMutableString *h_code = [NSMutableString stringWithCapacity:10];
		[h_code	appendString:[self charAtIndex:aLevel%60 ofString:h_key]];
		
		//		if (h_max >=77600000 / 2) {
		//			[h_code appendString:[self charAtIndex:(h_x_100000) ofString:h_key]];
		//			[h_code appendString:[self charAtIndex:(h_y_100000) ofString:h_key]];
		//		}
		
		if (h_max >= 1296000/2) {
			[h_code appendString:[self charAtIndex:(h_x_10000) ofString:h_key]];
			[h_code appendString:[self charAtIndex:(h_y_10000) ofString:h_key]];
		}
		
		if (h_max >= 216000/2) {
			[h_code appendString:[self charAtIndex:(h_x_1000) ofString:h_key]];
			[h_code appendString:[self charAtIndex:(h_y_1000) ofString:h_key]];
		}
		
		if (h_max >= 3600/2) {
			[h_code appendString:[self charAtIndex:(h_x_100) ofString:h_key]];
			[h_code appendString:[self charAtIndex:(h_y_100) ofString:h_key]];
		}
		
		if (h_max >= 60/2) {
			[h_code appendString:[self charAtIndex:(h_x_10) ofString:h_key]];
			[h_code appendString:[self charAtIndex:(h_y_10) ofString:h_key]];
		}
		
		[h_code appendString:[self charAtIndex:(h_x_1) ofString:h_key]];
		[h_code appendString:[self charAtIndex:(h_y_1) ofString:h_key]];
		
		code = [h_code copy];
		coordinate = z_loc;
		position = MKMapPointMake( h_x, h_y );
	}
	
	return self;
}

-(id) initFromCode:(NSString *)aCode {
	if ((self = [super init])) {	
		int level = [self indexOfChar:[self charAtIndex:0 ofString:aCode] inString:h_key];
		double h_size = [GeoHex hexSizeForLevel:level];
		double unit_x = 6 * h_size;
		double unit_y = 6 * h_size * h_k;
		double h_max = round(h_base / unit_x + h_base / unit_y);
		int h_x = 0;
		int h_y = 0;
		
		//		if (h_max >= 777600000 / 2) {
		//			h_x = [self indexOfChar:[self charAtIndex:1 ofString:code] inString:h_key] * 777600000 + 
		//					[self indexOfChar:[self charAtIndex:3 ofString:code] inString:h_key] * 12960000 +
		//					[self indexOfChar:[self charAtIndex:5 ofString:code] inString:h_key] * 216000 + 
		//					[self indexOfChar:[self charAtIndex:7 ofString:code] inString:h_key] * 3600 +
		//					[self indexOfChar:[self charAtIndex:9 ofString:code] inString:h_key] * 60 + 
		//					[self indexOfChar:[self charAtIndex:11 ofString:code] inString:h_key];
		//			h_y = [self indexOfChar:[self charAtIndex:2 ofString:code] inString:h_key] * 777600000 + 
		//					[self indexOfChar:[self charAtIndex:4 ofString:code] inString:h_key] * 12960000 +
		//					[self indexOfChar:[self charAtIndex:6 ofString:code] inString:h_key] * 216000 + 
		//					[self indexOfChar:[self charAtIndex:8 ofString:code] inString:h_key] * 3600 +
		//					[self indexOfChar:[self charAtIndex:10 ofString:code] inString:h_key] * 60 + 
		//					[self indexOfChar:[self charAtIndex:12 ofString:code] inString:h_key];
		//		} else
		
		
		if (h_max >= 12960000 / 2) {
			h_x = [self indexOfChar:[self charAtIndex:1 ofString:aCode] inString:h_key] * 12960000 +
			[self indexOfChar:[self charAtIndex:3 ofString:aCode] inString:h_key] * 216000 + 
			[self indexOfChar:[self charAtIndex:5 ofString:aCode] inString:h_key] * 3600 +
			[self indexOfChar:[self charAtIndex:7 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:9 ofString:aCode] inString:h_key];
			h_y = [self indexOfChar:[self charAtIndex:2 ofString:aCode] inString:h_key] * 12960000 +
			[self indexOfChar:[self charAtIndex:4 ofString:aCode] inString:h_key] * 216000 + 
			[self indexOfChar:[self charAtIndex:6 ofString:aCode] inString:h_key] * 3600 +
			[self indexOfChar:[self charAtIndex:8 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:10 ofString:aCode] inString:h_key];
		} else if (h_max >= 216000 / 2) {
			h_x = [self indexOfChar:[self charAtIndex:1 ofString:aCode] inString:h_key] * 216000 + 
			[self indexOfChar:[self charAtIndex:3 ofString:aCode] inString:h_key] * 3600 +
			[self indexOfChar:[self charAtIndex:5 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:7 ofString:aCode] inString:h_key];
			h_y = [self indexOfChar:[self charAtIndex:2 ofString:aCode] inString:h_key] * 216000 + 
			[self indexOfChar:[self charAtIndex:4 ofString:aCode] inString:h_key] * 3600 +
			[self indexOfChar:[self charAtIndex:6 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:8 ofString:aCode] inString:h_key];
		} else if (h_max >= 3600 / 2) {
			h_x = [self indexOfChar:[self charAtIndex:1 ofString:aCode] inString:h_key] * 3600 +
			[self indexOfChar:[self charAtIndex:3 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:5 ofString:aCode] inString:h_key];
			h_y = [self indexOfChar:[self charAtIndex:2 ofString:aCode] inString:h_key] * 3600 +
			[self indexOfChar:[self charAtIndex:4 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:6 ofString:aCode] inString:h_key];
		} else if (h_max >= 60 / 2) {
			h_x = [self indexOfChar:[self charAtIndex:1 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:3 ofString:aCode] inString:h_key];
			h_y = [self indexOfChar:[self charAtIndex:2 ofString:aCode] inString:h_key] * 60 + 
			[self indexOfChar:[self charAtIndex:4 ofString:aCode] inString:h_key];
		} else {
			h_x = [self indexOfChar:[self charAtIndex:1 ofString:aCode] inString:h_key];
			h_y = [self indexOfChar:[self charAtIndex:2 ofString:aCode] inString:h_key];
			
		}
		
		h_x = (h_x % 2) ? -(h_x - 1) / 2 : h_x / 2;
		h_y = (h_y % 2) ? -(h_y - 1) / 2 : h_y / 2;
		double h_lat_y = (h_k * h_x * unit_x + h_y * unit_y) / 2;
		double h_lon_x = (h_lat_y - h_y * unit_y) / h_k;
		
		CLLocationCoordinate2D h_loc = [GeoHex locationFromPoint:MKMapPointMake(h_lon_x, h_lat_y)];
		
		code = [aCode copy];
		coordinate = h_loc;
		position = MKMapPointMake(h_x, h_y);
	}
	
	return self;
}

-(id)initFromPoint:(MKMapPoint) aPoint withLevel:(int)aLevel {
	if ((self = [super init])) {
		double h_size = [GeoHex hexSizeForLevel:aLevel];
		double unit_x = 6 * h_size;
		double unit_y = 6 * h_size * h_k;
		double h_max = round(h_base / unit_x + h_base / unit_y);
		double h_lat_y = (h_k * aPoint.x * unit_x + aPoint.y * unit_y) / 2;
		double h_lon_x = (h_lat_y - aPoint.y * unit_y) / h_k;
		
		CLLocationCoordinate2D h_loc = [GeoHex locationFromPoint:MKMapPointMake(h_lon_x, h_lat_y)];
		
		int x_p = 0;
		int y_p = 0;
		if (aPoint.x < 0) x_p = 1;
		if (aPoint.y < 0) y_p = 1;
		int x_abs = fabs(aPoint.x) * 2 + x_p;
		int y_abs = fabs(aPoint.y) * 2 + y_p;
		//		double x_100000 = floor(x_abs/777600000);
		double x_10000 = floor((x_abs%777600000)/12960000);
		double x_1000 = floor((x_abs%12960000)/216000);
		double x_100 = floor((x_abs%216000)/3600);
		double x_10 = floor((x_abs%3600)/60);
		double x_1 = floor((x_abs%3600)%60);
		//		double y_100000 = floor(y_abs/777600000);
		double y_10000 = floor((y_abs%777600000)/12960000);
		double y_1000 = floor((y_abs%12960000)/216000);
		double y_100 = floor((y_abs%216000)/3600);
		double y_10 = floor((y_abs%3600)/60);
		double y_1 = floor((y_abs%3600)%60);
		
		NSMutableString *h_code = [NSMutableString stringWithCapacity:10];
		[h_code appendString:[self charAtIndex:(aLevel % 60) ofString:h_key]];
		
		//		if (h_max >= 77600000/2) {
		//			[h_code appendString:[self charAtIndex:x_100000 ofString:h_key]];
		//			[h_code appendString:[self charAtIndex:y_100000 ofString:h_key]];
		//		}
		
		if (h_max >=12960000/2) {
			[h_code appendString:[self charAtIndex:x_10000 ofString:h_key]];
			[h_code appendString:[self charAtIndex:y_10000 ofString:h_key]];
		}
		
		if (h_max >=216000/2) {
			[h_code appendString:[self charAtIndex:x_1000 ofString:h_key]];
			[h_code appendString:[self charAtIndex:y_1000 ofString:h_key]];
		}
		
		if (h_max >=3600/2) {
			[h_code appendString:[self charAtIndex:x_100 ofString:h_key]];
			[h_code appendString:[self charAtIndex:y_100 ofString:h_key]];
		}
		
		if (h_max >=60/2) {
			[h_code appendString:[self charAtIndex:x_10 ofString:h_key]];
			[h_code appendString:[self charAtIndex:y_10 ofString:h_key]];
		}
		
		[h_code appendString:[self charAtIndex:x_1 ofString:h_key]];
		[h_code appendString:[self charAtIndex:y_1 ofString:h_key]];
		
		code = [h_code copy];
		coordinate = h_loc;
		position = aPoint;		
	}
	
	return self;
}

-(int)level {
	return [self indexOfChar:[self charAtIndex:0 ofString:code] inString:h_key];
}

-(double) hexSize {
	return [GeoHex hexSizeForLevel:[self level]];
}

-(NSArray *)locations
{	
	double h_lat = self.coordinate.latitude;
	
	MKMapPoint h_xy = [GeoHex pointFromLocation: self.coordinate];
	
	double h_x = h_xy.x;
	double h_y = h_xy.y;
	
	double h_angle = tan(M_PI*(60.0/180.0));
	double h_size = [self hexSize];
	
	double h_top = [GeoHex locationFromPoint:MKMapPointMake(h_x, (h_y + h_angle* h_size) )].latitude;
	double h_btm = [GeoHex locationFromPoint:MKMapPointMake(h_x, (h_y - h_angle* h_size) )].latitude;
	
	double h_l = [GeoHex locationFromPoint:MKMapPointMake( (h_x - 2* h_size), h_y)].longitude;
	double h_r = [GeoHex locationFromPoint:MKMapPointMake( (h_x + 2* h_size), h_y)].longitude;
	double h_cl = [GeoHex locationFromPoint:MKMapPointMake( (h_x - 1* h_size), h_y)].longitude;
	double h_cr = [GeoHex locationFromPoint:MKMapPointMake( (h_x + 1* h_size), h_y)].longitude;
	
	NSArray *locations = [NSArray arrayWithObjects:
						  [[[CLLocation alloc] initWithLatitude:h_lat longitude:h_l] autorelease],
						  [[[CLLocation alloc] initWithLatitude:h_top longitude:h_cl] autorelease],
						  [[[CLLocation alloc] initWithLatitude:h_top longitude:h_cr] autorelease],
						  [[[CLLocation alloc] initWithLatitude:h_lat longitude:h_r] autorelease],
						  [[[CLLocation alloc] initWithLatitude:h_btm longitude:h_cr] autorelease],
						  [[[CLLocation alloc] initWithLatitude:h_btm longitude:h_cl] autorelease],
						  nil];
		
	return locations;
}

-(void)dealloc {
	[code release];
	[super dealloc];
}

#pragma mark private utility methods

-(NSString *)charAtIndex:(int)anIndex ofString:(NSString *)aString
{
	if (anIndex >= [aString length]) {
		return nil;
	}
	
	return [aString substringWithRange:NSMakeRange(anIndex,1)];
}

-(int)indexOfChar:(NSString *) aChar inString:(NSString *) aString {
	if (nil == aString) {
		return NSNotFound;
	}
	
	NSRange range = [aString rangeOfString:aChar];
	
	return range.location;
}

@end
