//
//  ActiveOrdersTableViewController.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/25/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "ActiveOrdersViewController.h"
#import "DataHold.h"
#import "UserOrder.h"
#import "CustomDisplayTableViewCell.h"
#import "ManageOrderViewController.h"
#import "WebServiceManager.h"

@interface ActiveOrdersViewController ()

@end

@implementation ActiveOrdersViewController
{
    DataHold *sharedRepository;
    NSMutableArray *displayOrdersArray;
    NSTimer *updateTimer;
    UITapGestureRecognizer *exteriorTap;
}

@synthesize activeOrdersTableView;
@synthesize activeOrdersSearchBar;

- (void)viewDidLoad
{
    sharedRepository = [[DataHold alloc] init];
    
    displayOrdersArray = [[NSMutableArray alloc] init];
    
    [self resetDisplayOrdersArrayToRetrievedData];
    
    exteriorTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSearchBarKeyboard)];
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 7)
    {
        [activeOrdersSearchBar setSearchBarStyle:UISearchBarStyleMinimal];
        [activeOrdersSearchBar setBarTintColor:[UIColor whiteColor]];
    }
    else
    {
        
    }
    
    if([displayOrdersArray count] == 0)
    {
        [self adjustViewForEmptyTableView];
    }
    else
    {
        [self adjustViewForPopulatedTableView];
    }
    
    [activeOrdersTableView setAllowsSelection:TRUE];
    
    activeOrdersTableView.tableFooterView = [UIView new];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self recolorStatusAndNavigatioNBars];
    [self initializeActiveOrderUpdateTimer];
    [self updateActiveOrdersTableView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [updateTimer invalidate];
}

- (void)recolorStatusAndNavigatioNBars
{
    UIColor *greenColor = sharedRepository.greenColor;
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    NSArray *version = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[version objectAtIndex:0] intValue] >= 7)
    {
        [navigationBar setBarTintColor:greenColor];
        [navigationBar setTranslucent:NO];
        [navigationBar setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [navigationBar setTintColor:greenColor];
    }
    
    navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
}

- (void)initializeActiveOrderUpdateTimer
{
    // Start Background Timer to Update Active Orders
    WebServiceManager *updateActiveOrdersManager = [[WebServiceManager alloc] init];
    updateTimer = [NSTimer timerWithTimeInterval:8 target:updateActiveOrdersManager selector:@selector(updateActiveOrders:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                   ^{
                       while(updateTimer.isValid)
                       {
                           if(updateActiveOrdersManager.dataIsReady)
                           {
                               [self resetDisplayOrdersArrayToRetrievedData];
                               
                               [self performSelectorOnMainThread:@selector(updateActiveOrdersTableView) withObject:nil waitUntilDone:NO];
                           }
                       }
                   });
}

- (void)resetDisplayOrdersArrayToRetrievedData
{
    [displayOrdersArray removeAllObjects];
    [displayOrdersArray addObjectsFromArray:sharedRepository.activeOrdersArray];
}

- (void)adjustViewForEmptyTableView
{
    //Scrolls SearchBar Off-Screen
    
    CGRect newBounds = activeOrdersTableView.bounds;
    newBounds.origin.y = activeOrdersSearchBar.frame.size.height;
    
    activeOrdersTableView.bounds = newBounds;
}

- (void)adjustViewForPopulatedTableView
{
    CGRect newBounds = activeOrdersTableView.bounds;
    newBounds.origin.y = 0;
    activeOrdersTableView.bounds = newBounds;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int numRows = 0;
    if([displayOrdersArray count] > 0)
    {
        numRows = [displayOrdersArray count];
    }
    else if([sharedRepository.activeOrdersArray count] == 0)
    {
        numRows = 1;
    }
    
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([sharedRepository.activeOrdersArray count] == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyActiveOrders"];
        
        return cell;
    }
    else
    {
        UserOrder *order = [displayOrdersArray objectAtIndex:indexPath.row];

        CustomDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderExpandedCell"];

        if (nil == cell)
        {
            cell = [[CustomDisplayTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"OrderExpandedCell"];
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

- (void)updateActiveOrdersTableView
{
    if([displayOrdersArray count] == 0)
    {
        [self adjustViewForEmptyTableView];
    }
    else
    {
        [self adjustViewForPopulatedTableView];
        
        [displayOrdersArray sortUsingComparator: ^(UserOrder *a, UserOrder *b)
        {
            return [a.placementTime compare:b.placementTime];
        }];
    }
    
//    NSLog(@"Visible Cells: %@", [activeOrdersTableView visibleCells]);
//    NSLog(@"Visible Rows: %@", [activeOrdersTableView indexPathsForVisibleRows]);
//    
//    NSIndexPath *index = [[activeOrdersTableView indexPathsForVisibleRows] objectAtIndex:0];
//    NSLog(@"Row: %d", index.row);
//    [activeOrdersTableView reloadData];
//    [activeOrdersTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)fulfillOrderButtonPressed:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:activeOrdersTableView];
    NSIndexPath *indexPath = [activeOrdersTableView indexPathForRowAtPoint:buttonPosition];
    CustomDisplayTableViewCell *cell = ((CustomDisplayTableViewCell *)[activeOrdersTableView cellForRowAtIndexPath:indexPath]);
    
    UserOrder *orderToFulfill = cell.order;
    
    WebServiceManager *fulfillOrderManager = [[WebServiceManager alloc] init];
    
    NSDictionary *fulfillOrderCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        sharedRepository.userEmail, @"email",
                                        sharedRepository.sessionID, @"sessionId",
                                        orderToFulfill.orderId, @"orderId",
                                        nil];
    
    [fulfillOrderManager generatePostRequestAtRoute:sharedRepository.fulfillOrderURL withJSONBodyData:fulfillOrderCredentials];
    
    [sharedRepository.activeOrdersArray removeObject:orderToFulfill];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       // All Code within block is executed asynchronously.
                       
                       while(!fulfillOrderManager.dataFinishedLoading)
                       {
                           
                       }
                       
                       NSString *responseString = fulfillOrderManager.responseString;
                       if(fulfillOrderManager.responseStatusCode == 200)
                       {
                           NSLog(@"Order Fulfilled! %@", responseString);
                       }
                       else
                       {
                           [sharedRepository.activeOrdersArray addObject:orderToFulfill];
                           [self indicateFulfillOrderFailure:responseString];
                       }
                       
                       if(sharedRepository.debugModeActive)
                       {
                           
                       }
                       
                       [self updateActiveOrdersTableView];
                   });
    
    [self updateActiveOrdersTableView];
}

- (void)indicateFulfillOrderFailure:(NSString *)errorString
{
    NSLog(@"Failure To Fulfill Order! %@", errorString);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [displayOrdersArray removeAllObjects];
    for(UserOrder *x in sharedRepository.activeOrdersArray)
    {
        BOOL containsOrderNumber = [x.orderNumber rangeOfString:searchText].location != NSNotFound;
        BOOL containsPhoneNumber = [x.customerPhoneNumber rangeOfString:searchText].location != NSNotFound;
        
        if([searchText isEqualToString:@""] || containsOrderNumber || containsPhoneNumber)
        {
            [displayOrdersArray addObject:x];
        }
    }
    
    [self updateActiveOrdersTableView];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [activeOrdersTableView setAllowsSelection:FALSE];
    [self.view addGestureRecognizer:exteriorTap];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self dismissSearchBarKeyboard];
}

- (void)dismissSearchBarKeyboard
{
    [activeOrdersSearchBar resignFirstResponder];
    [self.view removeGestureRecognizer:exteriorTap];
    [activeOrdersTableView setAllowsSelection:TRUE];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"editOrderSegue"])
    {
        ManageOrderViewController *detailViewController = (ManageOrderViewController *)segue.destinationViewController;
        
        detailViewController.order = ((CustomDisplayTableViewCell *)[activeOrdersTableView cellForRowAtIndexPath:[activeOrdersTableView indexPathForCell:sender]]).order;
    }
}

@end
