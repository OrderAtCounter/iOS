//
//  ActiveOrderExpandedCell.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 9/25/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "CustomDisplayTableViewCell.h"

@implementation CustomDisplayTableViewCell

@synthesize order;
@synthesize sendTextButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [sendTextButton setImage:[UIImage imageNamed:@"big-message-red.png"] forState:UIControlStateHighlighted];

    // Configure the view for the selected state
}

@end
