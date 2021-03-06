//
//  UserOrder.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/25/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserOrder : NSObject
{
    NSString *orderNumber;
    NSString *orderId;
    NSString *customerPhoneNumber;
    NSString *placementTime;
    NSString *customTextMessage;
    BOOL orderFulfilled;
}

@property NSString *orderNumber, *orderId, *customerPhoneNumber, *placementTime, *customTextMessage;
@property BOOL orderFulfilled;



- (id)initWithRandomData;
- (NSString *)retrieveFormattedPhoneNumber;

@end
