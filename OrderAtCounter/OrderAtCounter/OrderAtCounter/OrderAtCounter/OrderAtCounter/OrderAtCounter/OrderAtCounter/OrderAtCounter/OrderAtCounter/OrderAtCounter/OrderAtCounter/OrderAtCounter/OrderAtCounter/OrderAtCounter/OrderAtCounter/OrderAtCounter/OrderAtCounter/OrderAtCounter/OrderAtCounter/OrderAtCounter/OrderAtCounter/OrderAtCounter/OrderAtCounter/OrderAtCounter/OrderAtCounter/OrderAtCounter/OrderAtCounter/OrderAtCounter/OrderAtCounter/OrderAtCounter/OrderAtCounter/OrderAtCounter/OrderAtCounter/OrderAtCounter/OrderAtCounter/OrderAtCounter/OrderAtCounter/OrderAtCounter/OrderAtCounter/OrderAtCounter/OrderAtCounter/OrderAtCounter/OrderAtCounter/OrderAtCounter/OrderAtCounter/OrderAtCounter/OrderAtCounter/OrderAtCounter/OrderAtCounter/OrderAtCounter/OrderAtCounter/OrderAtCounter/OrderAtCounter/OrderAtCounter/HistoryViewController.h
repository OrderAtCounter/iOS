//
//  HistoryViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/29/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *historySearchBar;

@end
