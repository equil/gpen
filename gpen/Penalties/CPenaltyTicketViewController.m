//
//  CPenaltyTicketViewController.m
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyTicketViewController.h"
#import "Penalty.h"
#import "Recipient.h"
#import "CPenaltyDetailCell.h"

@interface CPenaltyTicketViewController ()
{
    NSArray *m_dataSource;
}
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation CPenaltyTicketViewController

@synthesize penalty = _penalty;
//доставай данные по квитанции через свойство _penalty.recipient

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [NSArray arrayWithObjects:
                       [NSArray arrayWithObjects:@"Протокол:", [NSString stringWithFormat:@"№ %@", [self spacedProtocolString: self.penalty.reportId]], nil],
                       [NSArray arrayWithObjects:@"Код администратора:", [self spacedMoneyString:self.penalty.recipient.administratorCode], nil],
                       [NSArray arrayWithObjects:@"Сумма платежа:", [NSString stringWithFormat:@"%@ рублей", [self spacedMoneyString: [NSString stringWithFormat:@"%@", self.penalty.price]]], nil],
                       [NSArray arrayWithObjects:@"Получатель:", [self noneNilString:self.penalty.recipient.name], nil],
                       [NSArray arrayWithObjects:@"Счет:", [self spacedCheckString: self.penalty.recipient.account], nil],
                       [NSArray arrayWithObjects:@"Инн:", [self spacedCheckString: self.penalty.recipient.inn], nil],
                       [NSArray arrayWithObjects:@"КПП:", [self spacedCheckString: self.penalty.recipient.kpp], nil],
                       [NSArray arrayWithObjects:@"ОКАТО:", [self spacedCheckString: self.penalty.recipient.okato], nil],
                       [NSArray arrayWithObjects:@"КБК:", [self spacedCheckString: self.penalty.recipient.kbk], nil],
                       [NSArray arrayWithObjects:@"Банк:", [self noneNilString:self.penalty.recipient.bank], nil],
                       [NSArray arrayWithObjects:@"Наименование платежа:", [self noneNilString:self.penalty.recipient.billTitle], nil],
                       nil];

    [self.tableView reloadData];
}

- (NSString *) spacedProtocolString: (NSString *) protocolString
{
    if (!protocolString) {
        return @"";
    }
    NSMutableString *temp = [NSMutableString stringWithString:protocolString];
    
    [temp insertString:@" " atIndex:7];
    [temp insertString:@" " atIndex:4];
    [temp insertString:@" " atIndex:2];
    
    return temp;
}

- (NSString *) spacedMoneyString: (NSString *) moneyString
{
    if (!moneyString) {
        return @"";
    }
    NSMutableString *temp = [NSMutableString stringWithString:moneyString];
    
    int strLen = [temp length];
    while (strLen >= 4)
    {
        [temp insertString:@" " atIndex:strLen - 3];
        strLen -= 3;
    }
    
    return temp;
}

- (NSString *) spacedCheckString: (NSString *) moneyString
{
    if (!moneyString) {
        return @"";
    }
    NSMutableString *temp = [NSMutableString stringWithString:moneyString];
    
    int strLen = [temp length];
    while (strLen >= 5)
    {
        [temp insertString:@" " atIndex:strLen - 4];
        strLen -= 4;
    }
    
    return temp;
}

- (NSString *) noneNilString: (NSString *) aString
{
    return (aString ? aString : @"");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.dataSource ? [self.dataSource count] : 0);
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat result = [self heightForVerticalText:[[self.dataSource objectAtIndex:indexPath.row] objectAtIndex:1] title:[[self.dataSource objectAtIndex:indexPath.row] objectAtIndex:0]];
    
    return (result < 44.0) ? 44.0 : result;
}

- (CGFloat) heightForVerticalText: (NSString *) aText title: (NSString *) aTitle
{
    CGFloat textHeight = [self heightForVerticalText:aText];
    CGFloat titleHeight = [self heightForVerticalText:aTitle];
    CGFloat height = textHeight + titleHeight + 11.0 * 2 + 8.0;
    return height;
}

- (CGFloat) heightForVerticalText: (NSString *) aText
{
    CGFloat outerWidth = 276.0;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        outerWidth = 436.0;
    }
    // use large value to avoid scrolling
    CGFloat maxHeight = 50000.0f;
    CGSize constraint = CGSizeMake(outerWidth, maxHeight);
    CGSize size = [aText
                   sizeWithFont:[UIFont fontWithName:@"PTSans-Regular" size:16.0]
                   constrainedToSize:constraint
                   lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *penaltyVerticalCellId = @"penaltyDetailVertical";
    
    CPenaltyDetailCell *cell = (CPenaltyDetailCell *)[tableView dequeueReusableCellWithIdentifier:penaltyVerticalCellId];
    [cell.labelTitle setText:[[self.dataSource objectAtIndex:indexPath.row] objectAtIndex:0]];
    [cell.labelSubtitle setText:[[self.dataSource objectAtIndex:indexPath.row] objectAtIndex:1]];
    
    cell.labelTitle.frame = CGRectMake(cell.labelTitle.frame.origin.x, cell.labelTitle.frame.origin.y, cell.labelTitle.frame.size.width, [self heightForVerticalText:cell.labelTitle.text]);
    cell.labelSubtitle.frame = CGRectMake(cell.labelSubtitle.frame.origin.x, cell.labelTitle.frame.origin.y + cell.labelTitle.frame.size.height + 8.0, cell.labelSubtitle.frame.size.width, [self heightForVerticalText:cell.labelSubtitle.text]);
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = [[UIView alloc] init];
    result.backgroundColor = [UIColor clearColor];
    return result;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

@end
