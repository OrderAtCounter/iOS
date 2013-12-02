//
//  ActiveOrdersTableViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/25/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveOrdersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *activeOrdersTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *activeOrdersSearchBar;

- (IBAction)fulfillOrderButtonPressed:(id)sender;

@end
