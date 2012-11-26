//
//  CTextFieldCell.m
//  gpen
//
//  Created by Ilya Khokhlov on 26.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CTextFieldCell.h"

@implementation CTextFieldCell

@synthesize cellTextField = _cellTextField;

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

    // Configure the view for the selected state
}

@end
