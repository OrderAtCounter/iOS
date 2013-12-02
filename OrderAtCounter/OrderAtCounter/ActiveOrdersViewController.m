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
    WebServiceManager *updateActiveOrdersManager;
    WebServiceManager *fulfillOrderManager;
}

@synthesize activeOrdersTableView;
@synthesize activeOrdersSearchBar;

- (void)viewDidLoad
{
    sharedRepository = [[DataHold alloc] init];
    
    displayOrdersArray = [[NSMutableArray alloc] init];
    
    [self recolorStatusAndNavigatioNBars];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"ActiveOrderService" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDataLoadedNotificationReceived:) name:@"FulfillOrderService" object:nil];
    
    updateActiveOrdersManager = [[WebServiceManager alloc] init];
    updateActiveOrdersManager.serviceNotificationType = @"ActiveOrderService";
    
    fulfillOrderManager = [[WebServiceManager alloc] init];
    fulfillOrderManager.serviceNotificationType = @"FulfillOrderService";
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initializeActiveOrderUpdateTimer];
    [self resetDisplayOrdersArrayToRetrievedData];
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
    updateTimer = [NSTimer timerWithTimeInterval:8 target:updateActiveOrdersManager selector:@selector(updateActiveOrders:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
}

- (void)newDataLoadedNotificationReceived:(NSNotification *)notification
{
    if([[notification name] isEqualToString:@"ActiveOrderService"])
    {
        NSLog(@"NEW ACTIVE ORDERS LOADED");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                       ^{
                           [self parseResponseData];
                           
                           [self resetDisplayOrdersArrayToRetrievedData];
                           
                           if(!activeOrdersSearchBar.isFirstResponder)
                           {
                               [self performSelectorOnMainThread:@selector(updateActiveOrdersTableView) withObject:nil waitUntilDone:NO];
                           }
                       });
    }
    else if([[notification name] isEqualToString:@"FulfillOrderService"])
    {
        if(fulfillOrderManager.responseStatusCode == 200)
        {
            NSLog(@"Order Fulfilled! %@", fulfillOrderManager.responseString);
        }
        else
        {
            NSLog(@"Failed To Fulfill Order! %@", fulfillOrderManager.responseString);
        }
        
        [self updateActiveOrdersTableView];
    }
}

- (void)parseResponseData
{
    if(updateActiveOrdersManager.responseStatusCode == 200)
    {
        if(sharedRepository.debugModeActive)
        {
            NSLog(@"Active Orders Retrieved! %@", updateActiveOrdersManager.responseString);
        }
        
        [sharedRepository.activeOrdersArray removeAllObjects];
        
        NSError *error;
        NSArray *jsonOrdersArray = [NSJSONSerialization JSONObjectWithData:updateActiveOrdersManager.responseData options:0 error:&error];
        
        for(NSDictionary *x in jsonOrdersArray)
        {
            UserOrder *activeOrder = [[UserOrder alloc] init];
            
            activeOrder.orderNumber = [[x objectForKey:@"orderNumber"] stringValue];
            activeOrder.orderId = [x objectForKey:@"_id"];
            activeOrder.customerPhoneNumber = [x objectForKey:@"phoneNumber"];
            activeOrder.placementTime = [x objectForKey:@"timestamp"];
            activeOrder.orderFulfilled = FALSE;
            
            [sharedRepository.activeOrdersArray addObject:activeOrder];
        }
    }
    else
    {
        NSLog(@"FAILED TO RETRIEVE ACTIVE ORDERS!");// %@", responseData);
    }
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
        
        cell.sendTextButton.enabled = TRUE;
        if(order.orderId == nil)
        {
            cell.sendTextButton.enabled = FALSE;
        }
        
        if(order.orderFulfilled)
        {
            cell.orderNumberLabel.textColor = sharedRepository.greenColor;
        }
        else
        {
            cell.orderNumberLabel.textColor = [UIColor blackColor];
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
    if([sharedRepository.activeOrdersArray count] == 0)
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
    
    [activeOrdersTableView reloadData];
    
//    [activeOrdersTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)fulfillOrderButtonPressed:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:activeOrdersTableView];
    NSIndexPath *indexPath = [activeOrdersTableView indexPathForRowAtPoint:buttonPosition];
    CustomDisplayTableViewCell *cell = ((CustomDisplayTableViewCell *)[activeOrdersTableView cellForRowAtIndexPath:indexPath]);
    
    UserOrder *orderToFulfill = cell.order;
    orderToFulfill.orderFulfilled = TRUE;
    
    NSDictionary *fulfillOrderCredentials = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        sharedRepository.userEmail, @"email",
                                        sharedRepository.sessionID, @"sessionId",
                                        orderToFulfill.orderId, @"orderId",
                                        nil];
    
    [fulfillOrderManager generatePostRequestAtRoute:sharedRepository.fulfillOrderURL withJSONBodyData:fulfillOrderCredentials];
    
    [sharedRepository.activeOrdersArray removeObject:orderToFulfill];
    
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
        BOOL containsPhoneNumber = [[x.customerPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""] rangeOfString:searchText].location != NSNotFound;
        
        NSLog(@"%@", x.customerPhoneNumber);
        
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
    [self updateActiveOrdersTableView];
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
