//
//  AddNewOrderTableViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/21/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "NewOrderTableViewController.h"
#import "DataHold.h"
#import "UserOrder.h"
#import "WebServiceManager.h"

@interface NewOrderTableViewController ()

@end

@implementation NewOrderTableViewController
{
    DataHold *sharedRepository;
    WebServiceManager *createOrderManager;
}

@synthesize addNewOrderTableView, orderNumberTextField, phoneNumberTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    [self recolorStatusAndNavigatioNBars];
    
    addNewOrderTableView.tableFooterView = [UIView new];
    
    [orderNumberTextField becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"CreateOrderService" object:nil];
    
    createOrderManager = [[WebServiceManager alloc] init];
    createOrderManager.serviceNotificationType = @"CreateOrderService";
}

- (void)recolorStatusAndNavigatioNBars
{
    UIColor *greenColor = sharedRepository.greenColor;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 7)
    {
        [navigationBar setBarTintColor:greenColor];
        [navigationBar setTranslucent:NO];
        [navigationBar setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [navigationBar setTintColor:greenColor];
    }
    
    navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellHeight = 60;
    
    return cellHeight;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == orderNumberTextField)
    {
        [phoneNumberTextField becomeFirstResponder];
    }
    
    if(textField == phoneNumberTextField)
    {
        [self processPlaceOrderRequest];
    }
    
    return YES;
}

- (void)processPlaceOrderRequest
{
    NSDictionary *orderCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      sharedRepository.userEmail, @"email",
                                      sharedRepository.sessionID, @"sessionId",
                                      orderNumberTextField.text, @"orderNumber",
                                      phoneNumberTextField.text, @"phoneNumber",
                                      nil];
    
    //NSLog(@"Email: %@;  SessionID: %@", sharedRepository.userEmail, sharedRepository.sessionID);
    //NSLog(@"Order: %@; Phone: %@", orderNumberTextField.text, phoneNumberTextField.text);
    
    [createOrderManager generatePostRequestAtRoute:sharedRepository.createOrderURL withJSONBodyData:orderCredentials];
    
    UserOrder *newOrder = [[UserOrder alloc] init];
    newOrder.orderNumber = orderNumberTextField.text;
    newOrder.customerPhoneNumber = phoneNumberTextField.text;
    newOrder.placementTime = @"Just Now";
    
    [sharedRepository.activeOrdersArray addObject:newOrder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"CreateOrderService"])
    {
        if(createOrderManager.responseStatusCode == 200)
        {
            if(sharedRepository.debugModeActive)
            {
                NSLog(@"Order Placed! %@", createOrderManager.responseString);
            }
        }
        else
        {
            [self indicateOrderPlacementAttemptFailure:createOrderManager.responseString];
        }
    }
}

- (void)indicateOrderPlacementAttemptFailure:(NSString *)errorString
{
    NSLog(@"Failure To Place Order! >>> %@", errorString);
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender
{
    [self processPlaceOrderRequest];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
