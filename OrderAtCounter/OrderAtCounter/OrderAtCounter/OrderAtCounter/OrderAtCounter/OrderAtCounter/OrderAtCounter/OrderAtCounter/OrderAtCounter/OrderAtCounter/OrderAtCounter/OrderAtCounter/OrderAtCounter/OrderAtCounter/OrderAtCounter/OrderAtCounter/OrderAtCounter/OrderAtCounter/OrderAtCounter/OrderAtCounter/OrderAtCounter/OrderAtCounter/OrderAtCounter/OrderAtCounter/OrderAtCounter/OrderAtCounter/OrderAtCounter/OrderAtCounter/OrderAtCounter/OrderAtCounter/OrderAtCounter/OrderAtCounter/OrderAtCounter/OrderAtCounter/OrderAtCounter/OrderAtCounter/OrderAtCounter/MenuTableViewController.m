//
//  MenuTableViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 10/17/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "MenuTableViewController.h"
#import "DataHold.h"
#import "WebServiceManager.h"

@implementation MenuTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    // Update Active Orders
    WebServiceManager *updateActiveAndFulfilledOrdersManager = [[WebServiceManager alloc] init];
    [updateActiveAndFulfilledOrdersManager updateActiveOrders];
    //[updateActiveAndFulfilledOrdersManager updateOrdersHistory];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 4)
    {
        [self processUserLogoutAttempt];
    }
}

- (void)processUserLogoutAttempt
{
    DataHold *sharedRepository = [[DataHold alloc] init];
    
    WebServiceManager *logoutManager = [[WebServiceManager alloc] init];
    
    NSDictionary *logoutCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       sharedRepository.userEmail, @"email",
                                       sharedRepository.sessionID, @"sessionId",
                                       nil];
    
    [logoutManager generatePostRequestAtRoute:sharedRepository.logoutURL withJSONBodyData:logoutCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!logoutManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       NSString *responseString = logoutManager.responseString;
                       if(logoutManager.responseStatusCode == 200)
                       {
                           if(sharedRepository.debugModeActive)
                           {
                               NSLog(@"Logout Successful");
                           }
                       }
                       else
                       {
                           [self indicateLogoutAttemptFailure:responseString];
                       }
                       
                       
                   });
    
    [self performLogoutOperation];
}

- (void)indicateLogoutAttemptFailure:(NSString *)errorString
{
    NSLog(@"Failure To Logout! >>> %@", errorString);
}

- (void)performLogoutOperation
{
    DataHold *sharedRepository = [[DataHold alloc] init];
    
    [sharedRepository cleanseLocalData];
    
    if([sharedRepository.deviceType isEqualToString:@"iPhone Simulator"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        
        UIViewController *viewController = [storyboard  instantiateViewControllerWithIdentifier:@"iPhoneLoginView"];
        [UIApplication sharedApplication].delegate.window.rootViewController = viewController;
    }
    else // [deviceType isEqualToString:@"iPad Simulator"]
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"iPadLoginView"];
        [UIApplication sharedApplication].delegate.window.rootViewController = viewController;
    }
}

@end
