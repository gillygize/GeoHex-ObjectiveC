//
//  GeoHex_ObjectiveCAppDelegate.h
//  GeoHex-ObjectiveC
//
//  Created by Matthew Gillingham on 11/26/10.
//  Copyright 2010 Tonchidot. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GeoHex_ObjectiveCViewController;

@interface GeoHex_ObjectiveCAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GeoHex_ObjectiveCViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GeoHex_ObjectiveCViewController *viewController;

@end

