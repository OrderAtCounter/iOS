//
//  OrderDetailCell.m
//  OrderAtCounter
//
//  Created by Kevin Lacey on 12/1/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import "OrderDetailCell.h"

@implementation OrderDetailCell
{
    
}

@synthesize isEditMode;
@synthesize editValueTextField, valueLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(isEditMode)
    {
        editValueTextField.hidden = FALSE;
        valueLabel.hidden = TRUE;
    }
    else
    {
        valueLabel.hidden = FALSE;
        editValueTextField.hidden = TRUE;
    }
}

@end
