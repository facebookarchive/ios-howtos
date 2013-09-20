//
//  AppDelegate.h
//  FBLoginCustomUISample
//
//  Created by Luz Caballero on 9/19/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "CustomLoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CustomLoginViewController *customLoginViewController;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;
@end
