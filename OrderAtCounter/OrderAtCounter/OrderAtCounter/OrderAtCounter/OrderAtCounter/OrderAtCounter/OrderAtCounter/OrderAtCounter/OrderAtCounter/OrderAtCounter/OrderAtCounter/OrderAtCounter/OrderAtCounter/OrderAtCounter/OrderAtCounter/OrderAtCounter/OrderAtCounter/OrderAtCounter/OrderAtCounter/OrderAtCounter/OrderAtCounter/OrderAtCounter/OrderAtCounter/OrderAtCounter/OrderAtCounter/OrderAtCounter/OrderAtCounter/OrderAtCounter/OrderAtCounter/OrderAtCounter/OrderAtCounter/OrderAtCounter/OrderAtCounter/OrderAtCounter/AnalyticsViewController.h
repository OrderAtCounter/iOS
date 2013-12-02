//
//  AnalyticsViewController.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/29/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnalyticsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property (weak, nonatomic) IBOutlet UINavigationBar *backgroundNavBar;

@property (weak, nonatomic) IBOutlet UILabel *selectedDateRange;

@property (weak, nonatomic) IBOutlet UITableView *analyticsTableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *analyticsSegmentedControl;

@property (strong, nonatomic) IBOutlet UITableViewCell *graphCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *numTextsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *mostActiveCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *averageWaitCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *longestWaitCell;

- (IBAction)segmentedControlHasChanged:(id)sender;

@end
