//
//  AppDelegate.h
//  FBShareSample
//
//  Created by Luz Caballero on 9/26/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "ShareViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ShareViewController *shareViewController;
@property (strong, nonatomic) NSDictionary *refererAppLink;

@end
