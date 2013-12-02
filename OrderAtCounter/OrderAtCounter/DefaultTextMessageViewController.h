//
//  DefaultTextMessageViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/21/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultTextMessageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *customMessageTextView;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end
