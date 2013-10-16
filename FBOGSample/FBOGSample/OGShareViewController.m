//
//  OGShareViewController.m
//  FBOGSample
//
//  Created by Luz Caballero on 10/14/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "OGShareViewController.h"

@interface OGShareViewController ()
@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) IBOutlet UIButton *shareOGStoryButton;
@end

@implementation OGShareViewController

- (void) viewDidLoad {
  // Ask for basic permissions on login
  [_fbLoginView setReadPermissions:@[@"basic_info"]];
  [_fbLoginView setDelegate:self];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
  NSLog(@"user logged in");
  [_shareOGStoryButton setHidden:NO];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  NSLog(@"user logged out");
  [_shareOGStoryButton setHidden:YES];
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

- (IBAction)shareOGStory:(id)sender
{
  // Check for publish permissions
  [FBRequestConnection startWithGraphPath:@"/me/permissions"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          __block NSString *alertText;
                          __block NSString *alertTitle;
                          if (!error){
                            NSDictionary *permissions= [(NSArray *)[result data] objectAtIndex:0];
                            if (![permissions objectForKey:@"publish_actions"]){
                              // Permission hasn't been granted, so ask for publish_actions
                              [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                                    defaultAudience:FBSessionDefaultAudienceFriends
                                                                  completionHandler:^(FBSession *session, NSError *error) {
                                                                    if (!error) {
                                                                      if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound){
                                                                        // Permission not granted, tell the user we will not add the item to their wishlist
                                                                        alertTitle = @"Permission not granted";
                                                                        alertText = @"This app will not share to Facebook.";
                                                                        [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                                                    message:alertText
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"OK!"
                                                                                          otherButtonTitles:nil] show];
                                                                      } else {
                                                                        // Permission granted, publish the OG story
                                                                        [self pickImageAndPublishStory];
                                                                      }
                                                                      
                                                                    } else {
                                                                      // An error occurred
                                                                      if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
                                                                        // Error requires people using an app to make an out-of-band action to recover
                                                                        alertTitle = @"Something went wrong";
                                                                        alertText = [FBErrorUtility userMessageForError:error];
                                                                        [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                                                    message:alertText
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"OK!"
                                                                                          otherButtonTitles:nil] show];
                                                                      } else {
                                                                        // We need to handle the error
                                                                        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                                                                          alertTitle = @"Permission not granted";
                                                                          alertText = @"This app will not share to Facebook.";
                                                                          [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                                                      message:alertText
                                                                                                     delegate:self
                                                                                            cancelButtonTitle:@"OK!"
                                                                                            otherButtonTitles:nil] show];
                                                                        } else {
                                                                          // All other errors that can happen need retries
                                                                          //Get more error information from the error and
                                                                          NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                                                                          
                                                                          // Show the user an error message
                                                                          alertTitle = @"Something went wrong";
                                                                          alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                                                                          [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                                                      message:alertText
                                                                                                     delegate:self
                                                                                            cancelButtonTitle:@"OK!"
                                                                                            otherButtonTitles:nil] show];
                                                                        }
                                                                        
                                                                      }
                                                                    }
                                                                  }];
                              
                            } else {
                              // Permissions present, publish the OG story
                              [self pickImageAndPublishStory];
                            }
                            
                          }
                        }];
  
}

- (void)pickImageAndPublishStory
{
  // Retrieve a picture from the device's photo library
  /*
  NOTE: SDK Image size limits are 480x480px minimum resolution to 12MB maximum file size.
  In this app we're not making sure that our image is within those limits but you should.
  Error code for images that go below or above the size limits is 102.
  */
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  [imagePicker setDelegate:self];
  [self presentViewController:imagePicker animated:YES completion:nil];
}

// When the user is done picking the image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  // Get the image
  UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
  
  // Dismiss the image picker off the screen
  [self dismissViewControllerAnimated:YES completion:nil];
  
  // stage an image
  [FBRequestConnection startForUploadStagingResourceWithImage:image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if(!error) {
      NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
      
      // instantiate a Facebook Open Graph object
      NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];

      // specify that this Open Graph object will be posted to Facebook
      object.provisionedForPost = YES;

      // for og:title
      object[@"title"] = @"Roasted pumpkin seeds";

      // for og:type, this corresponds to the Namespace you've set for your app and the object type name
      object[@"type"] = @"fbogsample:dish";

      // for og:description
      object[@"description"] = @"Crunchy pumpkin seeds roasted in butter and lightly salted.";

      // for og:url, we cover how this is used in the "Deep Linking" section below
      object[@"url"] = @"http://example.com/roasted_pumpkin_seeds";

      // for og:image we assign the uri of the image that we just staged
      object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
      
      // Post custom object
      [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
          // get the object ID for the Open Graph object that is now stored in the Object API
          NSString *objectId = [result objectForKey:@"id"];
          NSLog([NSString stringWithFormat:@"object id: %@", objectId]);
          
          // create an Open Graph action
          id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
          [action setObject:objectId forKey:@"dish"];

          // create action referencing user owned object
          [FBRequestConnection startForPostWithGraphPath:@"/me/fbogsample:eat" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error) {
              NSLog([NSString stringWithFormat:@"OG story posted, story id: %@", [result objectForKey:@"id"]]);
              [[[UIAlertView alloc] initWithTitle:@"OG story posted"
                                          message:@"Check your Facebook profile or activity log to see the story."
                                         delegate:self
                                cancelButtonTitle:@"OK!"
                                otherButtonTitles:nil] show];
            } else {
              // An error occurred
              NSLog(@"Encountered an error posting to Open Graph: %@", error);
            [self handleOGPostingError:error];
            }
          }];
          
        } else {
          // An error occurred
          NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
          [self handleOGPostingError:error];
        }
      }];
      
    } else {
      // An error occurred
      NSLog(@"Error staging an image: %@", error);
      [self handleOGPostingError:error];
    }
  }];
  
}


// A function for handling errors
- (void)handleOGPostingError:(NSError *)error
{
  NSString *alertText;
  NSString *alertTitle;
  if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
    // Error requires people using your app to make an action outside of your app to recover
    alertTitle = @"Something went wrong";
    alertText = [FBErrorUtility userMessageForError:error];
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertText
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
  } else {
    // All other errors that can happen need retries
    
    //Get more error information from the error
    NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
    
    // Show the user a generic error message
    alertTitle = @"Something went wrong";
    alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertText
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
    
  }
}
@end
