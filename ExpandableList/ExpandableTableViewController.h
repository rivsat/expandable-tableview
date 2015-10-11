//
//  ExpandableTableViewController.h
//  ExpandableTable
//
//  Created by Tasvir H Rohila on 27/04/15.
//  Copyright (c) 2015 Tasvir H Rohila. All rights reserved.
//


#import <UIKit/UIKit.h>
//#import "MainViewController.h"

@interface ExpandableTableViewController : UITableViewController <UIAlertViewDelegate>

@property(nonatomic,strong) NSArray *items;
@property (nonatomic, retain) NSMutableArray *itemsInTable;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;

//@property (nonatomic, retain) MainViewController *mainViewController;
@end
