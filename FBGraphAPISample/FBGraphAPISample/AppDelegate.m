//
//  AppDelegate.m
//  FBGraphAPISample
//
//  Created by Luz Caballero on 10/17/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"
#import "GraphAPICallsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  
    // Load the FBLoginView and FBProfilePictureView classes
    // You can find more information about why you need to add this line of code in our troubleshooting guide
    // https://developers.facebook.com/docs/ios/troubleshooting#objc
    [FBLoginView class];
    [FBProfilePictureView class];
  
    // Create a GraphAPICallsViewController instance from where we will make the Graph API calls
    GraphAPICallsViewController *graphAPICallsViewController = [[GraphAPICallsViewController alloc] init];
    
    // Set loginUIViewController as root view controller
    [[self window] setRootViewController:graphAPICallsViewController];
  
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

// In order to process the response you get from interacting with the Facebook login process,
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  
  // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
  BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
  
  // You can add your app-specific url handling code here if needed
  
  return wasHandled;
}

@end
