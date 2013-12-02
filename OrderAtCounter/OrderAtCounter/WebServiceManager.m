//
//  WebServiceManager.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "WebServiceManager.h"
#import "DataHold.h"
#import "UserOrder.h"

@implementation WebServiceManager
{
    DataHold *sharedRepository;
}

@synthesize responseStatusCode, responseData, responseString, dataFinishedLoading, dataIsReady;

- (void)generatePostRequestAtRoute:(NSString *)route withJSONBodyData:(NSDictionary *)bodyData
{
    sharedRepository = [[DataHold alloc] init];
    
    NSMutableURLRequest *webserviceRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:route relativeToURL:sharedRepository.webserviceURL]];
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:bodyData options:0 error:&error];
    
    webserviceRequest.HTTPMethod = @"POST";
    webserviceRequest.HTTPBody = postData;
    [webserviceRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:webserviceRequest delegate:self];
    [connection start];
}

- (void)generateGetRequestAtRoute:(NSString *)route withJSONBodyData:(NSDictionary *)bodyData
{
    sharedRepository = [[DataHold alloc] init];
    
    NSMutableURLRequest *webserviceRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:route relativeToURL:sharedRepository.webserviceURL]];
    
    NSError *error = nil;
    NSData *getData = [NSJSONSerialization dataWithJSONObject:bodyData options:0 error:&error];
    
    webserviceRequest.HTTPMethod = @"GET";
    webserviceRequest.HTTPBody = getData;
    [webserviceRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:webserviceRequest delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    dataFinishedLoading = TRUE;
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection Failure!");
    NSLog(@"Error: %@", error);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (NSString *)getDataFromResponseString
{
    NSString *dataSubstring = responseString;
    
    if([dataSubstring rangeOfString:@"sessionId"].location != NSNotFound)
    {
        NSArray *dataArray = [dataSubstring componentsSeparatedByString:@"\""];
        
        dataSubstring = dataArray[3];
    }
    
    if(sharedRepository.debugModeActive)
    {
        NSLog(@"Response Data: %@", dataSubstring);
    }
    
    return dataSubstring;
}

- (void)updateActiveOrders:(NSTimer *)theTimer
{
    [self updateActiveOrders];
}

- (void)updateActiveOrders
{
    if(!sharedRepository)
    {
        sharedRepository = [[DataHold alloc] init];
    }
    
    NSDictionary *retrieveActiveOrdersCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     sharedRepository.userEmail, @"email",
                                                     sharedRepository.sessionID, @"sessionId",
                                                     nil];
    
    NSLog(@"Retrieving Active Orders");
    NSLog(@"Email: %@", sharedRepository.userEmail);
    NSLog(@"Session: %@", sharedRepository.sessionID);
    
    [self generatePostRequestAtRoute:sharedRepository.getOrdersURL withJSONBodyData:retrieveActiveOrdersCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!dataFinishedLoading)
                       {
                           
                       }
                       
                       if(responseStatusCode == 200)
                       {
                           if(sharedRepository.debugModeActive)
                           {
                               NSLog(@"Active Orders Retrieved! %@", responseString);
                           }
                           
                           [sharedRepository.activeOrdersArray removeAllObjects];
                           
                           NSError *error;
                           NSArray *jsonOrdersArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                           
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
                           
                           dataIsReady = TRUE;
                       }
                       else
                       {
                           NSLog(@"FAILED TO RETRIEVE ACTIVE ORDERS!");// %@", responseData);
                       }
                       
                       dataIsReady = FALSE;
                   });
}

- (void)updateOrdersHistory:(NSTimer *)theTimer
{
    [self updateOrdersHistory];
}

- (void)updateOrdersHistory
{
    if(!sharedRepository)
    {
        sharedRepository = [[DataHold alloc] init];
    }
    
    NSDictionary *retrieveActiveOrdersCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                     sharedRepository.userEmail, @"email",
                                                     sharedRepository.sessionID, @"sessionId",
                                                     nil];
    
    NSLog(@"Retrieving Orders History");
    NSLog(@"Email: %@", sharedRepository.userEmail);
    NSLog(@"Session: %@", sharedRepository.sessionID);
    
    [self generatePostRequestAtRoute:sharedRepository.getHistoryURL withJSONBodyData:retrieveActiveOrdersCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!dataFinishedLoading)
                       {
                           
                       }
                       
                       if(responseStatusCode == 200)
                       {
                           if(sharedRepository.debugModeActive)
                           {
                               NSLog(@"History Retrieved! %@", responseString);
                           }
                           
                           [sharedRepository.ordersHistoryArray removeAllObjects];
                           
                           NSError *error;
                           NSArray *jsonHistoryArray = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                           
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
                           
                           dataIsReady = TRUE;
                       }
                       else
                       {
                           NSLog(@"FAILED TO RETRIEVE ORDER HISTORY!");// %@", responseData);
                       }
                       
                       dataIsReady = FALSE;
                   });
}

- (void)retrieveDefaultTextMessage
{
    if(!sharedRepository)
    {
        sharedRepository = [[DataHold alloc] init];
    }
    
    NSDictionary *textMessageCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            sharedRepository.userEmail, @"email",
                                            sharedRepository.sessionID, @"sessionId",
                                            nil];
    
    NSLog(@"Retrieving Default Text Message!");
    NSLog(@"Email: %@", sharedRepository.userEmail);
    NSLog(@"Session: %@", sharedRepository.sessionID);
    
    [self generatePostRequestAtRoute:sharedRepository.getTextMessageURL withJSONBodyData:textMessageCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       while(!dataFinishedLoading)
                       {
                           
                       }
                       
                       if(responseStatusCode == 200)
                       {
                           NSLog(@"Message Retrieved! %@", responseString);
                           
                           sharedRepository.defaultTextMessageString = [responseString substringWithRange:NSMakeRange(12, responseString.length - 14)];
                       }
                       else
                       {
                           NSLog(@"FAILED TO RETRIEVE CUSTOM MESSAGE!");// %@", responseData);
                       }
                   });
}


@end
