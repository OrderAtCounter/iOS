//
//  HistoryViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 11/29/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "HistoryViewController.h"
#import "DataHold.h"
#import "UserOrder.h"
#import "WebServiceManager.h"
#import "CustomDisplayTableViewCell.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController
{
    DataHold *sharedRepository;
    NSMutableArray *displayHistoryArray;
    NSTimer *historyTimer;
    UITapGestureRecognizer *exteriorTap;
    WebServiceManager *updateHistoryManager;
}

@synthesize historyTableView;
@synthesize historySearchBar;

- (void)viewDidLoad
{
    sharedRepository = [[DataHold alloc] init];
    
    displayHistoryArray = [[NSMutableArray alloc] init];
    
    [self resetDisplayHistoryArrayToRetrievedData];
    
    exteriorTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBarKeyboard)];
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 7)
    {
        [historySearchBar setSearchBarStyle:UISearchBarStyleMinimal];
        [historySearchBar setBarTintColor:[UIColor whiteColor]];
    }
    else
    {
        
    }
    
    [historyTableView setAllowsSelection:TRUE];
    
    historyTableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"OrderHistoryService" object:nil];
    
    updateHistoryManager = [[WebServiceManager alloc] init];
    updateHistoryManager.serviceNotificationType = @"OrderHistoryService";
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initializeHistoryUpdateTimer];
    [self updateHistoryTableView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [historyTimer invalidate];
}

- (void)initializeHistoryUpdateTimer
{
    // Start Background Timer to Update Active Orders
    historyTimer = [NSTimer timerWithTimeInterval:8 target:updateHistoryManager selector:@selector(updateOrdersHistory:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:historyTimer forMode:NSRunLoopCommonModes];
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"OrderHistoryService"])
    {
        NSLog(@"NEW ORDER HISTORY LOADED");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           [self parseResponseData];
                           
                           [self resetDisplayHistoryArrayToRetrievedData];
                           
                           if(!historySearchBar.isFirstResponder)
                           {
                               [self performSelectorOnMainThread:@selector(updateHistoryTableView) withObject:nil waitUntilDone:NO];
                           }
                       });
    }
}

- (void)parseResponseData
{
    if(updateHistoryManager.responseStatusCode == 200)
    {
        if(sharedRepository.debugModeActive)
        {
            NSLog(@"History Retrieved! %@", updateHistoryManager.responseString);
        }
        
        [sharedRepository.ordersHistoryArray removeAllObjects];
        
        NSError *error;
        NSArray *jsonHistoryArray = [NSJSONSerialization JSONObjectWithData:updateHistoryManager.responseData options:0 error:&error];
        
        for(NSDictionary *x in jsonHistoryArray)
        {
            UserOrder *fulfilledOrder = [[UserOrder alloc] init];
            
            fulfilledOrder.orderNumber = [[x objectForKey:@"orderNumber"] stringValue];
            fulfilledOrder.orderId = [x objectForKey:@"_id"];
            fulfilledOrder.customerPhoneNumber = [x objectForKey:@"phoneNumber"];
            fulfilledOrder.placementTime = [x objectForKey:@"timestamp"];
            fulfilledOrder.orderFulfilled = FALSE;
            
            [sharedRepository.ordersHistoryArray addObject:fulfilledOrder];
        }
    }
    else
    {
        NSLog(@"FAILED TO RETRIEVE ORDER HISTORY!");// %@", responseData);
    }
}

- (void)resetDisplayHistoryArrayToRetrievedData
{
    [displayHistoryArray removeAllObjects];
    [displayHistoryArray addObjectsFromArray:sharedRepository.ordersHistoryArray];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayHistoryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([sharedRepository.ordersHistoryArray count] == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyOrderHistory"];
        
        return cell;
    }
    else
    {
        UserOrder *order = [displayHistoryArray objectAtIndex:indexPath.row];
        
        CustomDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryExpandedCell"];
        
        if (nil == cell)
        {
            cell = [[CustomDisplayTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HistoryExpandedCell"];
        }
        
        cell.order = order;
        
        cell.orderNumberLabel.text = order.orderNumber;
        cell.phoneNumberLabel.text = [order retrieveFormattedPhoneNumber];
        cell.timePlacementLabel.text = order.placementTime;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int cellHeight = 92;
    
    return cellHeight;
}

- (void)updateHistoryTableView
{
    [displayHistoryArray sortUsingComparator: ^(UserOrder *a, UserOrder *b)
     {
         return [a.placementTime compare:b.placementTime];
     }];
    
    //    NSLog(@"Visible Cells: %@", [activeOrdersTableView visibleCells]);
    //    NSLog(@"Visible Rows: %@", [activeOrdersTableView indexPathsForVisibleRows]);
    //
    //    NSIndexPath *index = [[activeOrdersTableView indexPathsForVisibleRows] objectAtIndex:0];
    //    NSLog(@"Row: %d", index.row);
    
    
    
    [historyTableView reloadData];
    
    
    
    //    [activeOrdersTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [displayHistoryArray removeAllObjects];
    for(UserOrder *x in sharedRepository.ordersHistoryArray)
    {
        BOOL containsOrderNumber = [x.orderNumber rangeOfString:searchText].location != NSNotFound;
        BOOL containsPhoneNumber = [[x.customerPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""] rangeOfString:searchText].location != NSNotFound;
        
        if([searchText isEqualToString:@""] || containsOrderNumber || containsPhoneNumber)
        {
            [displayHistoryArray addObject:x];
        }
    }
    
    [self updateHistoryTableView];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [historyTableView setAllowsSelection:FALSE];
    [self.view addGestureRecognizer:exteriorTap];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self updateHistoryTableView];
    [self dismissSearchBarKeyboard];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)dismissSearchBarKeyboard
{
    [historySearchBar resignFirstResponder];
    [self.view removeGestureRecognizer:exteriorTap];
    [historyTableView setAllowsSelection:TRUE];
}

@end
