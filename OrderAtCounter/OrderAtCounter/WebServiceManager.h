//
//  WebServiceManager.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceManager : NSObject <NSURLConnectionDelegate>
{
    int responseStatusCode;
    NSMutableData *responseData;
    NSString *responseString;
    BOOL dataFinishedLoading;
    BOOL dataIsReady;
    
    NSString *serviceNotificationType;
}

@property int responseStatusCode;
@property NSMutableData *responseData;
@property NSString *responseString;
@property BOOL dataFinishedLoading, dataIsReady;
@property NSString *serviceNotificationType;

- (void)generatePostRequestAtRoute:(NSString *)route withJSONBodyData:(NSDictionary *)bodyData;
- (void)generateGetRequestAtRoute:(NSString *)route withJSONBodyData:(NSDictionary *)bodyData;

- (NSString *)getDataFromResponseString;
- (void)updateActiveOrders;
- (void)updateOrdersHistory;
- (void)retrieveDefaultTextMessage;

@end
