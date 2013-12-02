//
//  LoginViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *customerLogoImageView;

- (IBAction)emailGestureRecognizerTapped:(id)sender;
- (IBAction)passwordGestureRecognizerTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonPressed:(id)sender;

@end
