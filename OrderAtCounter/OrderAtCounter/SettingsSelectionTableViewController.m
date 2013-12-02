//
//  SettingsSelectionTableViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/21/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "SettingsSelectionTableViewController.h"
#import "DataHold.h"
#import "WebServiceManager.h"

@interface SettingsSelectionTableViewController ()

@end

@implementation SettingsSelectionTableViewController
{
    DataHold *sharedRepository;
}

@synthesize settingsTableView;
@synthesize defaultTextMessageLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    settingsTableView.tableFooterView = [UIView new];
    
    [self updateCustomTextMessage];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellHeight = 50;
    
    return cellHeight;
}

- (void)updateCustomTextMessage
{
    WebServiceManager *textMessageManager = [[WebServiceManager alloc] init];
    
    NSDictionary *textMessageCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           sharedRepository.userEmail, @"email",
                                           sharedRepository.sessionID, @"sessionId",
                                           nil];
    
    [textMessageManager generatePostRequestAtRoute:sharedRepository.getTextMessageURL withJSONBodyData:textMessageCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       while(!textMessageManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       NSString *responseString = textMessageManager.responseString;
                       if(textMessageManager.responseStatusCode == 200)
                       {
                           sharedRepository.defaultTextMessageString = [responseString substringWithRange:NSMakeRange(12, responseString.length - 14)];
                       }
                       else
                       {
                           [self indicateTextMessageRetrievalFailure:responseString];
                       }
                   });
}

- (void)indicateTextMessageRetrievalFailure:(NSString *)errorString
{
    NSLog(@"Failure To Retrieve Custom Text Message! >>> %@", errorString);
}

@end
