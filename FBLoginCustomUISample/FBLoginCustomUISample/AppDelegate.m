//
//  AppDelegate.m
//  FBLoginCustomUISample
//
//  Created by Luz Caballero on 9/19/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

/* This sample implements Login with Facebook using API calls and a custom button.
 It checks for a cached session when a person opens the app, and if there is one, it is opened.
 You can see the tutorial that accompanies this sample here:
 https://developers.facebook.com/docs/ios/login-tutorial/#login-apicalls
 
 For simplicity, this sample does limited error handling. You can read more
 about handling errors in our Error Handling guide:
 https://developers.facebook.com/docs/ios/errors
 */

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  
    // Create a LoginUIViewController instance where we will put the login button
    CustomLoginViewController *customLoginViewController = [[CustomLoginViewController alloc] init];
    self.customLoginViewController = customLoginViewController;
    
    // Set loginUIViewController as root view controller
    [[self window] setRootViewController:customLoginViewController];
  
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
  
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
      NSLog(@"Found a cached session");
      // If there's one, just open the session silently, without showing the user the login UI
      [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                         allowLoginUI:NO
                                    completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      // Handler for session state changes
                                      // This method will be called EACH time the session state changes,
                                      // also for intermediate states and NOT just when the session open
                                      [self sessionStateChanged:session state:state error:error];
                                    }];
      
      // If there's no cached session, we will show a login button
    } else {
      UIButton *loginButton = [self.customLoginViewController loginButton];
      [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    }
    return YES;
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
  // If the session was opened successfully
  if (!error && state == FBSessionStateOpen){
    NSLog(@"Session opened");
    // Show the user the logged-in UI
    [self userLoggedIn];
    return;
  }
  if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
    // If the session is closed
    NSLog(@"Session closed");
    // Show the user the logged-out UI
    [self userLoggedOut];
  }

  // Handle errors
  if (error){
    NSLog(@"Error");
    NSString *alertText;
    NSString *alertTitle;
    // If the error requires people using an app to make an action outside of the app in order to recover
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
      alertTitle = @"Something went wrong";
      alertText = [FBErrorUtility userMessageForError:error];
      [self showMessage:alertText withTitle:alertTitle];
    } else {
      
      // If the user cancelled login, do nothing
      if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"User cancelled login");
        
      // Handle session closures that happen outside of the app
      } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
        alertTitle = @"Session Error";
        alertText = @"Your current session is no longer valid. Please log in again.";
        [self showMessage:alertText withTitle:alertTitle];
        
      // For simplicity, here we just show a generic message for all other errors
      // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
      } else {
        //Get more error information from the error
        NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
        
        // Show the user an error message
        alertTitle = @"Something went wrong";
        alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
        [self showMessage:alertText withTitle:alertTitle];
      }
    }
    // Clear this token
    [FBSession.activeSession closeAndClearTokenInformation];
    // Show the user the logged-out UI
    [self userLoggedOut];
  }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
  // Set the button title as "Log in with Facebook"
  UIButton *loginButton = [self.customLoginViewController loginButton];
  [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];

  // Confirm logout message
  [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
  // Set the button title as "Log out"
  UIButton *loginButton = self.customLoginViewController.loginButton;
  [loginButton setTitle:@"Log out" forState:UIControlStateNormal];

  // Welcome message
  [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
  
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
  [[[UIAlertView alloc] initWithTitle:title
                              message:text
                             delegate:self
                    cancelButtonTitle:@"OK!"
                    otherButtonTitles:nil] show];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

  // Handle the user leaving the app while the Facebook login dialog is being shown
  // For example: when the user presses the iOS "home" button while the login dialog is active
  [FBAppCall handleDidBecomeActive];
}

@end
