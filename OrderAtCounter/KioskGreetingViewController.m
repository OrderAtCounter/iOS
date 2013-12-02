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
}

@synthesize addNewOrderButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedRepository = [[DataHold alloc] init];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : sharedRepository.redColor};
    
    addNewOrderButton.titleLabel.textColor = sharedRepository.greenColor;
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
    WebServiceManager *logoutManager = [[WebServiceManager alloc] init];
    
    NSDictionary *logoutCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       sharedRepository.userEmail, @"email",
                                       sharedRepository.sessionID, @"sessionId",
                                       nil];
    
    [logoutManager generatePostRequestAtRoute:sharedRepository.logoutURL withJSONBodyData:logoutCredentials];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!logoutManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       NSString *responseString = logoutManager.responseString;
                       if(logoutManager.responseStatusCode == 200)
                       {
                           if(sharedRepository.debugModeActive)
                           {
                               NSLog(@"Logout Successful");
                           }
                       }
                       else
                       {
                           [self indicateLogoutAttemptFailure:responseString];
                       }
                       
                       
                   });
    
    [self performLogoutOperation];
}

- (void)indicateLogoutAttemptFailure:(NSString *)errorString
{
    NSLog(@"Failure To Logout! >>> %@", errorString);
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
