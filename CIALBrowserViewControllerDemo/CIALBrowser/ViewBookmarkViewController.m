//
//  ViewBookmarkViewController.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import "ViewBookmarkViewController.h"

@implementation ViewBookmarkViewController

@synthesize delegate = _delegate;
@synthesize doneButtonItem = _doneButtonItem;
@synthesize newBookmark = _newBookmark;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load custom tableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Show the navigation controller
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Create "Done" button
    self.navigationItem.title = NSLocalizedString(@"Bookmarks",@"");
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

    // get bookmarks from userDefaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSData * bookmarks = [defaults objectForKey:@"bookmarks"];
    if (bookmarks) {
        _bookmarksArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:bookmarks]];
    } else {
        _bookmarksArray = [[NSMutableArray alloc] initWithCapacity:1];        
    }    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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

- (void)doneEditingButtonAction {
    [self.tableView setEditing:NO animated:YES];
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
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:LabelCellIdentifier] autorelease];
    }
    
    // Set up the cell...
    BookmarkObject *bookmark = [_bookmarksArray objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.textLabel setText:bookmark.name];
    cell.imageView.image = [UIImage imageNamed:@"Bookmark.png"];
    cell.imageView.highlightedImage = [UIImage imageNamed:@"BookmarkSelected.png"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // send url to browser
    BookmarkObject *bookmark = [_bookmarksArray objectAtIndex:indexPath.row];
    [_delegate openThisURL:bookmark.url];
    // save modifications
    [self saveBookmarks];
    
    [_delegate dismissViewBookmMarkViewController:self];
}

- (void)saveBookmarks {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_bookmarksArray] forKey:@"bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBookmark:(NSString *)aName url:(NSURL *)aURL {
    _newBookmark = [[BookmarkObject alloc] initWithName:aName andURL:aURL];
}

- (void)dealloc {
    self.delegate = nil;
    self.doneButtonItem = nil;
    self.newBookmark = nil;
    [_bookmarksArray release];
    [super dealloc];
}

@end

