//
//  MenuTableViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 10/17/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "MainMenuTableViewController.h"
#import "DataHold.h"
#import "WebServiceManager.h"
#import "UserOrder.h"

@implementation MainMenuTableViewController
{
    DataHold *sharedRepository;
    WebServiceManager *logoutManager;
    WebServiceManager *activeOrdersManager;
    WebServiceManager *orderHistoryManager;
    WebServiceManager *defaultTextMessageManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    sharedRepository = [[DataHold alloc] init];
    
    [self initializeLocalDatabaseFromExternalRepository];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"LogoutService" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"MenuActiveOrderService" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"MenuOrderHistoryService" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"MenuRetrieveDefaultTextMessageService" object:nil];
    
    logoutManager = [[WebServiceManager alloc] init];
    logoutManager.serviceNotificationType = @"LogoutService";
    
    activeOrdersManager = [[WebServiceManager alloc] init];
    activeOrdersManager.serviceNotificationType = @"MenuActiveOrderService";
    
    orderHistoryManager = [[WebServiceManager alloc] init];
    orderHistoryManager.serviceNotificationType = @"MenuOrderHistoryService";
    
    defaultTextMessageManager = [[WebServiceManager alloc] init];
    defaultTextMessageManager.serviceNotificationType = @"MenuRetrieveDefaultTextMessageService";
    
    [self initializeLocalDatabaseFromExternalRepository];
}

- (void)initializeLocalDatabaseFromExternalRepository
{
    [activeOrdersManager updateActiveOrders];
    [orderHistoryManager updateOrdersHistory];
    [defaultTextMessageManager retrieveDefaultTextMessage];
}

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
    NSDictionary *logoutCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       sharedRepository.userEmail, @"email",
                                       sharedRepository.sessionID, @"sessionId",
                                       nil];
    
    [logoutManager generatePostRequestAtRoute:sharedRepository.logoutURL withJSONBodyData:logoutCredentials];
    
    [self performLogoutOperation];
}

- (void)indicateLogoutAttemptFailure:(NSString *)errorString
{
    NSLog(@"Failure To Logout! >>> %@", errorString);
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"LogoutService"])
    {
        if(logoutManager.responseStatusCode == 200)
        {
            NSLog(@"Logout Successful");
        }
        else
        {
            NSLog(@"Failure To Logout! >>> %@", logoutManager.responseString);
        }
    }
    if([[notification name] isEqualToString:@"MenuActiveOrderService"])
    {
        if(activeOrdersManager.responseStatusCode == 200)
        {
            if(sharedRepository.debugModeActive)
            {
                NSLog(@"Active Orders Retrieved! %@", activeOrdersManager.responseString);
            }
            
            [sharedRepository.activeOrdersArray removeAllObjects];
            
            NSError *error;
            NSArray *jsonOrdersArray = [NSJSONSerialization JSONObjectWithData:activeOrdersManager.responseData options:0 error:&error];
            
            for(NSDictionary *x in jsonOrdersArray)
            {
                UserOrder *activeOrder = [[UserOrder alloc] init];
                
                activeOrder.orderNumber = [[x objectForKey:@"orderNumber"] stringValue];
                activeOrder.orderId = [x objectForKey:@"_id"];
                activeOrder.customerPhoneNumber = [x objectForKey:@"phoneNumber"];
                activeOrder.placementTime = [x objectForKey:@"timestamp"];
                activeOrder.orderFulfilled = FALSE;
                
                [sharedRepository.activeOrdersArray addObject:activeOrder];
            }
        }
        else
        {
            NSLog(@"FAILED TO RETRIEVE ACTIVE ORDERS!");// %@", responseData);
        }

    }
    if([[notification name] isEqualToString:@"MenuOrderHistoryService"])
    {
        if(orderHistoryManager.responseStatusCode == 200)
        {
            if(sharedRepository.debugModeActive)
            {
                NSLog(@"History Retrieved! %@", orderHistoryManager.responseString);
            }
            
            [sharedRepository.ordersHistoryArray removeAllObjects];
            
            NSError *error;
            NSArray *jsonHistoryArray = [NSJSONSerialization JSONObjectWithData:orderHistoryManager.responseData options:0 error:&error];
            
            for(NSDictionary *x in jsonHistoryArray)
            {
                UserOrder *fulfilledOrder = [[UserOrder alloc] init];
                
                fulfilledOrder.orderNumber = [[x objectForKey:@"orderNumber"] stringValue];
                fulfilledOrder.orderId = [x objectForKey:@"_id"];
                fulfilledOrder.customerPhoneNumber = [x objectForKey:@"phoneNumber"];
                fulfilledOrder.placementTime = [x objectForKey:@"timestamp"];
                fulfilledOrder.orderFulfilled = FALSE;
                
                [sharedRepository.ordersHistoryArray addObject:fulfilledOrder];
            }
        }
        else
        {
            NSLog(@"FAILED TO RETRIEVE ORDER HISTORY!");// %@", responseData);
        }
    }
    if([[notification name] isEqualToString:@"MenuRetrieveDefaultTextMessageService"])
    {
        if(defaultTextMessageManager.responseStatusCode == 200)
        {
            NSLog(@"Message Retrieved! %@", defaultTextMessageManager.responseString);
            
            NSString *rawString = defaultTextMessageManager.responseString;
            sharedRepository.defaultTextMessageString = [rawString substringWithRange:NSMakeRange(12, rawString.length - 14)];
        }
        else
        {
            NSLog(@"FAILED TO RETRIEVE DEFAULT MESSAGE!");// %@", responseData);
        }
    }
}

- (void)performLogoutOperation
{
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
