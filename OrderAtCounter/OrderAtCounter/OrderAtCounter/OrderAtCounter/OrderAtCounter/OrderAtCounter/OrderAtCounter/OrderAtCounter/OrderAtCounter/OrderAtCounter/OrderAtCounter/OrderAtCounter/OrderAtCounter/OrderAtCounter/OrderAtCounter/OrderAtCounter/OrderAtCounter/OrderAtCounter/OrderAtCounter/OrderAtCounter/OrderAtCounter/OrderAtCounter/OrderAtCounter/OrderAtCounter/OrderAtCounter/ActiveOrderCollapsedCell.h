//
//  ActiveOrderCollapsedCell.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/25/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserOrder.h"

@interface ActiveOrderCollapsedCell : UITableViewCell
{
    UserOrder *order;
}

@property UserOrder *order;

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;

- (IBAction)fulfillOrderButtonPressed:(id)sender;

@end
