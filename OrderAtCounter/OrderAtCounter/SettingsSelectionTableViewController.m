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
    WebServiceManager *textMessageManager;
}

@synthesize settingsTableView;
@synthesize defaultTextMessageLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    settingsTableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"RetrieveDefaultTextMessageService" object:nil];
    
    textMessageManager = [[WebServiceManager alloc] init];
    textMessageManager.serviceNotificationType = @"RetrieveDefaultTextMessageService";
    
    if(!sharedRepository.defaultTextMessageString)
    {
        [textMessageManager retrieveDefaultTextMessage];
    }
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

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"RetrieveDefaultTextMessageService"])
    {
        NSLog(@"DEFAULT TEXT MESSAGE RETRIEVED");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           [self parseResponseData];
                       });
    }
}

- (void)parseResponseData
{
    if(textMessageManager.responseStatusCode == 200)
    {
        NSLog(@"Message Retrieved! %@", textMessageManager.responseString);
        
        NSString *rawString = textMessageManager.responseString;
        sharedRepository.defaultTextMessageString = [rawString substringWithRange:NSMakeRange(12, rawString.length - 14)];
    }
    else
    {
        NSLog(@"FAILED TO RETRIEVE DEFAULT MESSAGE!");// %@", responseData);
    }
}

@end
