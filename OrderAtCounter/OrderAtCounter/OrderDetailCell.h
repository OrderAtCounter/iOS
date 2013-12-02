//
//  OrderDetailCell.h
//  OrderAtCounter
//
//  Created by Kevin Lacey on 12/1/13.
//  Copyright (c) 2013 KRL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailCell : UITableViewCell <UITextFieldDelegate>
{
    BOOL isEditMode;
}

@property BOOL isEditMode;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UITextField *editValueTextField;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;

@end
