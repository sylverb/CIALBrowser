//
//  EditBookmarkViewController.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 03/03/12.
//  Copyright 2012 CodeIsALie. All rights reserved.
//

#import "CIALBrowser.h"
#import "EditBookmarkViewController.h"

@interface EditBookmarkViewController ()
- (void)save;
@end

@implementation EditBookmarkViewController

@synthesize delegate = _delegate;
@synthesize bookmark = _bookmark;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
    {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 400.0);
    }
    
    // Load tableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Show the navigation controller
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Create "Cancel" and "Save" buttons
    self.navigationItem.title = CIALBrowserLocalizedString(@"Edit Bookmark",@"");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
    // When view appears, start with editing the bookmark text
    [_nameTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Force resignFirstResponder for edited textfield
    [self.view endEditing:YES];
    
    [self save];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section)
    {
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *UrlCellIdentifier = @"urlCell";
    static NSString *TextFieldCellIdentifier = @"textFieldCell";
    UITableViewCell *cell = nil;
    
    // Set up the cell...
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier];
                    if (cell == nil)
                    {
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
                        
                        [cell addSubview:_nameTextField];
                        
                        [_nameTextField release];
                    }
                    _nameTextField.text = _bookmark.name;
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:UrlCellIdentifier];
                    if (cell == nil)
                    {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UrlCellIdentifier] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        _urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 280, 30)];
                        _urlTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                        _urlTextField.adjustsFontSizeToFitWidth = YES;
                        _urlTextField.minimumFontSize = 14.0;
                        _urlTextField.font = [UIFont systemFontOfSize:17.0];
                        _urlTextField.textColor = [UIColor colorWithRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1.0];
                        _urlTextField.keyboardType = UIKeyboardTypeURL;
                        _urlTextField.returnKeyType = UIReturnKeyDone;
                        _urlTextField.backgroundColor = [UIColor clearColor];
                        _urlTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
                        _urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
                        _urlTextField.textAlignment = UITextAlignmentLeft;
                        _urlTextField.delegate = self;
                        _urlTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        [_urlTextField setEnabled: YES];
                        
                        [cell addSubview:_urlTextField];
                        
                        [_urlTextField release];
                    }
                    _urlTextField.text = [_bookmark.url absoluteString];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    _bookmark.name = _nameTextField.text;
    _bookmark.url = [NSURL URLWithString:_urlTextField.text];
    
    [self.navigationController popViewControllerAnimated:YES];
    return NO;
}

#pragma mark -
#pragma mark private methods

- (void)save
{
    // Force resignFirstResponder for edited textfield
    [_nameTextField resignFirstResponder];
    
    _bookmark.name = _nameTextField.text;
    _bookmark.url = [NSURL URLWithString:_urlTextField.text];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    self.bookmark = nil;
    [super dealloc];
}

@end
