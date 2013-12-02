//
//  UserOrder.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/25/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "DataHold.h"
#import "UserOrder.h"
#import "WebServiceManager.h"

@implementation UserOrder

@synthesize orderNumber, orderId, customerPhoneNumber, placementTime, orderFulfilled, customTextMessage;

- (id)initWithRandomData
{
    [self generateNewUserOrder];
    return self;
}

- (void)generateNewUserOrder
{
    self.orderNumber = [NSString stringWithFormat:@"%d", (arc4random() % 100) + 1];
    self.orderId = @"Order Description";
    self.customerPhoneNumber = @"7701234567";
    self.placementTime = @"12:00 PM";
}

- (NSString *)retrieveFormattedPhoneNumber
{
    NSString *formattedNumber = customerPhoneNumber;
    
    NSString *number = [customerPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if([number length] == 10)
    {
        NSString *areaCode = [number substringWithRange:NSMakeRange(0, 3)];
        NSString *prefix =[number substringWithRange:NSMakeRange(3, 3)];
        NSString *line = [number substringWithRange:NSMakeRange(6, 4)];
        
        formattedNumber = [NSString stringWithFormat:@"(%@) %@-%@", areaCode, prefix, line];
    }
    
    return formattedNumber;
}

@end
