//
//  GeoHex.h
//  GeoHex-ObjectiveC
//
//  Created by Matthew Gillingham on 11/22/10.
//  Copyright 2010 Tonchidot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>

#define kGeoHexVersion			@"2.0.3"
#define kGeoHexNumberOfLevels	24

/*!
 * A class to create a new GeoHex object.  This class is a somewhat literal translation of the JavaScript implementation of the GeoHex
 * found at http://geohex.net/hex_v2.03_core.js .  I have changed the name of some of the methods and altered some points of functionality, but I tried
 * to keep each of the algorithms found in this file in tact.
 */
@interface GeoHexV2 : NSObject {
	NSString *code;						
	CLLocationCoordinate2D coordinate;	
	MKMapPoint position;				
}

@property(nonatomic, retain, readonly) NSString *code;	/*!< The encoded string for this GeoHex. */
@property(readonly) CLLocationCoordinate2D coordinate;	/*!< The coordinate of the GeoHex. */
@property(readonly) MKMapPoint position;				/*!< The X, Y position of the GeoHex, using the GeoHex specific coordinate system */

/*!
 * Converts a CLLocationCoordinate2D into an MKMapPoint coordinate.  MKMapPoint is being used here as a struct for GeoHex's own X-Y representation
 * system. The value returned by this method does NOT coorespond to the MKMapPoint value in MapKit.
 * @param	aLocation	A longitude/latitude position
 * @return	An MKMapPoint with an x and y value encoded using GeoHex's representation system.
 */
+(MKMapPoint)pointFromLocation:(CLLocationCoordinate2D) aLocation;

/*!
 * Converts an MKMapPoint to a CLLocationCoordinate2D.  MKMapPoint is being used here as a struct for GeoHex's own X-Y representation system. The
 * value returned by this method does NOT coorespond to the MKMapPoint value in MapKit.
 * @param	aLocation	A longitude/latitude position
 * @return	An MKMapPoint with an x and y value encoded using GeoHex's representation system.
 */
+(CLLocationCoordinate2D)locationFromPoint: (MKMapPoint) aPoint;

/*!
 * Given a level, this method will return the size of a GeoHex at that level.  The level is part of the GeoHex definition and ranges from 0 to kGeoHexNumberOfLevels
 * where 0 is a GeoHex of the largest area and each subsequent level becomes smaller.
 * @param	aLevel	A longitude/latitude position
 * @return	The size of a GeoHex at that level.
 */
+(double)hexSizeForLevel: (int) aLevel;

/*!
 * Returns a two-dimensional NSArray of GeoHexes.  Each level contains an Array of GeoHexes which completely surround the previous level of GeoHexes.  The resulting
 * NSArray will contain the specified number of layers.
 * @param	centralZone		The GeoHex at the center of the list.
 * @param	numberOfLayers	The number of layers surrounding the given list.
 * @return	A two-dimensional NSArray with a list of GeoHexes expanding radially outwards from the center.
 */
+(NSArray *)geoHexListByStepsCenteredAroundGeoHex:(GeoHexV2 *) centralGeoHex withLayers: (int) numberOfLayers;

/*!
 * Given two latitude/longitude positions and a level, this method generates a path of GeoHexes from the start position to the end position.
 * @param	startCoordinate		The starting latitude/longitude position
 * @param	endCoordiate		The ending latitude/longitude position
 * @param	aLevel				The level of the GeoHexes to use in creating the list
 * @return	An array of GeoHexes of a given level moving from the startCoordinate to the endCoordinate
 */
+(NSArray *)geoHexListByCoordinatePathFrom: (CLLocationCoordinate2D) startCoordinate to:(CLLocationCoordinate2D) endCoordinate atLevel:(int)aLevel;

/*!
 * Indicates the current version of the GeoHex specification.
 * @return A string representing the current GeoHex version.
 */
+(NSString *)version;

/*!
 * Returns the number of steps from one GeoHex to another, including both the start and ending GeoHex
 * @param	start		The starting GeoHex
 * @param	end			The ending GeoHex 
 * @return	The number of steps from the first GeoHex to the second GeoHex, including both GeoHexes
 */
+(int)stepsFrom:(GeoHexV2 *) startGeoHex to:(GeoHexV2 *) endGeoHex;

/*!
 * Creates a new GeoHex from a latitude/longitude position and a level.  The level is part of the GeoHex definition and ranges from 0 to kGeoHexNumberOfLevels
 * where 0 is a GeoHex of the largest area and each subsequent level becomes smaller.
 * @param	aLocation		A latitude/longitude position
 * @param	aLevel			The level of the GeoHex to generate
 * @return	The number of steps from the first GeoHex to the second GeoHex, including both GeoHexes
 */
-(id)initFromLocation:(CLLocationCoordinate2D) aLocation withLevel:(int)aLevel;

/*!
 * Creates a new GeoHex from a GeoHex encoding.
 * @param	aCode	A GeoHex encoding.
 * @return	The GeoHex object represented by the given encoding.
 */
-(id)initFromCode:(NSString *)aCode;

/*!
 * Creates a new GeoHex from a GeoHex X-Y position.  The X-Y represention used to create the GeoHex must by the X-Y pair contained in the GeoHex specification.  It
 * will not work with a CGPoint position taken from a UIView or an MKMapPoint position taken from the CLLocationCoordinate2D.  It can only be the GeoHex internal
 * representation.  Likewise, The level is part of the GeoHex definition and ranges from 0 to kGeoHexNumberOfLevels
 * where 0 is a GeoHex of the large area and each subsequent level becomes smaller.
 * @param	aPoint		An X-Y position as expressed in the GeoHex standard
 * @param	aLevel		
 * @return	The number of steps from the first GeoHex to the second GeoHex, including both GeoHexes
 */
-(id)initFromPoint:(MKMapPoint) aPoint withLevel:(int)aLevel;

/*!
 * The level of the current GeoHex. The level is part of the GeoHex definition and ranges from 0 to kGeoHexNumberOfLevels
 * where 0 is a GeoHex of the large area and each subsequent level becomes smaller.
 */
-(int)level;

/*!
 * The size of the hexgon for the given GeoHex.
 */
-(double) hexSize;

/*!
 * Returns an array with each of the six corners of the GeoHex, represented as CLLocation objects.
 */
-(NSArray *)locations;

@end
