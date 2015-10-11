//
//  ExpandableTableViewCell.m
//  ExpandableTable
//
//  Created by Tasvir H Rohila on 27/04/15.
//  Copyright (c) 2015 Tasvir H Rohila. All rights reserved.
//

#import "ExpandableTableViewCell.h"
#import "ExpandableTableViewController.h"


@implementation ExpandableTableViewCell
@synthesize lblTitle = _lblTitle;
@synthesize imgMenuItem = _imgMenuItem;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(55, 15, 200, 20)];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.textColor = [UIColor grayColor];
        UIFont *myFont = [ UIFont fontWithName: @"Helvetica" size: 12.0 ];
        self.lblTitle.font  = myFont;
        
        UIImage *bgImage = [UIImage imageNamed:@"Background"];
        UIColor *patternColor = [UIColor colorWithPatternImage:bgImage];
        self.backgroundColor = patternColor;
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
        bgView.backgroundColor = [UIColor blackColor];
        self.selectedBackgroundView = bgView;

        self.imgMenuItem = [[UIImageView alloc]initWithFrame:CGRectMake(25, 15, 16, 16)];
        
        [self.contentView addSubview:self.lblTitle];
        [self.contentView addSubview:self.imgMenuItem];
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    
    self.contentView.frame = CGRectMake(
                                        indentPoints,
                                        self.contentView.frame.origin.y,
                                        self.contentView.frame.size.width - indentPoints,
                                        self.contentView.frame.size.height
                                        );
}

@end
