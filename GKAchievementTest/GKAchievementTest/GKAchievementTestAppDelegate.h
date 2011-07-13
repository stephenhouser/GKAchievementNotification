//
//  GKAchievementTestAppDelegate.h
//  GKAchievementTest
//
//  Created by Stéphane Peter on 7/13/11.
//  Copyright 2011 Catloaf Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKAchievementTestViewController;

@interface GKAchievementTestAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet GKAchievementTestViewController *viewController;

@end
