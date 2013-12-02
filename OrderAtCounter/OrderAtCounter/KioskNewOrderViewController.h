//
//  KioskNewOrderViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 12/1/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KioskNewOrderViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UITextField *orderNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;

- (IBAction)oneButtonPressed:(id)sender;
- (IBAction)twoButtonPressed:(id)sender;
- (IBAction)threeButtonPressed:(id)sender;
- (IBAction)fourButtonPressed:(id)sender;
- (IBAction)fiveButtonPressed:(id)sender;
- (IBAction)sixButtonPressed:(id)sender;
- (IBAction)sevenButtonPressed:(id)sender;
- (IBAction)eightButtonPressed:(id)sender;
- (IBAction)nineButtonPressed:(id)sender;
- (IBAction)zeroButtonPressed:(id)sender;


- (IBAction)resetButtonPressed:(id)sender;

- (IBAction)undoButtonPressed:(id)sender;

- (IBAction)cancelButtonPressed:(id)sender;

- (IBAction)submitButtonPressed:(id)sender;

@end
