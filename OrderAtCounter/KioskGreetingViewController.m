//
//  KioskGreetingViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 12/1/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "KioskGreetingViewController.h"
#import "WebServiceManager.h"
#import "DataHold.h"

@interface KioskGreetingViewController ()

@end

@implementation KioskGreetingViewController
{
    DataHold *sharedRepository;
    
    WebServiceManager *logoutManager;
}

@synthesize addNewOrderButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : sharedRepository.redColor};
    
    addNewOrderButton.titleLabel.textColor = sharedRepository.greenColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"KioskLogoutService" object:nil];
    
    logoutManager = [[WebServiceManager alloc] init];
    logoutManager.serviceNotificationType = @"KioskLogoutService";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logoutButtonPressed:(id)sender
{
    [self processUserLogoutAttempt];
}

- (void)processUserLogoutAttempt
{
    NSDictionary *logoutCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       sharedRepository.userEmail, @"email",
                                       sharedRepository.sessionID, @"sessionId",
                                       nil];
    
    [logoutManager generatePostRequestAtRoute:sharedRepository.logoutURL withJSONBodyData:logoutCredentials];
    
    [self performLogoutOperation];
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"KioskLogoutService"])
    {
        if(logoutManager.responseStatusCode == 200)
        {
            if(sharedRepository.debugModeActive)
            {
                NSLog(@"Logout Successful");
            }
        }
        else
        {
            NSLog(@"Failure to Logout! %@", logoutManager.responseString);
        }
    }
}

- (void)performLogoutOperation
{
    [sharedRepository cleanseLocalData];
    
    if([sharedRepository.deviceType isEqualToString:@"iPad Simulator"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"iPadLoginView"];
        [UIApplication sharedApplication].delegate.window.rootViewController = viewController;
    }
}

@end
