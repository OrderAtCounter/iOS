//
//  DefaultTextMessageViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/21/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "DefaultTextMessageViewController.h"

@interface DefaultTextMessageViewController ()

@end

@implementation DefaultTextMessageViewController
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(id)sender
{
    // Update Save Text
    [self.navigationController popViewControllerAnimated:YES];
}
@end
