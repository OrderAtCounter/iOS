//
//  OrderDetailViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/30/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "ManageOrderViewController.h"
#import "DataHold.h"
#import "OrderDetailCell.h"
#import "WebServiceManager.h"

@interface ManageOrderViewController ()

@end

@implementation ManageOrderViewController
{
    DataHold *sharedRepository;
    BOOL isEditMode;
    UIBarButtonItem *editButton;
    UIBarButtonItem *saveButton;
    UITapGestureRecognizer *exteriorTap;
    
    WebServiceManager *saveEditsManager;
    WebServiceManager *cancelOrderManager;
}

@synthesize order;
@synthesize orderNumberLabel;
@synthesize orderDetailsTableView;
@synthesize editOrderNumberTextField;
@synthesize saveEditsActivityIndicator;
@synthesize cancelButton;

- (void)viewDidLoad
{
    sharedRepository = [[DataHold alloc] init];
    
    editOrderNumberTextField.text = order.orderNumber;
    
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    [self recolorStatusAndNavigatioNBars:sharedRepository.redColor];
    
    self.navigationItem.rightBarButtonItem = editButton;
    isEditMode = FALSE;
    
    saveEditsActivityIndicator.hidden = TRUE;
    
    exteriorTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBarKeyboard)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"SaveOrderEditsService" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"CancelOrderService" object:nil];
    
    saveEditsManager = [[WebServiceManager alloc] init];
    saveEditsManager.serviceNotificationType = @"SaveOrderEditsService";
    
    cancelOrderManager = [[WebServiceManager alloc] init];
    cancelOrderManager.serviceNotificationType = @"CancelOrderService";
    
    [self refreshUI];
}

- (void)recolorStatusAndNavigatioNBars:(UIColor *)color
{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 7)
    {
        [navigationBar setBarTintColor:color];
        [navigationBar setTranslucent:NO];
        [navigationBar setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [navigationBar setTintColor:color];
    }
    
    navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self recolorStatusAndNavigatioNBars:sharedRepository.greenColor];
}

- (void)refreshUI
{
    orderNumberLabel.text = editOrderNumberTextField.text;
    
    if(!isEditMode)
    {
        orderNumberLabel.hidden = FALSE;
        editOrderNumberTextField.hidden = TRUE;
        cancelButton.enabled = TRUE;
        cancelButton.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        editOrderNumberTextField.hidden = FALSE;
        orderNumberLabel.hidden = TRUE;
        cancelButton.enabled = FALSE;
        cancelButton.backgroundColor = [UIColor grayColor];
    }
    
    [orderDetailsTableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    
    if (nil == cell)
    {
        cell = [[OrderDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DetailCell"];
    }
    
    cell.detailLabel.textColor = sharedRepository.greenColor;
    
    [cell.detailLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [cell.valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    
    if(indexPath.row == 0)
    {
        if(isEditMode)
        {
            cell.isEditMode = TRUE;
        }
        else
        {
            cell.isEditMode = FALSE;
        }
        
        cell.detailLabel.text = @"Phone Number";
        cell.valueLabel.text = order.customerPhoneNumber;
        cell.editValueTextField.text = [order.customerPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    else if(indexPath.row == 1)
    {
        cell.detailLabel.text = @"Placement Time";
        cell.valueLabel.text = order.placementTime;
    }
    else if(indexPath.row == 2)
    {
        if(isEditMode)
        {
            cell.isEditMode = TRUE;
        }
        else
        {
            cell.isEditMode = FALSE;
        }
        
        cell.detailLabel.text = @"Text Message";
        
        NSString *customMessage = order.customTextMessage;
        
        cell.editValueTextField.keyboardType = UIKeyboardTypeAlphabet;
        if(customMessage == nil)
        {
            cell.valueLabel.text = sharedRepository.defaultTextMessageString;
            cell.editValueTextField.text = sharedRepository.defaultTextMessageString;
        }
        else
        {
            cell.valueLabel.text = order.customTextMessage;
            cell.editValueTextField.text = order.customTextMessage;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellHeight = 80;
    
    return cellHeight;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view addGestureRecognizer:exteriorTap];
}

- (void)dismissSearchBarKeyboard
{
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:exteriorTap];
}

- (void)editButtonPressed
{
    isEditMode = !isEditMode;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self refreshUI];
}

- (void)saveButtonPressed
{
    [self.view endEditing:YES];
    [self saveEditedData];
}

- (void)saveEditedData
{
    NSString *editedPhoneNumber = ((OrderDetailCell *)[orderDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).editValueTextField.text;
    
    NSString *editedTextMessage = ((OrderDetailCell *)[orderDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).editValueTextField.text;
    
    NSDictionary *editsCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      sharedRepository.userEmail, @"email",
                                      sharedRepository.sessionID, @"sessionId",
                                      order.orderId, @"orderId",
                                      editedPhoneNumber, @"phoneNumber",
                                      editOrderNumberTextField.text, @"orderNumber",
                                      editedTextMessage, @"message",
                                     nil];
    
    [saveEditsManager generatePostRequestAtRoute:sharedRepository.updateOrderURL withJSONBodyData:editsCredentials];
    
    [saveEditsActivityIndicator setHidden:FALSE];
    [saveEditsActivityIndicator startAnimating];
    
    UserOrder *editOrder = [[UserOrder alloc] init];
    editOrder.orderNumber = editOrderNumberTextField.text;
    editOrder.placementTime = order.placementTime;
    editOrder.customerPhoneNumber = editedPhoneNumber;
    
    if(![editedTextMessage isEqualToString:sharedRepository.defaultTextMessageString])
    {
        editOrder.customTextMessage = editedTextMessage;
    }
    
    [sharedRepository.activeOrdersArray removeObject:order];
    [sharedRepository.activeOrdersArray addObject:editOrder];
    
    [self refreshUIForNonEditMode];
}

- (IBAction)cancelOrderButtonPressed:(id)sender
{
    NSDictionary *cancelCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       sharedRepository.userEmail, @"email",
                                       sharedRepository.sessionID, @"sessionId",
                                       order.orderId, @"orderId",
                                       nil];
    
    [cancelOrderManager generatePostRequestAtRoute:sharedRepository.deleteOrderURL withJSONBodyData:cancelCredentials];
    
    [sharedRepository.activeOrdersArray removeObject:order];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"SaveOrderEditsService"])
    {
        [saveEditsActivityIndicator stopAnimating];
        [saveEditsActivityIndicator setHidden:TRUE];
        
        if(saveEditsManager.responseStatusCode == 200)
        {
            NSLog(@"Order Changes Saved Successfully!");
            NSString *editedPhoneNumber = ((OrderDetailCell *)[orderDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).editValueTextField.text;
            
            order.orderNumber = editOrderNumberTextField.text;
            order.customerPhoneNumber = editedPhoneNumber;
        }
        else
        {
            NSLog(@"Could Not Save Order Changes! %@", saveEditsManager.responseString);
        }
    }
    else if([[notification name] isEqualToString:@"CancelOrderService"])
    {
        if(cancelOrderManager.responseStatusCode == 200)
        {
            NSLog(@"Order Deleted!");
        }
        else
        {
            NSLog(@"Failure To Delete Order! %@", cancelOrderManager.responseString);
        }
    }
}

- (void)refreshUIForNonEditMode
{
    isEditMode = !isEditMode;
    self.navigationItem.rightBarButtonItem = editButton;
    
    [self refreshUI];
}

@end
