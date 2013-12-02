//
//  LoginViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/19/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "LoginViewController.h"
#import "MenuTableViewController.h"
#import "WebServiceManager.h"
#import "DataHold.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
{
    DataHold *sharedRepository;
}

@synthesize customerLogoImageView, emailTextField, passwordTextField, loginActivityIndicator, loginButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    UITapGestureRecognizer *exteriorTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:exteriorTap];
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0f green:247.0/255.0f blue:245.0/255.0f alpha:1.0f];
    
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
    
    WebServiceManager *loginManager = [[WebServiceManager alloc] init];
    
    NSDictionary *userCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     emailTextField.text, @"email",
                                     passwordTextField.text, @"password",
                                     nil];
    
    [loginManager generatePostRequestAtRoute:sharedRepository.loginURL withJSONBodyData:userCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!loginManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       NSString *responseString = loginManager.responseString;
                       if(loginManager.responseStatusCode == 200)
                       {
                           [self persistSessionID:[loginManager getDataFromResponseString] andEmail:emailTextField.text];
                           
                           [self proceedWithLogin];
                       }
                       else
                       {
                           [self indicateLoginAttemptFailure:responseString];
                       }
                       
                       [self stopLoginActivityIndicator];
                       
                       if(sharedRepository.debugModeActive)
                       {
                           
                       }
                   });
}

- (void)proceedWithLogin
{
    if([sharedRepository.deviceType isEqualToString:@"iPhone Simulator"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        
        UINavigationController *navController = [storyboard  instantiateViewControllerWithIdentifier:@"menuNavigationController"];
        
        UIColor *greenColor = sharedRepository.greenColor;
        
        NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if ([[version objectAtIndex:0] intValue] >= 7)
        {
            [navController.navigationBar setBarTintColor:greenColor];
            [navController.navigationBar setTranslucent:NO];
            [navController.navigationBar setTintColor:[UIColor whiteColor]];
        }
        else
        {
            [navController.navigationBar setTintColor:greenColor];
        }
        
        [UIApplication sharedApplication].delegate.window.rootViewController = navController;
    }
    else // [deviceType isEqualToString:@"iPad Simulator"]
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        
        UISplitViewController *splitViewController = [storyboard instantiateViewControllerWithIdentifier:@"menuTabBarController"];
        [UIApplication sharedApplication].delegate.window.rootViewController = splitViewController;
    }
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
