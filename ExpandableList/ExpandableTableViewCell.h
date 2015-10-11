//
//  ExpandableTableViewCell.h
//  ExpandableTable
//
//  Created by Tasvir H Rohila on 27/04/15.
//  Copyright (c) 2015 Tasvir H Rohila. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ExpandableTableViewController;
@interface ExpandableTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnExpand;
@property (nonatomic, retain) IBOutlet UIImageView *imgMenuItem;

@end
