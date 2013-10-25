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
@property (strong, nonatomic) IBOutlet UIButton *shareLinkButton;
@property (strong, nonatomic) IBOutlet UIButton *publishOGStoryWithImageButton;


@end

@implementation ShareViewController

- (IBAction)shareLink:(id)sender
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
                                      // There was an error, show a message to the user
                                      NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                      [[[UIAlertView alloc] initWithTitle:@"Error posting to Facebook"
                                                                  message:@"Please try again later"
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil] show];
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
                                                // Error launching the dialog or publishing a story.
                                                if (error) {
                                                  NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                  [[[UIAlertView alloc] initWithTitle:@"Error posting to Facebook"
                                                                              message:@"Please try again later"
                                                                             delegate:self
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil] show];
                                                  
                                                } else {
                                                  // User canceled.
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // In this sample we just ignore it, but you could also notify your user that the story will not be posted.
                                                    NSLog(@"User cancelled.");
                                                    
                                                  } else {
                                                    // Handle the publish feed callback
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    // User canceled.
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // In this sample we just ignore it, but you could also notify your user that the story will not be posted.
                                                      NSLog(@"User cancelled.");
                                                      
                                                      // User clicked the Share button
                                                    } else {
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                      [[[UIAlertView alloc] initWithTitle:nil
                                                                                  message:@"Sharing Tutorial was posted to Facebook."
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil] show];
                                                    }
                                                  }
                                                }
                                              }];
  }
}

- (IBAction)publishOGStoryWithImage:(id)sender
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
  
  /// Package the image inside a dictionary
  NSArray* image = @[@{@"url": [info objectForKey:UIImagePickerControllerOriginalImage], @"user_generated": @"true"}];
  
  // Create an object
  id<FBGraphObject> object =
  [FBGraphObject openGraphObjectForPostWithType:@"share-sample:tutorial"
                                          title:@"Sharing Tutorial"
                                          image:@"http://i.imgur.com/g3Qc1HN.png"
                                            url:@"https://developers.facebook.com/docs/ios/share/"
                                    description:@"Allow your users to share stories on Facebook from your app using the iOS SDK."];

  // Create an action
  id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];

  // Set image on the action
  //[action setObject:image forKey:@"image"];

  // Link the object to the action
  [action setObject:object forKey:@"tutorial"];

  // Tag one or multiple users using the users' ids
  //[action setTags:@[<user-ids>]];

  // Tag a place using the place's id
  id<FBGraphPlace> place = (id<FBGraphPlace>)[FBGraphObject graphObject];
  [place setId:@"141887372509674"]; // Facebook Seattle
  [action setPlace:place];

  // Dismiss the image picker off the screen
  [self dismissViewControllerAnimated:YES completion:nil];

  // Check if the Facebook app is installed and we can present the share dialog
  FBOpenGraphActionShareDialogParams *params = [[FBOpenGraphActionShareDialogParams alloc] init];
  params.action = action;
  params.actionType = @"share-sample:complete";

  // If the Facebook app is installed and we can present the share dialog
  if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
    // Show the share dialog
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:@"share-sample:complete"
                                 previewPropertyName:@"tutorial"
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                               if(error) {
                                                 // There was an error
                                                 NSLog([NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                 [[[UIAlertView alloc] initWithTitle:@"Error posting to Facebook"
                                                                             message:@"Please try again later"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil] show];
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
       // Error launching the dialog or publishing a story.
       if (error) {
         NSLog(@"Error publishing story.");
         [[[UIAlertView alloc] initWithTitle:@"Error posting to Facebook"
                                     message:@"Please try again later"
                                    delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] show];
         
       } else {
         // User canceled.
         if (result == FBWebDialogResultDialogNotCompleted) {
           // In this sample we just ignore it, but you could also notify your user that the story will not be posted.
           NSLog(@"User cancelled.");
           
         } else {
           // Handle the publish feed callback
           NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
           
           // User canceled.
           if (![urlParams valueForKey:@"post_id"]) {
             // In this sample we just ignore it, but you could also notify your user that the story will not be posted.
             NSLog(@"User cancelled.");
             
           // User clicked the Share button
           } else {
             NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
             NSLog(@"%@", result);
             [[[UIAlertView alloc] initWithTitle:nil
                                         message:@"Sharing Tutorial was posted to Facebook."
                                        delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil] show];
           }
         }
       }
     }];
    
  }
  
}

// A function for parsing URL parameters.
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

@end
