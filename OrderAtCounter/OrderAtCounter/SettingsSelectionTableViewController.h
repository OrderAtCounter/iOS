//
//  SettingsSelectionTableViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/21/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsSelectionTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *settingsTableView;

@property (weak, nonatomic) IBOutlet UILabel *defaultTextMessageLabel;

@end
