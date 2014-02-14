//
//  GKAchievementNotification.m
//
//  Created by Benjamin Borowski on 9/30/10.
//  Copyright 2010 Typeoneerror Studios. All rights reserved.
//  $Id$
//

#import <GameKit/GameKit.h>
#import "GKAchievementNotification.h"

#pragma mark -

@interface GKAchievementNotification(private)

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)delegateCallback:(SEL)selector withObject:(id)object;

- (CGRect)text1FrameWithLogo:(BOOL)logo;
- (CGRect)text2FrameWithLogo:(BOOL)logo;
- (void)setRotation;

@end

#pragma mark -

@implementation GKAchievementNotification(private)

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didShowAchievementNotification:) withObject:self];
    [self performSelector:@selector(animateOut) withObject:nil afterDelay:kGKAchievementDisplayTime];
}

- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didHideAchievementNotification:) withObject:self];
    [self removeFromSuperview];
}

- (void)delegateCallback:(SEL)selector withObject:(id)object
{
// Suppures warning about non-retained return value from ARC.
// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.handlerDelegate)
    {
        if ([self.handlerDelegate respondsToSelector:selector])
        {
            [self.handlerDelegate performSelector:selector withObject:object];
        }
    }
#pragma clang diagnostic pop
}

- (CGRect)text1FrameWithLogo:(BOOL)logo
{
    if (logo) {
        return CGRectMake(10.0f + kGKAchievementImageSize, 6.0f, self.bounds.size.width - 55.0f, kGKAchievementTextHeight);
    } else {
        return CGRectMake(10.0f, 6.0f, self.bounds.size.width - 20.0f, kGKAchievementTextHeight);
    }
}

- (CGRect)text2FrameWithLogo:(BOOL)logo
{
    if (logo) {
        return CGRectMake(10.0f + kGKAchievementImageSize, 20.0f, self.bounds.size.width - 55.0f, kGKAchievementTextHeight);
    } else {
        return CGRectMake(10.0f, 20.0f, self.bounds.size.width - 20.0f, kGKAchievementTextHeight);
    }
}

- (void)setRotation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            self.transform = CGAffineTransformIdentity;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(M_PI_2 + M_PI);
            break;
    }
}

@end

#pragma mark -

@implementation GKAchievementNotification

@synthesize achievement=_achievement;
@synthesize background=_background;
@synthesize handlerDelegate=_handlerDelegate;
@synthesize detailLabel=_detailLabel;
@synthesize logo=_logo;
@synthesize message=_message;
@synthesize title=_title;
@synthesize textLabel=_textLabel;

#pragma mark -

- (id)initWithAchievementDescription:(GKAchievementDescription *)achievement
{
    CGRect frame = [self defaultSize];
    self.achievement = achievement;
    return [self initWithFrame:frame];
}

- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message
{
    CGRect frame = [self defaultSize];
    self.title = title;
    self.message = message;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
        if ([GKNotificationBanner class] == nil) {
#endif
        // create the GK background
        UIImage *backgroundStretch = [[UIImage imageNamed:@"gk-notification"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f];
        UIImageView *tBackground = [[UIImageView alloc] initWithFrame:frame];
        tBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tBackground.image = backgroundStretch;
        self.background = tBackground;
        self.opaque = NO;
        [self addSubview:self.background];
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                _barWidthRatio = kGKAchievementBarWidthRatioPad;
            } else {
                _barWidthRatio = kGKAchievementBarWidthRatioPhone;
            }
        } else { // iPhone/iPod touch only - pre iOS 3.2
            _barWidthRatio = kGKAchievementBarWidthRatioPhone;
        }
        
        [self setRotation];

        CGRect r1 = [self text1FrameWithLogo:NO];
        CGRect r2 = [self text2FrameWithLogo:NO];

        // create the text label
        UILabel *tTextLabel = [[UILabel alloc] initWithFrame:r1];
        tTextLabel.textAlignment = NSTextAlignmentCenter;
        tTextLabel.backgroundColor = [UIColor clearColor];
        tTextLabel.textColor = [UIColor whiteColor];
        tTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
        tTextLabel.text = NSLocalizedString(@"Achievement Unlocked", @"Achievement Unlocked Message");
        self.textLabel = tTextLabel;

        // detail label
        UILabel *tDetailLabel = [[UILabel alloc] initWithFrame:r2];
        tDetailLabel.textAlignment = NSTextAlignmentCenter;
        tDetailLabel.adjustsFontSizeToFitWidth = YES;
        // TODO: Research what minimimScaleFactor should be to replace minimumFontSize of 10.0
        //tDetailLabel.minimumFontSize = 10.0f;
        tDetailLabel.backgroundColor = [UIColor clearColor];
        tDetailLabel.textColor = [UIColor whiteColor];
        tDetailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        self.detailLabel = tDetailLabel;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
        }
#endif
        if (self.achievement)
        {
            self.textLabel.text = self.title = self.achievement.title;
            self.detailLabel.text = self.message = self.achievement.achievedDescription;
        }
        else
        {
            if (self.title)
            {
                self.textLabel.text = self.title;
            }
            if (self.message)
            {
                self.detailLabel.text = self.message;
            }
        }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
        if ([GKNotificationBanner class] == nil) {
#endif
            [self addSubview:self.textLabel];
            [self addSubview:self.detailLabel];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
        }
#endif
    }
    return self;
}


#pragma mark - Geometry

- (CGRect)defaultSize
{
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGRectMake(0.0f, 0.0f,
                          frame.size.height * _barWidthRatio, 
                          kGKAchievementFrameHeight);        
    } else {
        return CGRectMake(0.0f, 0.0f,
                          frame.size.width * _barWidthRatio, 
                          kGKAchievementFrameHeight);
    }
}

- (CGRect)startFrame
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIWindow *rootWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    CGRect frame = rootWindow.frame;
 
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return CGRectMake(frame.size.width * (1.0f - _barWidthRatio)/2.0f,
                              -kGKAchievementFrameHeight-1.0f, 
                              frame.size.width * _barWidthRatio, kGKAchievementFrameHeight);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGRectMake(frame.size.width * (1.0f - _barWidthRatio)/2.0f,
                              frame.size.height + kGKAchievementFrameHeight + 1.0f, 
                              frame.size.width * _barWidthRatio, kGKAchievementFrameHeight);
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectMake(-kGKAchievementFrameHeight-1.0f, 
                              frame.size.height * (1.0f - _barWidthRatio)/2.0f,
                              kGKAchievementFrameHeight, frame.size.height * _barWidthRatio);
        case UIInterfaceOrientationLandscapeRight:
            return CGRectMake(frame.size.width + kGKAchievementFrameHeight + 1.0f, 
                              frame.size.height * (1.0f - _barWidthRatio)/2.0f,
                              kGKAchievementFrameHeight, frame.size.height * _barWidthRatio);
    }
}

- (CGRect)endFrame
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect frame = [self startFrame];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            frame.origin.y += kGKAchievementMoveOffset + [UIApplication sharedApplication].statusBarFrame.size.height;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            frame.origin.y -= kGKAchievementMoveOffset + [UIApplication sharedApplication].statusBarFrame.size.height + kGKAchievementFrameHeight;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            frame.origin.x += kGKAchievementMoveOffset + [UIApplication sharedApplication].statusBarFrame.size.width;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            frame.origin.x -= kGKAchievementMoveOffset + [UIApplication sharedApplication].statusBarFrame.size.width + kGKAchievementFrameHeight;
            break;
    }
    return frame;
}


#pragma mark -

- (void)animateIn
{
    [self delegateCallback:@selector(willShowAchievementNotification:) withObject:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementAnimeTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationInDidStop:finished:context:)];
    self.frame = [self endFrame];
    [UIView commitAnimations];
}

- (void)animateOut
{
    [self delegateCallback:@selector(willHideAchievementNotification:) withObject:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementAnimeTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationOutDidStop:finished:context:)];
    self.frame = [self startFrame];
    [UIView commitAnimations];
}

- (void)setImage:(UIImage *)image
{
    if (image)
    {
        if (!self.logo)
        {
            UIImageView *tLogo = [[UIImageView alloc] initWithFrame:CGRectMake(7.0f, 6.0f, kGKAchievementImageSize, kGKAchievementImageSize)];
            tLogo.contentMode = UIViewContentModeScaleAspectFit;
            self.logo = tLogo;
            [self addSubview:self.logo];
        }
        self.logo.image = image;
        self.textLabel.frame = [self text1FrameWithLogo:YES];
        self.detailLabel.frame = [self text2FrameWithLogo:YES];
    }
    else
    {
        if (self.logo)
        {
            [self.logo removeFromSuperview];
        }
        self.textLabel.frame = [self text1FrameWithLogo:NO];
        self.detailLabel.frame = [self text2FrameWithLogo:NO];
    }
}

@end
