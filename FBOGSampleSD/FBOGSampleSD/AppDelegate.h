//
//  AppDelegate.h
//  FBOGSampleSD
//
//  Created by Luz Caballero on 11/14/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "OGShareViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ShareViewController *shareViewController;

@end
