// For iOS
#import <GHUnitIOS/GHUnit.h>
#import <CoreLocation/CoreLocation.h>
#import "GeoHexV2.h"
#import "GeoHexV3.h"

@interface GeoHexTests : GHTestCase { }
@end

@implementation GeoHexTests

- (BOOL)shouldRunOnMainThread {
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}  

- (void)testV2Encode {
    NSString *encodeTests = [[NSBundle mainBundle] pathForResource:@"GeoHexV2EncodeTests" ofType:@"plist"];
    NSArray *v2EncodeTestCases = [NSArray arrayWithContentsOfFile:encodeTests];
    
    for (NSString *testString in v2EncodeTestCases) {
        NSArray *testComponents = [testString componentsSeparatedByString:@","];
        double lat = [[testComponents objectAtIndex:0] doubleValue];
        double lon = [[testComponents objectAtIndex:1] doubleValue];
        int level = [[testComponents objectAtIndex:2] intValue];
        NSString *code = [testComponents objectAtIndex:3];
        
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
        GeoHexV2 *geoHexV2 = [[GeoHexV2 alloc] initFromLocation:location withLevel:level];

        GHAssertEqualStrings(geoHexV2.code, code, nil);
    }
}

- (void)testV3Encode {
    NSString *encodeTests = [[NSBundle mainBundle] pathForResource:@"GeoHexV3EncodeTests" ofType:@"plist"];
    NSArray *v3EncodeTestCases = [NSArray arrayWithContentsOfFile:encodeTests];
    
    for (NSString *testString in v3EncodeTestCases) {
        NSArray *testComponents = [testString componentsSeparatedByString:@","];
        double lat = [[testComponents objectAtIndex:0] doubleValue];
        double lon = [[testComponents objectAtIndex:1] doubleValue];
        int level = [[testComponents objectAtIndex:2] intValue];
        NSString *code = [testComponents objectAtIndex:3];
                
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
        GeoHexV3 *geoHexV3 = [[GeoHexV3 alloc] initFromLocation:location withLevel:level];
        
        GHAssertEqualStrings(geoHexV3.code, code, nil);
    }
}

- (void)testV3Decode {
    NSString *decodeTests = [[NSBundle mainBundle] pathForResource:@"GeoHexV3DecodeTests" ofType:@"plist"];
    NSArray *v3DecodeTestCases = [NSArray arrayWithContentsOfFile:decodeTests];
    
    for (NSString *testString in v3DecodeTestCases) {
        NSArray *testComponents = [testString componentsSeparatedByString:@","];
        double lat = [[testComponents objectAtIndex:0] doubleValue];
        double lon = [[testComponents objectAtIndex:1] doubleValue];
        int level = [[testComponents objectAtIndex:2] intValue];
        NSString *code = [testComponents objectAtIndex:3];
                
        GeoHexV3 *geoHexV3 = [[GeoHexV3 alloc] initFromCode:code];
        
        GHAssertEquals(geoHexV3.coordinate.latitude, lat, nil);
        GHAssertEquals(geoHexV3.coordinate.longitude, lon, nil);
        GHAssertEquals([geoHexV3 level], level, nil);
    }
}

@end