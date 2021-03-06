//
//  LoginViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "LoginViewController.h"
#import "MainMenuTableViewController.h"
#import "KioskGreetingViewController.h"
#import "WebServiceManager.h"
#import "DataHold.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    DataHold *sharedRepository;
    WebServiceManager *loginManager;
}

@synthesize customerLogoImageView, emailTextField, passwordTextField, loginActivityIndicator, loginButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    UITapGestureRecognizer *exteriorTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:exteriorTap];
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0f green:247.0/255.0f blue:245.0/255.0f alpha:1.0f];
    
    [loginButton setTitleColor:sharedRepository.greenColor forState:UIControlStateNormal];
    
    passwordTextField.secureTextEntry = TRUE;
    
    loginActivityIndicator.hidden = TRUE;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionID = [defaults objectForKey:@"userSessionID"];
    NSString *userEmail = [defaults objectForKey:@"userEmail"];
    if(nil != sessionID)
    {
        sharedRepository.sessionID = sessionID;
        sharedRepository.userEmail = userEmail;
        [self proceedWithLogin];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"LoginService" object:nil];
    
    loginManager = [[WebServiceManager alloc] init];
    loginManager.serviceNotificationType = @"LoginService";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self adjustFrameOriginTo:-150];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self adjustFrameOriginTo:20];
}

- (void)adjustFrameOriginTo:(int)origin
{
    CGRect frame = [self.view frame];
    
    if([sharedRepository.deviceType isEqualToString:@"iPhone Simulator"])
    {
        frame.origin.y = origin;
    }
    else
    {
        frame.origin.x = origin;
    }
    
    [self.view setFrame:frame];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == emailTextField)
    {
        [passwordTextField becomeFirstResponder];
    }
    
    if(textField == passwordTextField)
    {
        [self adjustFrameOriginTo:20];
        [self dismissKeyboard];
        [self processUserLoginAttempt];
    }
    
    return YES;
}

- (void)dismissKeyboard
{
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

- (IBAction)loginButtonPressed:(id)sender
{
    [self adjustFrameOriginTo:20];
    [self dismissKeyboard];
    [self processUserLoginAttempt];
}

- (void)processUserLoginAttempt
{
    [self startLoginActivityIndicator];
    
    NSDictionary *userCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     emailTextField.text, @"email",
                                     passwordTextField.text, @"password",
                                     nil];
    
    [loginManager generatePostRequestAtRoute:sharedRepository.loginURL withJSONBodyData:userCredentials];
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"LoginService"])
    {
        if(loginManager.responseStatusCode == 200)
        {
            [self persistSessionID:[loginManager getDataFromResponseString] andEmail:emailTextField.text];
        }
        else
        {
            [self indicateLoginAttemptFailure:loginManager.responseString];
        }
        
        [self stopLoginActivityIndicator];
    }
}

- (void)proceedWithLogin
{
//    if([sharedRepository.deviceType isEqualToString:@"iPhone 5"])//@"iPhone Simulator"])
//    {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    UINavigationController *navController = [storyboard  instantiateViewControllerWithIdentifier:@"menuNavigationController"];
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 7)
    {
        [navController.navigationBar setBarTintColor:sharedRepository.greenColor];
        [navController.navigationBar setTranslucent:NO];
        [navController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [navController.navigationBar setTintColor:sharedRepository.greenColor];
    }
    
    [UIApplication sharedApplication].delegate.window.rootViewController = navController;
//    }
//    else // [deviceType isEqualToString:@"iPad Simulator"]
//    {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
//        
//        UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"mainNavController"];
//        
//        [UIApplication sharedApplication].delegate.window.rootViewController = navController;
//    }
}

- (void)indicateLoginAttemptFailure:(NSString *)errorString
{
    NSLog(@"Failure To Log In! >>> %@", errorString);
}

- (void)persistSessionID:(NSString *)sessionID andEmail:(NSString *)userEmail
{
    NSLog(@"sessionId: %@", sessionID);
    NSLog(@"userEmail: %@", userEmail);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sessionID forKey:@"userSessionID"];
    [defaults setObject:userEmail forKey:@"userEmail"];
    [defaults synchronize];
    
    sharedRepository.userEmail = userEmail;
    sharedRepository.sessionID = sessionID;
    
    [self proceedWithLogin];
}

- (void)startLoginActivityIndicator
{
    loginActivityIndicator.hidden = FALSE;
    [loginActivityIndicator startAnimating];
}

- (void)stopLoginActivityIndicator
{
    [loginActivityIndicator stopAnimating];
    loginActivityIndicator.hidden = TRUE;
}

- (IBAction)emailGestureRecognizerTapped:(id)sender
{
    [emailTextField becomeFirstResponder];
}

- (IBAction)passwordGestureRecognizerTapped:(id)sender
{
    [passwordTextField becomeFirstResponder];
}

@end
