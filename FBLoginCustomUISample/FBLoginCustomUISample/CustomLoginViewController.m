//
//  CustomLoginViewController.m
//  FBLoginCustomUISample
//
//  Created by Luz Caballero on 9/19/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "CustomLoginViewController.h"
#import "AppDelegate.h"

@interface CustomLoginViewController ()
- (IBAction)buttonClicked:(id)sender;
@end

@implementation CustomLoginViewController

- (IBAction)buttonClicked:(id)sender
{
  // If the session state is any of the two "open" states when the button is clicked
  if (FBSession.activeSession.state == FBSessionStateOpen
      || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {

    // Close the session and remove the access token from the cache
    // The session state handler (in the app delegate) will be called automatically
    [FBSession.activeSession closeAndClearTokenInformation];
    
  // If the session state is not any of the two "open" states when the button is clicked
  } else {
    // Open a session showing the user the login UI
    // You must ALWAYS ask for basic_info permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
       
       // Retrieve the app delegate
       AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
       // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
       [appDelegate sessionStateChanged:session state:state error:error];
     }];
  }
}

@end