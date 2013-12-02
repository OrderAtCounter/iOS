//
//  OrderDetailViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/30/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserOrder.h"

@interface ManageOrderViewController : UIViewController <UITableViewDelegate, UITableViewDelegate, UITextFieldDelegate>
{
    UserOrder *order;
}

@property UserOrder *order;

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;

@property (weak, nonatomic) IBOutlet UITextField *editOrderNumberTextField;

@property (weak, nonatomic) IBOutlet UITableView *orderDetailsTableView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *saveEditsActivityIndicator;


- (IBAction)cancelOrderButtonPressed:(id)sender;

@end