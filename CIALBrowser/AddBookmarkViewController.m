//
//  AddBookmarkViewController.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import "CIALBrowser.h"
#import "AddBookmarkViewController.h"

@interface AddBookmarkViewController ()
- (void)saveAction;
- (void)cancelAction;
- (void)saveBookmarks;
@end

@implementation AddBookmarkViewController

@synthesize delegate = _delegate;
@synthesize bookmark = _bookmark;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load tableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Show the navigation controller
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Create "Cancel" and "Save" buttons
    self.navigationItem.title = CIALBrowserLocalizedString(@"Add Bookmark",@"");
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction) ] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction) ] autorelease];
    
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
    
    // When view appears, start with editing the bookmark text
    [_nameTextField becomeFirstResponder];
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

#pragma mark -
#pragma mark Buttons methods

- (void)saveAction {
    // Force resignFirstResponder for edited textfield
    [_nameTextField resignFirstResponder];
    
    BOOL saveURL = YES;
    // Check that the URL is not already in the bookmark list
    for (BookmarkObject * bookmark in _bookmarksArray) {
        if ([bookmark.url.absoluteString isEqual:_bookmark.url.absoluteString]) {
            saveURL = NO;
            break;
        }
    }
    
    // Add the new URL in the list
    if (saveURL) {
        _bookmark.name = _nameTextField.text;
        [_bookmarksArray addObject:_bookmark];
        [self.tableView reloadData];
    }
    
    [self saveBookmarks];

    [_delegate dismissAddBookmMarkViewController:self];
}

- (void)cancelAction {
    [_delegate dismissAddBookmMarkViewController:self];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case 0:
        {
            rows = 2;
            break;
        }   
        default:
        { 
            break;
        }
    }
    return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UrlCellIdentifier = @"urlCell";
    static NSString *TextFieldCellIdentifier = @"textFieldCell";
    UITableViewCell *cell = nil;

    // Set up the cell...
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextFieldCellIdentifier] autorelease];

                        cell.selectionStyle = UITableViewCellSelectionStyleNone;

                        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 280, 30)];
                        _nameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                        _nameTextField.adjustsFontSizeToFitWidth = YES;
                        _nameTextField.textColor = [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1.0];
                        _nameTextField.keyboardType = UIKeyboardTypeDefault;
                        _nameTextField.returnKeyType = UIReturnKeyDone;
                        _nameTextField.backgroundColor = [UIColor clearColor];
                        _nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
                        _nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
                        _nameTextField.textAlignment = UITextAlignmentLeft;
                        _nameTextField.delegate = self;
                        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        [_nameTextField setEnabled: YES];
                        _nameTextField.text = _bookmark.name;
                        
                        [cell addSubview:_nameTextField];
                        
                        [_nameTextField release];
                    }
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:UrlCellIdentifier];
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UrlCellIdentifier] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.textLabel.adjustsFontSizeToFitWidth = YES;
                    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
                    cell.textLabel.minimumFontSize = 14.0;
                    cell.textLabel.textColor = [UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:1.0];
                    cell.textLabel.text = [_bookmark.url absoluteString];
                    break;
                }
                default:
                {
                    break;
                }
            }
            break;
        }   
        default:
        {
            break;
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark -
#pragma mark TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self saveAction];
}

#pragma mark -

- (void)saveBookmarks {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_bookmarksArray] forKey:@"bookmarks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBookmark:(NSString *)aName url:(NSURL *)aURL {
    _bookmark = [[BookmarkObject alloc] initWithName:aName andURL:aURL];
}

- (void)dealloc {
    self.bookmark = nil;
    [_bookmarksArray release];
    [super dealloc];
}

@end

