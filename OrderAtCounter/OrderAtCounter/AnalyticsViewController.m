//
//  AnalyticsViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/29/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()

@end

@implementation AnalyticsViewController
{
    NSDateFormatter *todaysDateFormatter;
    NSDateFormatter *rangeDateFormatter;
}

@synthesize backgroundNavBar;
@synthesize analyticsSegmentedControl;
@synthesize selectedDateRange;
@synthesize analyticsTableView;
@synthesize graphCell, numTextsCell, mostActiveCell, averageWaitCell, longestWaitCell;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 7)
    {
        backgroundNavBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        backgroundNavBar.tintColor = [UIColor whiteColor];
    }
    else
    {
        
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0f green:247.0/255.0f blue:245.0/255.0f alpha:1.0f];
    
    todaysDateFormatter = [[NSDateFormatter alloc] init];
    [todaysDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [todaysDateFormatter setDateFormat:@"MMMM d, yyyy"];
    
    rangeDateFormatter = [[NSDateFormatter alloc] init];
    [rangeDateFormatter setDateFormat:@"MMMM d"];
    
    selectedDateRange.text = [todaysDateFormatter stringFromDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    switch(indexPath.row)
    {
        case 0: cell = graphCell; break;
        case 1: cell = numTextsCell; break;
        case 2: cell = mostActiveCell; break;
        case 3: cell = averageWaitCell; break;
        case 4: cell = longestWaitCell; break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 0;
    switch(indexPath.row)
    {
        case 0: height = 155; break;
        case 1: height = 65; break;
        case 2: height = 65; break;
        case 3: height = 65; break;
        case 4: height = 65; break;
    }
    
    return height;
}

- (IBAction)segmentedControlHasChanged:(id)sender
{
    [self refreshDateRangeLabel];
    [self updateRowData];
}

- (void)refreshDateRangeLabel
{
    int index = analyticsSegmentedControl.selectedSegmentIndex;
    if(index == 0)
    {
        selectedDateRange.text = [todaysDateFormatter stringFromDate:[NSDate date]];
    }
    else if(index == 1)
    {
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        
        [componentsToSubtract setDay: -([weekdayComponents weekday] - [gregorian firstWeekday])];
        
        NSString *firstDayOfWeek = [rangeDateFormatter stringFromDate:[gregorian dateByAddingComponents:componentsToSubtract toDate:[NSDate date] options:0]];
        NSString *currentDay = [rangeDateFormatter stringFromDate:[NSDate date]];
        
        selectedDateRange.text = [NSString stringWithFormat:@"%@ - %@", firstDayOfWeek, currentDay];
    }
    else if(index == 2)
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                       fromDate:[NSDate date]];
        components.day = 1;
        NSString *firstDayOfMonth = [rangeDateFormatter stringFromDate:[[NSCalendar currentCalendar] dateFromComponents: components]];
        NSString *currentDay = [rangeDateFormatter stringFromDate:[NSDate date]];
        
        selectedDateRange.text = [NSString stringWithFormat:@"%@ - %@", firstDayOfMonth, currentDay];
    }
}

- (void)updateRowData
{
    if(analyticsSegmentedControl.selectedSegmentIndex == 0)
    {
        numTextsCell.detailTextLabel.text = @"21 texts";
        mostActiveCell.detailTextLabel.text = @"11AM - 12PM";
        averageWaitCell.detailTextLabel.text = @"8 minutes";
        longestWaitCell.detailTextLabel.text=  @"28 minutes";
    }
    else if(analyticsSegmentedControl.selectedSegmentIndex == 1)
    {
        numTextsCell.detailTextLabel.text = @"32 texts";
        mostActiveCell.detailTextLabel.text = @"11AM - 12PM";
        averageWaitCell.detailTextLabel.text = @"7 minutes";
        longestWaitCell.detailTextLabel.text=  @"28 minutes";
    }
    else if(analyticsSegmentedControl.selectedSegmentIndex == 2)
    {
        numTextsCell.detailTextLabel.text = @"32 texts";
        mostActiveCell.detailTextLabel.text = @"11AM - 12PM";
        averageWaitCell.detailTextLabel.text = @"7 minutes";
        longestWaitCell.detailTextLabel.text=  @"28 minutes";
    }
}

@end
