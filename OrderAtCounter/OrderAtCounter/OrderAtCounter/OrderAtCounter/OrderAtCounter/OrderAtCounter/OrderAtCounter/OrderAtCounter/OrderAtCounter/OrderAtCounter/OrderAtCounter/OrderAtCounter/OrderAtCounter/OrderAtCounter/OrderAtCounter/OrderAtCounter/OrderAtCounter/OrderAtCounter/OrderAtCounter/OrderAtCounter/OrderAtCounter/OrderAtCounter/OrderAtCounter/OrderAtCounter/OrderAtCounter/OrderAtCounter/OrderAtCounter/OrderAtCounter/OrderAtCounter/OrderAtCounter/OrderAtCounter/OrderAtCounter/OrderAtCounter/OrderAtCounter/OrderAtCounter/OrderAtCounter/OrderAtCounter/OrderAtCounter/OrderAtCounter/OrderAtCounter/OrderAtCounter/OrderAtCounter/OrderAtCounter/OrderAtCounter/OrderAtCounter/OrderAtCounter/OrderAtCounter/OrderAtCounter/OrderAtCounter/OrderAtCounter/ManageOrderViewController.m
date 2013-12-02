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
        
        UIImageView *detailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"little-phone.png"]];
        detailImageView.frame = CGRectMake(detailImageView.frame.origin.x + 8, detailImageView.frame.origin.y, 16, 25);
        
        cell.detailImage = detailImageView;
    }
    else if(indexPath.row == 1)
    {
        cell.detailLabel.text = @"Placement Time";
        cell.valueLabel.text = order.placementTime;
        
        UIImageView *detailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"little-clock.png"]];
        detailImageView.frame = CGRectMake(detailImageView.frame.origin.x + 12, detailImageView.frame.origin.y, 25, 25);
        
        cell.detailImage = detailImageView;
    }
    else if(indexPath.row == 2)
    {
        cell.detailLabel.text = @"Text Message";
        cell.valueLabel.text = @"Your order is ready!";
        
        UIImageView *detailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"little-message.png"]];
        detailImageView.frame = CGRectMake(detailImageView.frame.origin.x + 12, detailImageView.frame.origin.y, 25, 25);
        
        cell.detailImage = detailImageView;
    }
    
    [cell.imageView setNeedsDisplay];
    
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
    WebServiceManager *saveEditsManager = [[WebServiceManager alloc] init];
    
    NSString *editedPhoneNumber = ((OrderDetailCell *)[orderDetailsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).editValueTextField.text;
    
    NSDictionary *editsCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      sharedRepository.userEmail, @"email",
                                      sharedRepository.sessionID, @"sessionId",
                                      editedPhoneNumber, @"phoneNumber",
                                      editOrderNumberTextField.text, @"orderNumber",
                                      @"Your order is ready!", @"message",
                                     nil];
    
    [saveEditsManager generatePostRequestAtRoute:sharedRepository.updateOrderURL withJSONBodyData:editsCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!saveEditsManager.dataFinishedLoading)
                       {
                           [saveEditsActivityIndicator setHidden:FALSE];
                           [saveEditsActivityIndicator startAnimating];
                       }
                       
                       [saveEditsActivityIndicator stopAnimating];
                       [saveEditsActivityIndicator setHidden:TRUE];
                       
                       if(saveEditsManager.responseStatusCode == 200)
                       {
                           order.orderNumber = editOrderNumberTextField.text;
                           order.customerPhoneNumber = editedPhoneNumber;
                       }
                       else
                       {
                           [self indicateUpdateOrderFailure:saveEditsManager.responseString];
                       }
                       
                       if(sharedRepository.debugModeActive)
                       {
                           
                       }
                   });
    
    [self refreshUIForNonEditMode];
}

- (void)refreshUIForNonEditMode
{
    isEditMode = !isEditMode;
    self.navigationItem.rightBarButtonItem = editButton;
    
    [self refreshUI];
}

- (void)indicateUpdateOrderFailure:(NSString *)response
{
    NSLog(@"Failed to Update User Order! %@", response);
}

- (IBAction)cancelOrderButtonPressed:(id)sender
{
    WebServiceManager *cancelOrderManager = [[WebServiceManager alloc] init];
    
    NSDictionary *cancelCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      sharedRepository.userEmail, @"email",
                                      sharedRepository.sessionID, @"sessionId",
                                      order.orderId, @"orderId",
                                      nil];
    
    [cancelOrderManager generatePostRequestAtRoute:sharedRepository.deleteOrderURL withJSONBodyData:cancelCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!cancelOrderManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       [sharedRepository.activeOrdersArray removeObject:order];
                       
                       if(cancelOrderManager.responseStatusCode == 200)
                       {
                           
                       }
                       else
                       {
                           [self indicateCancelOrderFailure:cancelOrderManager.responseString];
                       }
                       
                       if(sharedRepository.debugModeActive)
                       {
                           
                       }
                   });
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)indicateCancelOrderFailure:(NSString *)response
{
    NSLog(@"Failed to Cancel User Order! %@", response);
}

@end
