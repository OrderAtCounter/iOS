//
//  AddNewOrderTableViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/21/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewOrderTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *addNewOrderTableView;

@property (weak, nonatomic) IBOutlet UITextField *orderNumberTextField;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end
