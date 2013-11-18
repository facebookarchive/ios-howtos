//
//  AppDelegate.m
//  FBOGSampleSD
//
//  Created by Luz Caballero on 11/14/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  
  // Create a LoginUIViewController instance where we will put the login button
  ShareViewController *shareViewController = [[ShareViewController alloc] init];
  self.shareViewController = shareViewController;
  
  // Set loginUIViewController as root view controller
  [[self window] setRootViewController:shareViewController];
  
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  
  BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                              sourceApplication:sourceApplication
                                fallbackHandler:^(FBAppCall *call) {
                                  NSLog(@"Unhandled deep link: %@", url);
                                  // Parse the incoming URL to look for a target_url parameter
                                  NSString *query = [url fragment];
                                  if (!query) {
                                    query = [url query];
                                  }
                                  NSDictionary *params = [self parseURLParams:query];
                                  // Check if target URL exists
                                  NSString *targetURLString = [params valueForKey:@"target_url"];
                                  if (targetURLString) {
                                    // Show the incoming link in an alert
                                    // Your code to direct the user to the appropriate flow within your app goes here
                                    [[[UIAlertView alloc] initWithTitle:@"Received link:"
                                                                message:targetURLString
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil] show];
                                  }
                                }];
  
  return urlWasHandled;
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val = [[kv objectAtIndex:1]
                     stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [params setObject:val forKey:[kv objectAtIndex:0]];
  }
  return params;
}

@end
