//
//  DataHold.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "DataHold.h"

@implementation DataHold

@synthesize userEmail, sessionID;
@synthesize deviceType;
@synthesize webserviceURL, loginURL, logoutURL, createOrderURL, fulfillOrderURL, getOrdersURL, getTextMessageURL, updateTextMessageURL, getHistoryURL, updateOrderURL, deleteOrderURL;
@synthesize activeOrdersArray, ordersHistoryArray;
@synthesize defaultTextMessageString;
@synthesize greenColor, redColor;
@synthesize debugModeActive;

+ (DataHold *)sharedRepository
{
    static DataHold *sharedRepository = nil;
    
    if(!sharedRepository)
    {
        sharedRepository = [[super allocWithZone:nil] init];
    }
    
    return sharedRepository;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedRepository];
}

- (void)cleanseLocalData
{
    userEmail = nil;
    sessionID = nil;
    [activeOrdersArray removeAllObjects];
    [ordersHistoryArray removeAllObjects];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"userSessionID"];
    [defaults setObject:nil forKey:@"userEmail"];
    [defaults synchronize];
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (void)activateDebugMode
{
    debugModeActive = TRUE;
}

- (void)terminateDebugMode
{
    debugModeActive = FALSE;
}

@end
