//
//  DefaultTextMessageViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/21/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "DefaultTextMessageViewController.h"
#import "WebServiceManager.h"
#import "DataHold.h"

@interface DefaultTextMessageViewController ()

@end

@implementation DefaultTextMessageViewController
{
    DataHold *sharedRepository;
}

@synthesize customMessageTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(id)sender
{
    [self processMessageUpdateRequest];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)processMessageUpdateRequest
{
    WebServiceManager *updateMessageManager = [[WebServiceManager alloc] init];
    
    // (email, sessionId, message)
    NSDictionary *orderCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      sharedRepository.userEmail, @"email",
                                      sharedRepository.sessionID, @"sessionId",
                                      customMessageTextView.text, @"message",
                                      nil];
    
    //NSLog(@"Email: %@;  SessionID: %@", sharedRepository.userEmail, sharedRepository.sessionID);
    //NSLog(@"Order: %@; Phone: %@", orderNumberTextField.text, phoneNumberTextField.text);
    
    [updateMessageManager generatePostRequestAtRoute:sharedRepository.updateTextMessageURL withJSONBodyData:orderCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       while(!updateMessageManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       if(updateMessageManager.responseStatusCode == 200)
                       {
                           
                       }
                       else
                       {
                           [self indicateUpdateMessageAttemptFailure:updateMessageManager.responseString];
                       }
                   });
    
    sharedRepository.defaultTextMessageString = customMessageTextView.text;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)indicateUpdateMessageAttemptFailure:(NSString *)errorString
{
    NSLog(@"Failure To Place Order! >>> %@", errorString);
}

@end
