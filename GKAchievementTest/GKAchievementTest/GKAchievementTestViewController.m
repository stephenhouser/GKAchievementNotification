//
//  GKAchievementTestViewController.m
//  GKAchievementTest
//
//  Created by Stéphane Peter on 7/13/11.
//  Copyright 2011 Catloaf Software, LLC. All rights reserved.
//

#import "GKAchievementTestViewController.h"
#import "GKAchievementHandler.h"

@implementation GKAchievementTestViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (IBAction)showNotification
{
    NSString *msg;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        msg = @"Landscape Orientation";
    } else {
        msg = @"Portrait Orientation";
    }
    [[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Notification"
                                                       andMessage:msg];
    
    // Some debug info
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    NSLog(@"Status bar frame: (%f,%f) w=%f h=%f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (IBAction)hideBar:(id)sender
{
    UIApplication *app = [UIApplication sharedApplication];
    
    [app setStatusBarHidden:!app.statusBarHidden withAnimation:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
