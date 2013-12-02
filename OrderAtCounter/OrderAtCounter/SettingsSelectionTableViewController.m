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
    DataHold *sharedrepository;
}

@synthesize settingsTableView;
@synthesize defaultTextMessageLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedrepository = [[DataHold alloc] init];
    
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
                                           sharedrepository.userEmail, @"email",
                                           sharedrepository.sessionID, @"sessionId",
                                           nil];
    
    [textMessageManager generatePostRequestAtRoute:sharedrepository.getTextMessageURL withJSONBodyData:textMessageCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       while(!textMessageManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       NSString *responseString = textMessageManager.responseString;
                       if(textMessageManager.responseStatusCode == 200)
                       {
                           NSLog(@"Response: %@", responseString);
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
