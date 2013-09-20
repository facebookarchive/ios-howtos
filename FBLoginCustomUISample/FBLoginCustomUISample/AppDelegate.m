//
//  AppDelegate.m
//  FBLoginCustomUISample
//
//  Created by Luz Caballero on 9/19/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
  
    // Create a LoginUIViewController instance where the login button will be
    CustomLoginViewController *customLoginViewController = [[CustomLoginViewController alloc] init];
    self.customLoginViewController = customLoginViewController;
    
    // Set loginUIViewController as root view controller
    [[self window] setRootViewController:customLoginViewController];
  
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
      // If there's one, just open the session silently
      NSLog(@"FBSessionStateCreatedTokenLoaded");
      [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                         allowLoginUI:NO
                                    completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
                                    }];
    } else {
      UIButton *loginButton = [self.customLoginViewController loginButton];
      [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    }
  
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
  NSLog(@"sesionStateChange called");
  // If the session was opened successfully
  if (!error && state == FBSessionStateOpen){
    NSLog(@"session opened");
    // Show the user the logged-in UI
    [self userLoggedIn];
    return;
  }
  if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
    // if the session is closed
    NSLog(@"session closed");
    // Show the user the logged-out UI
    [self userLoggedOut];
  }

  // Handle errors
  if (error){
    NSLog(@"error");
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
        
      // All other errors that can happen need retries
      // more info: https://github.com/facebook/facebook-ios-sdk/blob/master/src/FBError.h#L163
      } else {
        //Get more error information from the error and
        NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
        
        // Show the user an error message
        alertTitle = @"Something went wrong :S";
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
  NSLog(@"userLoggedOut called");
  // Show login button, hide logout button
  // Show logout button, hide login button
  UIButton *loginButton = [self.customLoginViewController loginButton];
  [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
  //[[self.customLoginViewController view] addSubview:loginButton];
  // Confirm logout message
  [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
  NSLog(@"userLoggedIn called");
  // Show logout button, hide login button
  UIButton *loginButton = [self.customLoginViewController loginButton];
  [loginButton setTitle:@"Log out" forState:UIControlStateNormal];
  //[[self.customLoginViewController view] addSubview:loginButton];
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
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  // We need to properly handle checkpointing during Facebook Login
  // For example: when the user presses the iOS "home" button while the login dialog is active
  [FBAppCall handleDidBecomeActive];
}

@end
