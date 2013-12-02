//
//  KioskNewOrderViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 12/1/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "KioskNewOrderViewController.h"
#import "WebServiceManager.h"
#import "DataHold.h"

@interface KioskNewOrderViewController ()

@end

@implementation KioskNewOrderViewController
{
    DataHold *sharedRepository;
    UITextField *currentlyEditingTextField;
}

@synthesize navBar, orderNumberTextField, phoneNumberTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    currentlyEditingTextField = [[UITextField alloc] init];
    
    self.navigationController.navigationBar.translucent = NO;
    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont fontWithName:@"MontserratBold.tff" size:14], NSFontAttributeName,
//                                sharedRepository.redColor, NSForegroundColorAttributeName,
//                                nil];
//    
//    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : sharedRepository.redColor};
    
    orderNumberTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    phoneNumberTextField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    
    orderNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    orderNumberTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    phoneNumberTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    
    //orderNumberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //phoneNumberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [orderNumberTextField isFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        currentlyEditingTextField = orderNumberTextField;
    }
    else if(textField.tag == 2)
    {
        currentlyEditingTextField = phoneNumberTextField;
    }
}

- (IBAction)oneButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"1"];
}

- (IBAction)twoButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"2"];
}

- (IBAction)threeButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"3"];
}

- (IBAction)fourButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"4"];
}

- (IBAction)fiveButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"5"];
}

- (IBAction)sixButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"6"];
}

- (IBAction)sevenButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"7"];
}

- (IBAction)eightButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"8"];
}

- (IBAction)nineButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"9"];
}

- (IBAction)zeroButtonPressed:(id)sender
{
    [self ammendTextBoxFieldWith:@"0"];
}

- (void)ammendTextBoxFieldWith:(NSString *)value
{
    if(currentlyEditingTextField.tag == 1 || (currentlyEditingTextField.tag == 2 && [currentlyEditingTextField.text length] < 10))
    {
        currentlyEditingTextField.text = [NSString stringWithFormat:@"%@%@", currentlyEditingTextField.text, value];
    }
}

- (IBAction)resetButtonPressed:(id)sender
{
    orderNumberTextField.text = nil;
    phoneNumberTextField.text = nil;
}

- (IBAction)undoButtonPressed:(id)sender
{
    if(currentlyEditingTextField.text.length > 0)
    {
        currentlyEditingTextField.text = [currentlyEditingTextField.text substringToIndex:[currentlyEditingTextField.text length] -1];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitButtonPressed:(id)sender
{
    [self processPlaceOrderRequest];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)processPlaceOrderRequest
{
    WebServiceManager *createOrderManager = [[WebServiceManager alloc] init];
    
    NSDictionary *orderCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      sharedRepository.userEmail, @"email",
                                      sharedRepository.sessionID, @"sessionId",
                                      orderNumberTextField.text, @"orderNumber",
                                      phoneNumberTextField.text, @"phoneNumber",
                                      nil];
    
    //NSLog(@"Email: %@;  SessionID: %@", sharedRepository.userEmail, sharedRepository.sessionID);
    //NSLog(@"Order: %@; Phone: %@", orderNumberTextField.text, phoneNumberTextField.text);
    
    [createOrderManager generatePostRequestAtRoute:sharedRepository.createOrderURL withJSONBodyData:orderCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       while(!createOrderManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       NSString *responseString = createOrderManager.responseString;
                       if(createOrderManager.responseStatusCode == 200)
                       {
                           if(sharedRepository.debugModeActive)
                           {
                               NSLog(@"Order Placed! %@", responseString);
                           }
                       }
                       else
                       {
                           [self indicateOrderPlacementAttemptFailure:responseString];
                       }
                   });
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)indicateOrderPlacementAttemptFailure:(NSString *)errorString
{
    NSLog(@"Failure To Place Order! >>> %@", errorString);
}

@end
