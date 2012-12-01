//
//  CPenaltyCell.m
//  gpen
//
//  Created by Ilya Khokhlov on 01.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyCell.h"

@implementation CPenaltyCell
@synthesize penaltyImage = _penaltyImage;
@synthesize penaltyDate = _penaltyDate;
@synthesize penaltyPrice = _penaltyPrice;

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

- (void) configureCellWithPenalty: (Penalty *) penalty
{
    self.penaltyImage.image = [UIImage imageNamed:[self imageNameForStatus:penalty.status]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yy      hh:mm"];
    self.penaltyDate.text = [dateFormatter stringFromDate:penalty.date];
    
    self.penaltyPrice.text = [self spacedMoneyString:[NSString stringWithFormat:@"%@ р.", penalty.price]];
}

- (NSString *) imageNameForStatus: (NSString *) status
{
    if ([@"3_paid" isEqualToString:status])
    {
        return @"penalty_paid";
    }
    else if ([@"2_not paid" isEqualToString:status])
    {
        return @"penalty_not_paid";
    }
    else if ([@"1_overdue" isEqualToString:status])
    {
        return @"penalty_overdue";
    }
    
    return nil;
}

- (NSString *) spacedMoneyString: (NSString *) moneyString
{
    NSMutableString *temp = [NSMutableString stringWithString:moneyString];
    
    int strLen = [temp length];
    while (strLen >= 4)
    {
        [temp insertString:@" " atIndex:strLen - 3];
        strLen -= 3;
    }
    
    return temp;
}

@end
