//
//  ViewBookmarkViewController.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import "CIALBrowser.h"
#import "ViewBookmarkViewController.h"
#import "EditBookmarkViewController.h"

@implementation ViewBookmarkViewController

@synthesize delegate = _delegate;
@synthesize doneButtonItem = _doneButtonItem;
@synthesize bookmark = _bookmark;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
    {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 400.0);
    }
    
    // Load custom tableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    // Show the navigation controller
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Create "Done" button
    self.navigationItem.title = CIALBrowserLocalizedString(@"Bookmarks",@"");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                         target:self
                                                                                         action:@selector(editButtonAction)] autorelease];
        self.navigationItem.rightBarButtonItem = editButtonItem;
    }
    else
    {
        // Create "Done" button
        self.doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction) ] autorelease];
        self.navigationItem.rightBarButtonItem = _doneButtonItem;
        
        // Create toolbar with edit button
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:9];
        UIBarButtonItem *flexibleSpaceButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                  target:nil
                                                                                                  action:nil] autorelease];
        UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                         target:self
                                                                                         action:@selector(editButtonAction)] autorelease];
        [buttons addObject:editButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        
        [self setToolbarItems:buttons];
        [self.navigationController setToolbarHidden:NO animated:NO];
    }

    // get bookmarks from userDefaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * bookmarks = [defaults objectForKey:@"bookmarks"];
    if (bookmarks) {
        _bookmarksArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:bookmarks]];
    } else {
        _bookmarksArray = [[NSMutableArray alloc] initWithCapacity:1];        
    }    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Buttons methods

- (void)doneButtonAction {
    [self saveBookmarks];
    [_delegate dismissViewBookmMarkViewController:self];
}

- (void)editButtonAction {
    [self.tableView setEditing:YES animated:YES];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // Replace the "Edit" button with a "Done" button
        UIBarButtonItem *doneEditingButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                target:self
                                                                                                action:@selector(doneEditingButtonAction)] autorelease];
        self.navigationItem.rightBarButtonItem = doneEditingButtonItem;
    }
    else
    {
        // Hide Done button in navigation controller
        self.navigationItem.rightBarButtonItem = nil;
        
        // Replace the "Edit" button with a "Done" button
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:9];
        UIBarButtonItem *flexibleSpaceButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                  target:nil
                                                                                                  action:nil] autorelease];
        UIBarButtonItem *doneEditingButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                target:self
                                                                                                action:@selector(doneEditingButtonAction)] autorelease];
        [buttons addObject:doneEditingButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        
        [self setToolbarItems:buttons];
    }
}

- (void)doneEditingButtonAction {
    [self.tableView setEditing:NO animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIBarButtonItem *editButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                         target:self
                                                                                         action:@selector(editButtonAction)] autorelease];
        self.navigationItem.rightBarButtonItem = editButtonItem;
    }
    else
    {
        // Hide Done button in navigation controller
        self.navigationItem.rightBarButtonItem = _doneButtonItem;
        
        // Replace the "Done" button with an "Edit" button
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:9];
        UIBarButtonItem *flexibleSpaceButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                  target:nil
                                                                                                  action:nil] autorelease];
        UIBarButtonItem *doneEditingButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                                target:self
                                                                                                action:@selector(editButtonAction)] autorelease];
        [buttons addObject:doneEditingButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        
        [self setToolbarItems:buttons];
    }
}

#pragma mark -
#pragma mark Table view methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_bookmarksArray count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_bookmarksArray removeObjectAtIndex:indexPath.row];
        [self.tableView    deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }   
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LabelCellIdentifier = @"LabelCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LabelCellIdentifier] autorelease];
    }
    
    // Set up the cell...
    BookmarkObject *bookmark = [_bookmarksArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.textLabel setText:bookmark.name];
    cell.imageView.image = [UIImage imageNamed:@"CIALBrowser.bundle/images/Bookmark.png"];
    cell.imageView.highlightedImage = [UIImage imageNamed:@"CIALBrowser.bundle/images/BookmarkSelected.png"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing)
    {
        // Create view to edit bookmark details
        EditBookmarkViewController *editBookmarkViewController = [[EditBookmarkViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [editBookmarkViewController setBookmark:[_bookmarksArray objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:editBookmarkViewController animated:YES];
        [editBookmarkViewController release];
    }
    else
    {
        // Send url to browser
        BookmarkObject *bookmark = [_bookmarksArray objectAtIndex:indexPath.row];
        [_delegate openThisURL:bookmark.url];
        // save modifications
        [self saveBookmarks];
        
        [_delegate dismissViewBookmMarkViewController:self];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	BookmarkObject *bookmarkToMove = [[_bookmarksArray objectAtIndex:sourceIndexPath.row] retain];
	[_bookmarksArray removeObjectAtIndex:sourceIndexPath.row];
	[_bookmarksArray insertObject:bookmarkToMove atIndex:destinationIndexPath.row];
	[bookmarkToMove release];
    // save modifications
	[self saveBookmarks];
}

- (void)saveBookmarks {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_bookmarksArray] forKey:@"bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBookmark:(NSString *)aName url:(NSURL *)aURL {
    _bookmark = [[BookmarkObject alloc] initWithName:aName andURL:aURL];
}

- (void)dealloc {
    self.delegate = nil;
    self.doneButtonItem = nil;
    self.bookmark = nil;
    [_bookmarksArray release];
    [super dealloc];
}

@end

