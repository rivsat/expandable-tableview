//
//  ExpandableTableViewController.m
//  ExpandableTable
//
//  Created by Tasvir H Rohila on 27/04/15.
//  Copyright (c) 2015 Tasvir H Rohila. All rights reserved.
//


#import "ExpandableTableViewController.h"
#import "ExpandableTableViewCell.h"

@interface ExpandableTableViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end

@implementation ExpandableTableViewController

NSUInteger g_ExpandedCellIndex = 0;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    //SideBar specific initialisation
    [self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    [self setTableView];
    [self setProfileImage];
    //
    //select the data.plist as per the language set for the app
	NSDictionary *dict=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"enData" ofType:@"plist"]];
	self.items=[dict valueForKey:@"Items"];
	self.itemsInTable=[[NSMutableArray alloc] init];
	[self.itemsInTable addObjectsFromArray:self.items];
}

- (void) setTableView {
    //UIColor patternColor =  [UIColor colorWithPatternImage:image]. Then you apply this as the background color of the view. [someView setBackgroundColor:patternColor];
    UIImage *bgImage = [UIImage imageNamed:@"Background"];
    UIColor *patternColor = [UIColor colorWithPatternImage:bgImage];
    self.tableView.backgroundColor = patternColor;
    self.headerView.backgroundColor = patternColor;
    
    self.tableView.separatorColor = [UIColor blackColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}

- (void) setProfileImage {
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemsInTable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *Title= [[self.itemsInTable objectAtIndex:indexPath.row] valueForKey:@"Name"];
    //NSString *CellIdentifier= [[self.itemsInTable objectAtIndex:indexPath.row] valueForKey:@"id"];
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [self createCellWithTitle:Title cellId:CellIdentifier imageName:[[self.itemsInTable objectAtIndex:indexPath.row] valueForKey:@"image"] indexPath:indexPath];
    
    //    ExpandableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // cell.backgroundColor = TOP_HEADER_BG;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check if the row at indexPath is a child of an expanded parent.
    //At a time only one parent would be in expanded state
    NSInteger indexSelected = indexPath.row;
    NSDictionary *dicSelected  =[self.itemsInTable objectAtIndex:indexSelected];
    /**
     Resolved the issue of top line separator dissapearing upon selecting a row (hackishly) by reloading the selected cell
     */
    @try {
        [self.menuTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception) {
    }
    
    [tableView setSectionIndexBackgroundColor:[UIColor blackColor]];
    //
    //Collapse any other expanded cell by iterating through the table cells.
    //Don't collapse if the selected cell is a child of an expanded row.
    NSDictionary *dicCellToCollapse  =[self.itemsInTable objectAtIndex:g_ExpandedCellIndex];
    NSInteger numRowsCollapsed = 0;
    NSInteger level = [[dicSelected valueForKey:@"level"] integerValue];
    if(level==0 && [dicCellToCollapse valueForKey:@"SubItems"] && (g_ExpandedCellIndex != indexPath.row))
    {
        NSArray *arr=[dicCellToCollapse valueForKey:@"SubItems"];
        BOOL isTableExpanded=NO;
        
        for(NSDictionary *subitems in arr )
        {
            NSInteger index=[self.itemsInTable indexOfObjectIdenticalTo:subitems];
            isTableExpanded=(index>0 && index!=NSIntegerMax);
            if(isTableExpanded) break;
        }
        //
        //Collapse the parent cell if its expanded
        if(isTableExpanded)
        {
            [self CollapseRows:arr];
            numRowsCollapsed = [arr count]-1;
        }
    }
    
    //
    //go about the task of expanding the cell if it has subitems
    NSDictionary *dic;
    if (g_ExpandedCellIndex < indexPath.row && numRowsCollapsed)
    {
        dic = [self.itemsInTable objectAtIndex:indexPath.row-numRowsCollapsed-1];
    }
    else
    {
        dic = [self.itemsInTable objectAtIndex:indexPath.row];
    }
    //
    //Check if the selected cell has SubItems i.e its a Parent cell
    if([dic valueForKey:@"SubItems"])
    {
        NSArray *arr=[dic valueForKey:@"SubItems"];
        BOOL isTableExpanded=NO;
        
        for(NSDictionary *subitems in arr )
        {
            NSInteger index=[self.itemsInTable indexOfObjectIdenticalTo:subitems];
            isTableExpanded=(index>0 && index!=NSIntegerMax);
            if(isTableExpanded) break;
        }
        //
        //Collapse the parent cell if its expanded
        if(isTableExpanded)
        {
            [self CollapseRows:arr];
        }
        //
        //Else expand the cell to show SubItems
        else
        {
            //
            //store the location of the cell that is expanded
            NSUInteger rowIndex;
            if (g_ExpandedCellIndex < indexPath.row && numRowsCollapsed)
            {
                rowIndex = indexPath.row-numRowsCollapsed;//zero based index
                g_ExpandedCellIndex = indexPath.row-numRowsCollapsed-1;//zero based index
            }
            else
            {
                rowIndex = indexPath.row+1;
                g_ExpandedCellIndex = indexPath.row;
            }
            //
            //Insert the SubItems
            
            NSMutableArray *arrCells=[NSMutableArray array];
            for(NSDictionary *dInner in arr )
            {
                [arrCells addObject:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
                [self.itemsInTable insertObject:dInner atIndex:rowIndex++];
            }
            [self.menuTableView insertRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    //Else a subItem has been clicked. We need to push the relevant view into segue
    else
    {
        NSString* strId =[dic valueForKey:@"id"];
        //NSString *str = arr[0];
    }
    
}


-(void)CollapseRows:(NSArray*)ar
{
	for(NSDictionary *dInner in ar )
    {
		NSUInteger indexToRemove=[self.itemsInTable indexOfObjectIdenticalTo:dInner];
		NSArray *arInner=[dInner valueForKey:@"SubItems"];
		if(arInner && [arInner count]>0)
        {
			[self CollapseRows:arInner];
		}
		
		if([self.itemsInTable indexOfObjectIdenticalTo:dInner]!=NSNotFound)
        {
            [self.menuTableView beginUpdates];
			[self.itemsInTable removeObjectIdenticalTo:dInner];
			[self.menuTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:
                                                        [NSIndexPath indexPathForRow:indexToRemove inSection:0]
                                                        ]
                                      withRowAnimation:UITableViewRowAnimationLeft];
            [self.menuTableView endUpdates];
        }
	}
}

- (UITableViewCell*)createCellWithTitle:(NSString *)title cellId:(NSString *)cellId imageName:(NSString *)imageName  indexPath:(NSIndexPath*)indexPath
{
    ExpandableTableViewCell *cell = [self.menuTableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[ExpandableTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellId];
    }
    int posX = cell.imgMenuItem.frame.origin.x;
    int posY = cell.imgMenuItem.frame.origin.y;
    //Get Quote item has just the image, there is no title. So resize the imageView as per GetQuote image or regular icon
    if ([title isEqualToString:@"Get Quote"])
    {
        cell.lblTitle.text = @"";
        cell.imgMenuItem.frame = CGRectMake(posX, posY, 100, 20);
    }
    else
    {
        cell.lblTitle.text = title;
        cell.imgMenuItem.frame = CGRectMake(posX, posY, 16, 16);
    }
    
    cell.imgMenuItem.image = [UIImage imageNamed:imageName];
    NSInteger intIndentLevel = [[[self.itemsInTable objectAtIndex:indexPath.row] valueForKey:@"level"] intValue];
    [cell setIndentationLevel:intIndentLevel];
    cell.indentationWidth = 25;
    
    return cell;
}

-(void)showSubItems :(id) sender
{
    UIButton *btn = (UIButton*)sender;
    CGRect buttonFrameInTableView = [btn convertRect:btn.bounds toView:self.menuTableView];
    NSIndexPath *indexPath = [self.menuTableView indexPathForRowAtPoint:buttonFrameInTableView.origin];
    
    if(btn.alpha==1.0)
    {
        if ([[btn imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"down-arrow.png"]])
        {
            [btn setImage:[UIImage imageNamed:@"up-arrow.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn setImage:[UIImage imageNamed:@"down-arrow.png"] forState:UIControlStateNormal];
        }
        
    }
    
    NSDictionary *d=[self.itemsInTable objectAtIndex:indexPath.row] ;
    NSArray *arr=[d valueForKey:@"SubItems"];
    if([d valueForKey:@"SubItems"])
    {
        BOOL isTableExpanded=NO;
        for(NSDictionary *subitems in arr )
        {
            NSInteger index=[self.itemsInTable indexOfObjectIdenticalTo:subitems];
            isTableExpanded=(index>0 && index!=NSIntegerMax);
            if(isTableExpanded) break;
        }
        
        if(isTableExpanded)
        {
            [self CollapseRows:arr];
        }
        else
        {
            NSUInteger count=indexPath.row+1;
            NSMutableArray *arrCells=[NSMutableArray array];
            for(NSDictionary *dInner in arr )
            {
                [arrCells addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                [self.itemsInTable insertObject:dInner atIndex:count++];
            }
            [self.menuTableView insertRowsAtIndexPaths:arrCells withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
    
    
}

@end
