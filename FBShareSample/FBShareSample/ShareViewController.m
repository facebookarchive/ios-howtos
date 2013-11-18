//
//  ShareViewController.m
//  FBShareSample
//
//  Created by Luz Caballero on 9/30/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ShareViewController.h"

@interface ShareViewController ()
@property (strong, nonatomic) IBOutlet UIButton *ShareLinkWithShareDialogButton;
@property (strong, nonatomic) IBOutlet UIButton *ShareLinkWithAPICallsButton;

@property (strong, nonatomic) IBOutlet UIButton *StatusUpdateWithShareDialogButton;
@property (strong, nonatomic) IBOutlet UIButton *StatusUpdateWithAPICallsButton;

@end

@implementation ShareViewController


//------------------Login implementation starts here------------------

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
  // If the user is logged in, they can post to Facebook using API calls, so we show the buttons
  [_ShareLinkWithAPICallsButton setHidden:NO];
  [_StatusUpdateWithAPICallsButton setHidden:NO];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  // If the user is NOT logged in, they can't post to Facebook using API calls, so we show the buttons
  [_ShareLinkWithAPICallsButton setHidden:YES];
  [_StatusUpdateWithAPICallsButton setHidden:YES];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
  NSString *alertMessage, *alertTitle;
  
  // If the user should perform an action outside of you app to recover,
  // the SDK will provide a message for the user, you just need to surface it.
  // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
  if ([FBErrorUtility shouldNotifyUserForError:error]) {
    alertTitle = @"Facebook error";
    alertMessage = [FBErrorUtility userMessageForError:error];
    
    // This code will handle session closures since that happen outside of the app.
    // You can take a look at our error handling guide to know more about it
    // https://developers.facebook.com/docs/ios/errors
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
    alertTitle = @"Session Error";
    alertMessage = @"Your current session is no longer valid. Please log in again.";
    
    // If the user has cancelled a login, we will do nothing.
    // You can also choose to show the user a message if cancelling login will result in
    // the user not being able to complete a task they had initiated in your app
    // (like accessing FB-stored information or posting to Facebook)
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
    NSLog(@"user cancelled login");
    
    // For simplicity, this sample handles other errors with a generic message
    // You can checkout our error handling guide for more detailed information
    // https://developers.facebook.com/docs/ios/errors
  } else {
    alertTitle  = @"Something went wrong";
    alertMessage = @"Please try again later.";
    NSLog(@"Unexpected error:%@", error);
  }
  
  if (alertMessage) {
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}


//------------------------------------

//------------------Sharing a link using the share dialog------------------
- (IBAction)shareLinkWithShareDialog:(id)sender
{
 
  // Check if the Facebook app is installed and we can present the share dialog
  FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
  params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
  params.name = @"Sharing Tutorial";
  params.caption = @"Build great social apps and get more installs.";
  params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
  params.description = @"Allow your users to share stories on Facebook from your app using the iOS SDK.";


  // If the Facebook app is installed and we can present the share dialog
  if ([FBDialogs canPresentShareDialogWithParams:params]) {
    
    // Present share dialog
    [FBDialogs presentShareDialogWithLink:params.link
                                     name:params.name
                                  caption:params.caption
                              description:params.description
                                  picture:params.picture
                              clientState:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                    if(error) {
                                      // There was an error
                                      NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                    } else {
                                        // Success
                                        NSLog(@"result %@", results);
                                    }
                                  }];
    
  // If the Facebook app is NOT installed and we can't present the share dialog
  } else {
    // FALLBACK: publish just a link using the Feed dialog
    
    // Put together the dialog parameters
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Sharing Tutorial", @"name",
                                   @"Build great social apps and get more installs.", @"caption",
                                   @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                   @"https://developers.facebook.com/docs/ios/share/", @"link",
                                   @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                   nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  // Error launching the dialog or publishing a story.
                                                  NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // User canceled.
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    // Handle the publish feed callback
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // User canceled.
                                                      NSLog(@"User cancelled.");
                                                      
                                                    } else {
                                                      // User clicked the Share button
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
  }
}

//------------------------------------

//------------------Posting a status update using the share dialog------------------
- (IBAction)postStatusUpdateWithShareDialog:(id)sender
{
  
  // Check if the Facebook app is installed and we can present the share dialog
  
  FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
  params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
  
  // If the Facebook app is installed and we can present the share dialog
  if ([FBDialogs canPresentShareDialogWithParams:params]) {
    
    // Present share dialog
    [FBDialogs presentShareDialogWithLink:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                    if(error) {
                                      // There was an error
                                      NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                    } else {
                                      // Success
                                      NSLog(@"result %@", results);
                                    }
                                  }];
    
    // If the Facebook app is NOT installed and we can't present the share dialog
  } else {
    // FALLBACK: publish just a link using the Feed dialog
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:nil
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  // Error launching the dialog or publishing a story.
                                                  NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // User canceled.
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    // Handle the publish feed callback
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // User canceled.
                                                      NSLog(@"User cancelled.");
                                                      
                                                    } else {
                                                      // User clicked the Share button
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
  }
}


//------------------------------------

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val =
    [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params[kv[0]] = val;
  }
  return params;
}

//------------------------------------

//------------------Sharing a link using API calls------------------

- (IBAction)ShareLinkWithAPICalls:(id)sender {
  // We will post on behalf of the user, these are the permissions we need:
  NSArray *permissionsNeeded = @[@"publish_actions"];
  
  // Request the permissions the user currently has
  [FBRequestConnection startWithGraphPath:@"/me/permissions"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          if (!error){
                            NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                            NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                            
                            // Check if all the permissions we need are present in the user's current permissions
                            // If they are not present add them to the permissions to be requested
                            for (NSString *permission in permissionsNeeded){
                              if (![currentPermissions objectForKey:permission]){
                                [requestPermissions addObject:permission];
                              }
                            }
                            
                            // If we have permissions to request
                            if ([requestPermissions count] > 0){
                              // Ask for the missing permissions
                              [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                    defaultAudience:FBSessionDefaultAudienceFriends
                                                                  completionHandler:^(FBSession *session, NSError *error) {
                                                                    if (!error) {
                                                                      // Permission granted, we can request the user information
                                                                      [self makeRequestToShareLink];
                                                                    } else {
                                                                      // An error occurred, handle the error
                                                                      // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                      NSLog([NSString stringWithFormat:@"%@", error.description]);
                                                                    }
                                                                  }];
                            } else {
                              // Permissions are present, we can request the user information
                              [self makeRequestToShareLink];
                            }
                            
                          } else {
                            // There was an error requesting the permission information
                            // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                            NSLog([NSString stringWithFormat:@"%@", error.description]);
                          }
                        }];
}

- (void)makeRequestToShareLink {
  
  // NOTE: pre-filling fields associated with Facebook posts,
  // unless the user manually generated the content earlier in the workflow of your app,
  // can be against the Platform policies: https://developers.facebook.com/policy
  
  // Put together the dialog parameters
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"Sharing Tutorial", @"name",
                                 @"Build great social apps and get more installs.", @"caption",
                                 @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                 @"https://developers.facebook.com/docs/ios/share/", @"link",
                                 @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                 nil];
  
  [FBRequestConnection startWithGraphPath:@"/me/feed"
                               parameters:params
                               HTTPMethod:@"POST"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          if (!error) {
                            // Link posted successfully to Facebook
                            NSLog([NSString stringWithFormat:@"result: %@", result]);
                          } else {
                            // There was an error
                            NSLog([NSString stringWithFormat:@"%@", error.description]);
                          }
                        }];
}

//------------------------------------

//------------------Posting a status update using API calls------------------

- (IBAction)StatusUpdateWithAPICalls:(id)sender {
  // We will post on behalf of the user, these are the permissions we need:
  NSArray *permissionsNeeded = @[@"publish_actions"];
  
  // Request the permissions the user currently has
  [FBRequestConnection startWithGraphPath:@"/me/permissions"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          if (!error){
                            NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                            NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                            
                            // Check if all the permissions we need are present in the user's current permissions
                            // If they are not present add them to the permissions to be requested
                            for (NSString *permission in permissionsNeeded){
                              if (![currentPermissions objectForKey:permission]){
                                [requestPermissions addObject:permission];
                              }
                            }
                            
                            // If we have permissions to request
                            if ([requestPermissions count] > 0){
                              // Ask for the missing permissions
                              [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                    defaultAudience:FBSessionDefaultAudienceFriends
                                                                  completionHandler:^(FBSession *session, NSError *error) {
                                                                    if (!error) {
                                                                      // Permission granted, we can request the user information
                                                                      [self makeRequestToUpdateStatus];
                                                                    } else {
                                                                      // An error occurred, handle the error
                                                                      // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                      NSLog([NSString stringWithFormat:@"%@", error.description]);
                                                                    }
                                                                  }];
                            } else {
                              // Permissions are present, we can request the user information
                              [self makeRequestToUpdateStatus];
                            }
                            
                          } else {
                            // There was an error requesting the permission information
                            // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                            NSLog([NSString stringWithFormat:@"%@", error.description]);
                          }
                        }];
}

- (void)makeRequestToUpdateStatus {
  
  // NOTE: pre-filling fields associated with Facebook posts,
  // unless the user manually generated the content earlier in the workflow of your app,
  // can be against the Platform policies: https://developers.facebook.com/policy
  
  [FBRequestConnection startForPostStatusUpdate:@"User-generated status update."
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          if (!error) {
                            // Status update posted successfully to Facebook
                            NSLog([NSString stringWithFormat:@"result: %@", result]);
                          } else {
                            // There was an error
                            NSLog([NSString stringWithFormat:@"%@", error.description]);
                          }
                        }];
}


//------------------------------------

@end
