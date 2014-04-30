//
//  AppDelegate.m
//  FBOGSample
//
//  Created by Luz Caballero on 10/14/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"
#import "OGShareViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  
    // Load the FBLoginView class (needed for Login)
    // You can find more information about why you need to add this line of code in our troubleshooting guide
    // https://developers.facebook.com/docs/ios/troubleshooting#objc
    [FBLoginView class];
  
    // Create a LoginUIViewController instance where the login button will be
    OGShareViewController *ogShareViewController = [[OGShareViewController alloc] init];
  
    // Set loginUIViewController as root view controller
    [[self window] setRootViewController:ogShareViewController];
  
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

// In order to process the response you get from interacting with the Facebook login process
// and to handle any deep linking calls from Facebook
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

  BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
    if([[call appLinkData] targetURL] != nil) {
      // get the object ID string from the deep link URL
      // we use the substringFromIndex so that we can delete the leading '/' from the targetURL
      NSString *objectId = [[[call appLinkData] targetURL].path substringFromIndex:1];
      
      // now handle the deep link
      // write whatever code you need to show a view controller that displays the object, etc.
      [[[UIAlertView alloc] initWithTitle:@"Directed from Facebook"
                                  message:[NSString stringWithFormat:@"Deep link to %@", objectId]
                                 delegate:self
                        cancelButtonTitle:@"OK!"
                        otherButtonTitles:nil] show];
    } else {
      //
      NSLog(@"Unhandled deep link: %@", [[call appLinkData] targetURL]);
    }
  }];
  
  return wasHandled;
}

@end
