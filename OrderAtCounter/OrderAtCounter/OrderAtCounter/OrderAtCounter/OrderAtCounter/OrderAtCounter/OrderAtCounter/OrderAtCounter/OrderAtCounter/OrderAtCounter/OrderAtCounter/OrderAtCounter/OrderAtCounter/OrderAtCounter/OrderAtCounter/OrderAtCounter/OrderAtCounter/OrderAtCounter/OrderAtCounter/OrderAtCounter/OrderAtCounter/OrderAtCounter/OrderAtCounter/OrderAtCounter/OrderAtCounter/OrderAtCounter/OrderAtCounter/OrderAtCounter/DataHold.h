//
//  DataHold.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHold : NSObject
{
    NSURL *webserviceURL;
    NSString *loginURL;
    NSString *logoutURL;
    NSString *createOrderURL;
    NSString *fulfillOrderURL;
    NSString *getOrdersURL;
    NSString *getTextMessageURL;
    NSString *updateTextMessageURL;
    NSString *getHistoryURL;
    NSString *deleteOrderURL;
    NSString *updateOrderURL;
    
    NSString *deviceType;
    
    NSString *userEmail;
    NSString *sessionID;
    
    NSMutableArray *activeOrdersArray;
    NSMutableArray *ordersHistoryArray;
    NSString *defaultTextMessageString;
    
    UIColor *greenColor;
    UIColor *redColor;
    
    BOOL debugModeActive;
}

@property NSURL *webserviceURL;
@property NSString *userEmail, *sessionID;
@property NSString *deviceType;
@property NSString *loginURL, *logoutURL, *createOrderURL, *fulfillOrderURL, *getOrdersURL, *getTextMessageURL, *updateTextMessageURL, *getHistoryURL, *deleteOrderURL, *updateOrderURL;
@property NSMutableArray *activeOrdersArray, *ordersHistoryArray;
@property NSString *defaultTextMessageString;
@property UIColor *greenColor, *redColor;
@property BOOL debugModeActive;

+ (DataHold *)sharedRepository;

- (void)cleanseLocalData;

- (void)activateDebugMode;
- (void)terminateDebugMode;

@end
