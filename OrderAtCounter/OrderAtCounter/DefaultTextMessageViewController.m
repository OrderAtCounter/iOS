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
    
    WebServiceManager *updateMessageManager;
}

@synthesize customMessageTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    customMessageTextView.text = sharedRepository.defaultTextMessageString;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"MessageUpdateService" object:nil];
    
    updateMessageManager = [[WebServiceManager alloc] init];
    updateMessageManager.serviceNotificationType = @"MessageUpdateService";
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
    NSDictionary *orderCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      sharedRepository.userEmail, @"email",
                                      sharedRepository.sessionID, @"sessionId",
                                      customMessageTextView.text, @"message",
                                      nil];
    
    //NSLog(@"Email: %@;  SessionID: %@", sharedRepository.userEmail, sharedRepository.sessionID);
    //NSLog(@"Order: %@; Phone: %@", orderNumberTextField.text, phoneNumberTextField.text);
    
    [updateMessageManager generatePostRequestAtRoute:sharedRepository.updateTextMessageURL withJSONBodyData:orderCredentials];
    
    sharedRepository.defaultTextMessageString = customMessageTextView.text;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"MessageUpdateService"])
    {
        if(updateMessageManager.responseStatusCode == 200)
        {
            NSLog(@"Message Updated!");
        }
        else
        {
            NSLog(@"Failure to Update Default Text Message! %@", updateMessageManager.responseString);
        }
    }
}

@end
