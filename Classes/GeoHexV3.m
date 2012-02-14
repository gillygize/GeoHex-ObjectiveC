//
//	GeoHex.m
//  GeoHex-ObjectiveC
//
//  Created by Matthew Gillingham on 11/22/10.
//  Copyright 2010 Tonchidot. All rights reserved.
//

#import "GeoHexV3.h"

#define h_key   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define h_base	20037508.34
#define h_deg	M_PI*(30.0/180.0)
#define h_k		tan(h_deg)

@interface GeoHexV3 ()

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

/**
 * A utility method to turn a string representation of an integer in base 3 to an integer in base 10.
 * @property	codeStr an string which contains the representation of an integer in base 3
 * @return	An NSString containing a representation of an integer in base 10
 */
-(NSString*)parseInt3:(NSString*)codeStr;

/**
 * A utility method which takes an integer an converts it to an NSString with the base 3 representation of the integer
 * @property	anInteger   an integer
 * @return	An NSString with the base 3 represention of the given integer
 */
-(NSString*)toString3:(int)anInteger;

@end

@implementation GeoHexV3

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
	return h_base/pow(3, aLevel+1);
}

+(NSString *) version {
	return kGeoHexV3Version;
}

#pragma mark Initializer methods
-(id) initFromCode:(NSString *)aCode {
	if ((self = [super init])) {	
        int level = [aCode length];
        double h_size = [GeoHexV3 hexSizeForLevel:level];
        double unit_x = 6 * h_size;
        double unit_y = 6 * h_size * h_k;
        int h_x = 0;
        int h_y = 0;
        
        int i;
                
        NSMutableString *h_dec9 = [NSMutableString stringWithFormat:@"%d%@",
                                   [self indexOfChar:[self charAtIndex:0 ofString:aCode] inString:h_key] * 30 +
                                   [self indexOfChar:[self charAtIndex:1 ofString:aCode] inString:h_key],
                                   [aCode substringFromIndex:2]];
        
        NSRegularExpression *expression1 = [NSRegularExpression regularExpressionWithPattern:@"[15]" options:0 error:nil];
        NSRegularExpression *expression2 = [NSRegularExpression regularExpressionWithPattern:@"[^125]" options:0 error:nil]; 
        
        NSString *firstCharacter = [self charAtIndex:0 ofString:h_dec9];
        NSString *secondCharacter = [self charAtIndex:1 ofString:h_dec9];
        NSString *thirdCharacter = [self charAtIndex:2 ofString:h_dec9];

        if(([expression1 numberOfMatchesInString:firstCharacter options:0 range:NSMakeRange(0,1)] > 0) &&
           ([expression2 numberOfMatchesInString:secondCharacter options:0 range:NSMakeRange(0,1)] > 0) &&
           ([expression2 numberOfMatchesInString:thirdCharacter options:0 range:NSMakeRange(0,1)] > 0)) {
            
            if([firstCharacter intValue] == 5){
                [h_dec9 replaceCharactersInRange:NSMakeRange(0, 1) withString:@"7"];

            } else if([firstCharacter intValue] == 1){
                [h_dec9 replaceCharactersInRange:NSMakeRange(0, 1) withString:@"3"];
            }
        }
        
        int d9xlen = [h_dec9 length];
        
        for(i=0;i<level + 1 - d9xlen;i++){
            [h_dec9 insertString:@"0" atIndex:0];
            d9xlen++;
        }
        
        NSMutableString* h_dec3 = [NSMutableString string];
        
        for(i=0;i<d9xlen;i++){
            int dec9i = [[self charAtIndex:i ofString:h_dec9] intValue];
            NSString *h_dec0=[self toString3:dec9i];
            
            if ([h_dec0 length] == 0){
                [h_dec3 appendString:@"00"];
            } else if([h_dec0 length]==1){
                [h_dec3 appendString:@"0"];
            }
            
            [h_dec3 appendString:h_dec0];
        }
        
        NSMutableArray *h_decx = [NSMutableArray array];
        NSMutableArray *h_decy = [NSMutableArray array];
        
        for(i=0;i<h_dec3.length/2;i++){
            [h_decx addObject:[self charAtIndex:i*2 ofString:h_dec3]];
            [h_decy addObject:[self charAtIndex:i*2+1 ofString:h_dec3]];
        }
        
        for(i=0;i<=level;i++){
            double h_pow = pow(3,level-i);
            if([[h_decx objectAtIndex:i] isEqualToString:@"0"]){
                h_x -= h_pow;
            }else if([[h_decx objectAtIndex:i] isEqualToString:@"2"]){
                h_x += h_pow;
            }
            if([[h_decy objectAtIndex:i] isEqualToString:@"0"]){
                h_y -= h_pow;
            }else if([[h_decy objectAtIndex:i] isEqualToString:@"2"]){
                h_y += h_pow;
            }
        }
        
        double h_lat_y = (h_k * h_x * unit_x + h_y * unit_y) / 2;
        double h_lon_x = (h_lat_y - h_y * unit_y) / h_k;
        
        CLLocationCoordinate2D h_loc = [GeoHexV3 locationFromPoint:MKMapPointMake(h_lon_x, h_lat_y)];
        
        if(h_loc.longitude>180){
            h_loc.longitude -= 360;
            h_x -= pow(3,level);
            h_y += pow(3,level);
        } else if(h_loc.longitude < -180) { 
            h_loc.longitude += 360;
            h_x += pow(3,level);
            h_y -= pow(3,level);
        }
        
        code = aCode;
        coordinate = h_loc;
        position = MKMapPointMake(h_x, h_y);
	}
	
	return self;
}

-(id)initFromLocation:(CLLocationCoordinate2D) aLocation withLevel:(int)aLevel {
	if ((self = [super init])) {
        int level = aLevel + 2;
		double h_size = [GeoHexV3 hexSizeForLevel:level];
        
        MKMapPoint z_xy = [GeoHexV3 pointFromLocation:aLocation];
        double lon_grid = z_xy.x;
        double lat_grid = z_xy.y;
		double unit_x = 6 * h_size;
		double unit_y = 6 * h_size * h_k;
        double h_pos_x = (lon_grid + lat_grid / h_k) / unit_x;
        double h_pos_y = (lat_grid - h_k * lon_grid) / unit_y;
        double h_x_0 = floor(h_pos_x);
        double h_y_0 = floor(h_pos_y);
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
        
        double h_lat = (h_k * h_x * unit_x + h_y * unit_y) / 2;
        double h_lon = (h_lat - h_y * unit_y) / h_k;
        
        CLLocationCoordinate2D z_loc = [GeoHexV3 locationFromPoint:MKMapPointMake(h_lon, h_lat)];
        double z_loc_x = z_loc.longitude;
        double z_loc_y = z_loc.latitude;
        
        if(h_base - h_lon < h_size){
            z_loc_x = 180;
            double h_xy = h_x;
            h_x = h_y;
            h_y = h_xy;
        }
        
        NSMutableString *h_code = [NSMutableString string];
        int code3_x[level+1];
        int code3_y[level+1];
        NSMutableString *code3 = [NSMutableString string];
        NSMutableString *code9=  [NSMutableString string];
        double mod_x = h_x;
        double mod_y = h_y;
        int i;
        
        for(i = 0;i <= level ; i++){
            double h_pow = pow(3,level-i);
            if(mod_x >= ceil(h_pow/2)){
                code3_x[i] = 2;
                mod_x -= h_pow;
            } else if(mod_x <= -ceil(h_pow/2)){
                code3_x[i] = 0;
                mod_x += h_pow;
            } else{
                code3_x[i] = 1;
            }
            
            if(mod_y >= ceil(h_pow/2)){
                code3_y[i] = 2;
                mod_y -= h_pow;
            } else if(mod_y <= -ceil(h_pow/2)){
                code3_y[i] = 0;
                mod_y += h_pow;
            } else {
                code3_y[i] = 1;
            }
        }
        
        for(i=0;i<=level;i++){
            [code3 appendFormat:@"%d%d", code3_x[i], code3_y[i]];
            [code9 appendString:[self parseInt3:code3]];
            [h_code appendString:code9];
            [code9 deleteCharactersInRange:NSMakeRange(0, [code9 length])];
            [code3 deleteCharactersInRange:NSMakeRange(0, [code3 length])];
        }

        NSString* h_2 = [h_code substringFromIndex:3];
        NSString* h_1 = [h_code substringToIndex:3];

        int h_a1 = floor([h_1 intValue] / 30.0f);
        int h_a2 = [h_1 intValue]%30;
        h_code = [NSString stringWithFormat:@"%@%@%@", [self charAtIndex:h_a1 ofString:h_key], [self charAtIndex:h_a2 ofString:h_key], h_2];
        
        code = [h_code copy];
        coordinate = CLLocationCoordinate2DMake(z_loc_y, z_loc_x);
        position = MKMapPointMake(h_x, h_y);
	}
	
	return self;
}

-(int)level {
	return [[self code] length] - 2;
}

-(double) hexSize {
	return [GeoHexV3 hexSizeForLevel:([self level] + 2)];
}

-(NSArray *)locations
{	
	double h_lat = self.coordinate.latitude;
    double h_lon = self.coordinate.longitude;
	
	MKMapPoint h_xy = [GeoHexV3 pointFromLocation: self.coordinate];
	
	double h_x = h_xy.x;
	double h_y = h_xy.y;
	
	double h_angle = tan(M_PI*(60.0/180.0));
	double h_size = [self hexSize];
	
	double h_top = [GeoHexV3 locationFromPoint:MKMapPointMake(h_x, (h_y + h_angle* h_size) )].latitude;
	double h_btm = [GeoHexV3 locationFromPoint:MKMapPointMake(h_x, (h_y - h_angle* h_size) )].latitude;
	
	double h_l = [GeoHexV3 locationFromPoint:MKMapPointMake( (h_x - 2* h_size), h_y)].longitude;
	double h_r = [GeoHexV3 locationFromPoint:MKMapPointMake( (h_x + 2* h_size), h_y)].longitude;
	double h_cl = [GeoHexV3 locationFromPoint:MKMapPointMake( (h_x - 1* h_size), h_y)].longitude;
	double h_cr = [GeoHexV3 locationFromPoint:MKMapPointMake( (h_x + 1* h_size), h_y)].longitude;
	
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

- (NSString*)parseInt3:(NSString*)codeStr {
    int length = [codeStr length];
    int multiplier = length - 1;
    int result = 0;
    
    for(int i=0; i < length; i++, multiplier--) {
        NSString *place = [codeStr substringWithRange:NSMakeRange(i, 1)];
        result += [place integerValue] * pow(3, multiplier); 
    }
    
    return [NSString stringWithFormat:@"%d", result];
}

-(NSString*)toString3:(int)anInteger {
    NSMutableString *returnString = [NSMutableString string];
    int currentNumber = anInteger;
    
    while(currentNumber > 0) {
        if (nil == returnString) {
            returnString = [NSMutableString stringWithFormat:@"%d", currentNumber % 3];
        } else {
            [returnString insertString:[NSString stringWithFormat:@"%d", currentNumber % 3] atIndex:0];
        }
        
        currentNumber = currentNumber / 3;
    }
    
    return returnString;
}

@end
