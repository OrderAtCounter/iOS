//
//  KioskGreetingViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 12/1/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KioskGreetingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *addNewOrderButton;

- (IBAction)logoutButtonPressed:(id)sender;

@end
