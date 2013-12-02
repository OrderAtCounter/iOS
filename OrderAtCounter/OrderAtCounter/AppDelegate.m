//
//  AppDelegate.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "AppDelegate.h"
#import "DataHold.h"
#import "UserOrder.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    DataHold *sharedRepository = [[DataHold alloc] init];
    
    sharedRepository.deviceType = [UIDevice currentDevice].model;
    
    sharedRepository.webserviceURL = [NSURL URLWithString:@"http://orderatcounter.herokuapp.com"];
    //sharedRepository.webserviceURL = [NSURL URLWithString:@"http://localhost:3001"];
    sharedRepository.loginURL = @"iOSLogin";
    sharedRepository.logoutURL = @"iOSLogout";
    sharedRepository.createOrderURL = @"iOSOrder";
    sharedRepository.fulfillOrderURL = @"iOSFulfillOrder";                  // (email, sessionId, orderId)
    sharedRepository.getOrdersURL = @"iOSOrders";
    sharedRepository.getTextMessageURL = @"iOSGetMessage";                  // (email, sessionId)
    sharedRepository.updateTextMessageURL = @"iOSUpdateMessage";            // (email, sessionId, message)
    sharedRepository.getHistoryURL = @"iOSGetHistory";
    sharedRepository.deleteOrderURL = @"iOSDeleteOrder";                    // (email, sessionId, orderId)
    sharedRepository.updateOrderURL = @"iOSUpdateOrder";                    // (email, sessionId, phoneNumber, orderNumber, message)
    
    sharedRepository.activeOrdersArray = [[NSMutableArray alloc] init];
    sharedRepository.ordersHistoryArray = [[NSMutableArray alloc] init];
    
    sharedRepository.greenColor = [UIColor colorWithRed:113.0/255.0f green:194.0/255.0f blue:179.0/255.0f alpha:1.0f];
    sharedRepository.redColor = [UIColor colorWithRed:239.0/255.0f green:73.0/255.0f blue:58.0/255.0f alpha:1.0f];
    
    sharedRepository.debugModeActive = TRUE;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    DataHold *sharedRepository = [[DataHold alloc] init];
    NSLog(@"?? %@", sharedRepository.activeOrdersArray);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
