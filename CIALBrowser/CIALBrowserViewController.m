//
//  CIALBrowserViewController.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import "CIALBrowser.h"
#import "CIALBrowserViewController.h"
#import "UIWebViewAdditions.h"
#import "UnpreventableUILongPressGestureRecognizer.h"

@interface CIALBrowserViewController ()
- (void)addBookmark;
- (void)updateLoadingStatus;
- (void)longPressRecognized:(UILongPressGestureRecognizer *)gestureRecognizer;

- (void)goBack:(id)sender;
- (void)goForward:(id)sender;
- (void)reloadOrStop:(id)sender;
- (void)loadURL:(NSURL *)url;

- (void)dismiss:(id)sender;
@end

@implementation CIALBrowserViewController

@synthesize bookmarkPopoverController = _bookmarkPopoverController;
@synthesize addBookmarkPopoverController = _addBookmarkPopoverController;
@synthesize actionActionSheet = _actionActionSheet;
@synthesize modal = _modal;
@synthesize enabledSafari = _enabledSafari;

+ (CIALBrowserViewController *)modalBrowserViewControllerWithURL:(NSURL *)url
{
    CIALBrowserViewController *controller = [[[self alloc] initWithURL:url] autorelease];
    controller.modal = YES;
    return controller;
}

/* DELETEME: default is nil
- (id)init {
    self = [super init];
    if (self) {
        _urlToLoad = nil;
        req = nil;
    }
    return self;
}
*/

- (id)initWithURL:(NSURL *)url  {
    self = [super init];
    if (self) {
        [self setURL:url];
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Toolbar
        toolBar = [[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
        toolBar.barStyle = UIBarStyleDefault;
        [toolBar sizeToFit];
        toolBar.autoresizesSubviews = NO;
        toolBar.frame = CGRectMake(0,
                                   0,
                                   self.view.frame.size.width, 
                                   toolBar.frame.size.height);
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:9];
        UIBarButtonItem *flexibleSpaceButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                  target:nil
                                                                                                  action:nil] autorelease];
        backButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/browserBack.png"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(goBack:)] autorelease];
        forwardButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/browserForward.png"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goForward:)] autorelease];
        UIBarButtonItem *bookmarkButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                             target:self
                                                                                             action:@selector(viewBookmark:)] autorelease];
        actionButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                          target:self
                                                                          action:@selector(actionButton:)] autorelease];
        
        locationField = [[UITextField alloc] initWithFrame:CGRectMake(37,7,246,31)];
        locationField.delegate = self;
        locationField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        locationField.textColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
        locationField.textAlignment = UITextAlignmentLeft;
        locationField.borderStyle = UITextBorderStyleRoundedRect;
        locationField.font = [UIFont fontWithName:@"Helvetica" size:15];
        locationField.autocorrectionType = UITextAutocorrectionTypeNo;
        locationField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        locationField.clearsOnBeginEditing = NO;
        locationField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        locationField.autocorrectionType = UITextAutocorrectionTypeNo;
        locationField.keyboardType = UIKeyboardTypeURL;
        locationField.returnKeyType = UIReturnKeyGo;        
        locationField.clearButtonMode = UITextFieldViewModeWhileEditing;
        // reloadButton
        stopReloadButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        stopReloadButton.bounds = CGRectMake(0, 0, 26, 30);
        [stopReloadButton setImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"] forState:UIControlStateNormal];
        [stopReloadButton setImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"] forState:UIControlStateHighlighted];
        stopReloadButton.showsTouchWhenHighlighted = NO;
        [stopReloadButton addTarget:self action:@selector(reloadOrStop:) forControlEvents:UIControlEventTouchUpInside];
        locationField.rightView = stopReloadButton;
        locationField.rightViewMode = UITextFieldViewModeUnlessEditing;

        UIBarButtonItem *textFieldItem = [[[UIBarButtonItem alloc] initWithCustomView:locationField] autorelease];

        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:backButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:forwardButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:bookmarkButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:actionButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:textFieldItem];

        if (self.isModal) {
            NSString *closeTitle = CIALBrowserLocalizedString(@"Close", nil);
            closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:closeTitle style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss:)];
            navigationItem.rightBarButtonItem = closeButtonItem;
            [buttons addObject:closeButtonItem];
        } else {
            [buttons addObject:flexibleSpaceButtonItem];
        }
        
        [toolBar setItems:buttons];
        [self.view addSubview:toolBar];
        
        // webView
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, toolBar.frame.size.height , self.view.frame.size.width, self.view.frame.size.height - toolBar.frame.size.height)];
        webView.scalesPageToFit = YES;
        webView.contentMode = UIViewContentModeScaleToFill;
        webView.multipleTouchEnabled = YES;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:webView];
        [webView release];
    } else {
        navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
        // titleView
        locationField = [[UITextField alloc] initWithFrame:CGRectMake(37,7,246,31)];
        locationField.delegate = self;
        locationField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        locationField.textColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
        locationField.textAlignment = UITextAlignmentLeft;
        locationField.borderStyle = UITextBorderStyleRoundedRect;
        locationField.font = [UIFont fontWithName:@"Helvetica" size:15];
        locationField.autocorrectionType = UITextAutocorrectionTypeNo;
        locationField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        locationField.clearsOnBeginEditing = NO;
        
        locationField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        locationField.autocorrectionType = UITextAutocorrectionTypeNo;
        locationField.keyboardType = UIKeyboardTypeURL;
        locationField.returnKeyType = UIReturnKeyGo;
        
        locationField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        // reloadButton
        stopReloadButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        stopReloadButton.bounds = CGRectMake(0, 0, 26, 30);
        [stopReloadButton setImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"] forState:UIControlStateNormal];
        [stopReloadButton setImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"] forState:UIControlStateHighlighted];
        stopReloadButton.showsTouchWhenHighlighted = NO;
        [stopReloadButton addTarget:self action:@selector(reloadOrStop:) forControlEvents:UIControlEventTouchUpInside];
        locationField.rightView = stopReloadButton;
        locationField.rightViewMode = UITextFieldViewModeUnlessEditing;
        
        navigationItem.titleView = locationField;
        
        if (self.isModal) {
            NSString *closeTitle = CIALBrowserLocalizedString(@"Close", nil);
            closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:closeTitle style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss:)];
            navigationItem.rightBarButtonItem = closeButtonItem;
        }
        
        navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [navigationBar setItems:[NSArray arrayWithObject:navigationItem]];
        [self.view addSubview:navigationBar];
        [navigationBar release];
        
        // Toolbar
        toolBar = [[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
        toolBar.barStyle = UIBarStyleDefault;
        [toolBar sizeToFit];
        toolBar.autoresizesSubviews = NO;
        toolBar.frame = CGRectMake(0,
                                   self.view.frame.size.height-toolBar.frame.size.height,
                                   self.view.frame.size.width, 
                                   toolBar.frame.size.height);
        toolBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:9];
        UIBarButtonItem *flexibleSpaceButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                  target:nil
                                                                                                  action:nil] autorelease];
        backButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/browserBack.png"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(goBack:)] autorelease];
        forwardButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CIALBrowser.bundle/images/browserForward.png"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(goForward:)] autorelease];
        actionButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                          target:self
                                                                          action:@selector(actionButton:)] autorelease];
        UIBarButtonItem *bookmarkButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                             target:self
                                                                                             action:@selector(viewBookmark:)] autorelease];
        
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:backButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:forwardButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:actionButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        [buttons addObject:bookmarkButtonItem];
        [buttons addObject:flexibleSpaceButtonItem];
        
        [toolBar setItems:buttons];
        [self.view addSubview:toolBar];
        
        // webView
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.size.height , self.view.frame.size.width, self.view.frame.size.height - navigationBar.frame.size.height - toolBar.frame.size.height)];
        webView.scalesPageToFit = YES;
        webView.contentMode = UIViewContentModeScaleToFill;
        webView.multipleTouchEnabled = YES;
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:webView];
        [webView release];
    }

    // Create a long press recognizer for handling links long press
    UnpreventableUILongPressGestureRecognizer *longPressRecognizer = [[UnpreventableUILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    longPressRecognizer.allowableMovement = 20;
    longPressRecognizer.minimumPressDuration = 1.0f;
    [webView addGestureRecognizer:longPressRecognizer];
    [longPressRecognizer release]; 
}

- (void)dealloc {
    // Stop the spinner
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    webView.delegate = nil;
    [webView release],webView = nil;
    [backButtonItem release],backButtonItem = nil;
    [forwardButtonItem release],forwardButtonItem = nil;
    [bookmarkButton release],bookmarkButton = nil;
    [stopReloadButton release],stopReloadButton = nil;
    [locationField release],locationField = nil;
    [closeButtonItem release], closeButtonItem = nil;
    [navigationBar release],navigationBar = nil;
    [_urlToLoad release],_urlToLoad = nil;
    [_urlToHandle release],_urlToHandle = nil;
    
    self.actionActionSheet = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // On iPad, allow any orientation
    // On iPhone/iPod Touch, allow any orientation but upside down portrait
    BOOL allowRotate = YES;
    if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) && (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))  {
        allowRotate = NO;
    }
    if ([_longPressActionSheet isVisible]) {
        allowRotate = NO;
    }
    return allowRotate;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // The height of the toolbar is changing according to orientation, resize the webview occording to this
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            webView.frame = CGRectMake(0, navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - navigationBar.frame.size.height - toolBar.frame.size.height);
        } else {
            webView.frame = CGRectMake(0, navigationBar.frame.size.height, self.view.frame.size.height, self.view.frame.size.width - navigationBar.frame.size.height - toolBar.frame.size.height);
        }
    }
}

#pragma mark -

- (void) viewDidLoad {
    [super viewDidLoad];
    
    webView.delegate = self;
    
    [self updateLoadingStatus];
    
    if (_urlToLoad) {
        [self loadURL:_urlToLoad];
    } else {
        [locationField becomeFirstResponder];
    }
}

#pragma mark -

- (void)loadURL:(NSURL *)url {
    if (!webView) {
        [self setURL:url];
        return;
    }
    
    if (!url) return;
    
    locationField.text = url.absoluteString;
    
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)goBack:(id) sender {
    [webView goBack];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
}

- (void)goForward:(id) sender {
    [webView goForward];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
}

- (void)reloadOrStop:(id) sender {
    if (webView.loading)
        [webView stopLoading];
    else [webView reload];
}

- (NSURL *)url {
    NSURL *url = [NSURL URLWithString:locationField.text];
    if (!url.scheme.length && locationField.text.length) url = [NSURL URLWithString:[@"http://" stringByAppendingString:locationField.text]];
    return url;
}

#pragma mark -
#pragma mark UITextField delegate

- (void)setURL:(NSURL *)url
{
    NSString *urlString = url.absoluteString;
    if ([urlString length]) {
        if (!url.scheme.length) {
            url = [NSURL URLWithString:[@"http://" stringByAppendingString:urlString]];
        }
        [_urlToLoad release];
        _urlToLoad = [url copy];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
    NSURL *url = [NSURL URLWithString:locationField.text];
    
    // if user didn't enter "http", add it the the url
    if (!url.scheme.length) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:locationField.text]];
    }
    
    [self loadURL:url];
    
    [locationField resignFirstResponder];
    
    return YES;
}

#pragma mark -

- (void) updateLocationField {
    NSString *location = webView.request.URL.absoluteString;
    if (location.length)
        locationField.text = webView.request.URL.absoluteString;
}

- (void) updateLoadingStatus {
    UIImage *image = nil;
    if (webView.loading) {
        image = [UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewStop.png"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        image = [UIImage imageNamed:@"CIALBrowser.bundle/images/AddressViewReload.png"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    [stopReloadButton setImage:image forState:UIControlStateNormal];
    
    // update status of back/forward buttons
    backButtonItem.enabled = [webView canGoBack];
    forwardButtonItem.enabled = [webView canGoForward];
}

#pragma mark -
#pragma mark UIWebView delegate

- (BOOL)webView:(UIWebView *) sender shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
    if ([request.URL.absoluteString isEqual:@"about:blank"])
        return NO;
    [req release];
    req = (NSMutableURLRequest *)[request retain];
    
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *) sender {
    [self updateLoadingStatus];
}

- (void) webViewDidFinishLoad:(UIWebView *) sender {
    // Disable the defaut actionSheet when doing a long press
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingStatus) object:nil];
    [self performSelector:@selector(updateLoadingStatus) withObject:nil afterDelay:1.];
}

- (void) webView:(UIWebView *)sender didFailLoadWithError:(NSError *) error {
    switch ([error code]) {
        case kCFURLErrorCancelled :
        {
            // Do nothing in this case
            break;
        }
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CIALBrowserLocalizedString(@"Error",@"") 
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:CIALBrowserLocalizedString(@"OK",@"")
                                                  otherButtonTitles:nil];
            [alert show];    
            [alert release];
            break;
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLocationField) object:nil];
    [self performSelector:@selector(updateLocationField) withObject:nil afterDelay:1.];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateLoadingStatus) object:nil];
    [self performSelector:@selector(updateLoadingStatus) withObject:nil afterDelay:1.];
}

#pragma mark actions -

- (void)dismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIBarButtonItem functions

- (void)viewBookmark:(UIBarButtonItem *)button {
    // Make other popover disappear
    if ([self.actionActionSheet isVisible]) {
        [self.actionActionSheet dismissWithClickedButtonIndex:self.actionActionSheet.cancelButtonIndex
                                                     animated:YES];
    }
    
    if ([self.addBookmarkPopoverController isPopoverVisible]) {
        [self.addBookmarkPopoverController dismissPopoverAnimated:YES];
    }

    if (printInteraction != nil) {
        [printInteraction dismissAnimated:YES];
        printInteraction = nil;
    }

    // Create the popover or make it disappear if needed
    if (self.bookmarkPopoverController.popoverVisible) {
        [self.bookmarkPopoverController dismissPopoverAnimated:YES];
        self.bookmarkPopoverController = nil;
    } else {
        ViewBookmarkViewController * viewBookmarkViewController = [[[ViewBookmarkViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        viewBookmarkViewController.delegate = self;
        [viewBookmarkViewController setBookmark:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]
                                        url:self.url];
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:viewBookmarkViewController] autorelease];
        
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.bookmarkPopoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
            [self.bookmarkPopoverController presentPopoverFromBarButtonItem:button
                                                   permittedArrowDirections:UIPopoverArrowDirectionDown|UIPopoverArrowDirectionUp
                                                                   animated:YES];
        } else {
            [self presentModalViewController:navController animated:YES];
        }
    }

}

- (void)addBookmark {
    AddBookmarkViewController * addBookmarkViewController = [[[AddBookmarkViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    [addBookmarkViewController setBookmark:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]
                                       url:self.url];
    addBookmarkViewController.delegate = self;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:addBookmarkViewController] autorelease];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.addBookmarkPopoverController = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        self.addBookmarkPopoverController.popoverContentSize = CGSizeMake(320.0, 150.0);
        [self.addBookmarkPopoverController presentPopoverFromBarButtonItem:actionButtonItem
                                               permittedArrowDirections:UIPopoverArrowDirectionDown|UIPopoverArrowDirectionUp
                                                               animated:YES];
    } else {
        [self presentModalViewController:navController animated:YES];
    }
}

- (void)actionButton:(UIBarButtonItem *)button {
    if ([self.bookmarkPopoverController isPopoverVisible]) {
        [self.bookmarkPopoverController dismissPopoverAnimated:YES];
    }
    if ([self.addBookmarkPopoverController isPopoverVisible]) {
        [self.addBookmarkPopoverController dismissPopoverAnimated:YES];
        // addBookmarkPopoverController is created by this actionSheet
        // if this button is tapped, make the popover disappear and don't create the actionSheet
        return;
    }
    
    if (printInteraction != nil) {
        [printInteraction dismissAnimated:YES];
        printInteraction = nil;
        // printInteraction is created by this actionSheet
        // if this button is tapped, make it disappear and don't create the actionSheet
        return;
    }
    
    // Create the actionSheet or make it disappear if needed
    if (!self.actionActionSheet) {
        self.actionActionSheet = [[UIActionSheet alloc] initWithTitle:[_urlToHandle.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil];
        self.actionActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        
        copyButtonIndex = -1;
        openLinkButtonIndex = -1;
        addBookmarkButtonIndex = [self.actionActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Add bookmark",nil)];
        
        if (self.enabledSafari) {
            openWithSafariButtonIndex = [self.actionActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Open with Safari",@"")];
        } else {
            openWithSafariButtonIndex = -1;
        }
        
        if ([MFMailComposeViewController canSendMail]) {
            sendUrlButtonIndex = [self.actionActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Mail Link to this Page",@"")];
        }
        
        Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
        if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable]) {
            printButtonIndex = [self.actionActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Print",@"")];
        } else {
            printButtonIndex = -1;
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.actionActionSheet.cancelButtonIndex = -1;
        } else {
            self.actionActionSheet.cancelButtonIndex = [_actionActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Cancel",@"")];
        }
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (_actionActionSheet.visible) {
            [_actionActionSheet dismissWithClickedButtonIndex:_actionActionSheet.cancelButtonIndex
                                                     animated:YES];
        } else {
            [_actionActionSheet showFromBarButtonItem:button animated:YES];
        }
    } else {
        [_actionActionSheet showInView:self.view];
    }
}

#pragma mark -
#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (copyButtonIndex == buttonIndex) {
        NSLog(@"url : %@",_urlToHandle);
        NSString *urlString;
        if (req != nil) {
            urlString = [req.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            urlString = [_urlToHandle.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        
        [pasteBoard setValue:urlString forPasteboardType:@"public.utf8-plain-text"];
    } else if (openLinkButtonIndex == buttonIndex) {
        NSLog(@"url : %@",_urlToHandle);
        [self loadURL:_urlToHandle];
        _urlToHandle = nil;
    } else if (addBookmarkButtonIndex == buttonIndex) {
        [self addBookmark];
    } else if (openWithSafariButtonIndex == buttonIndex) {
        [[UIApplication sharedApplication] openURL:self.url];
    } else if (sendUrlButtonIndex == buttonIndex) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setSubject:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
        [mailViewController setMessageBody:[self.url absoluteString]
                                    isHTML:NO];
        
        mailViewController.mailComposeDelegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        }
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
    } else if (printButtonIndex == buttonIndex) {
        Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
        
        if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
        {
            printInteraction = [printInteractionController sharedPrintController];
            printInteraction.delegate = self;
            
            UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];
            
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            
            printInteraction.printInfo = printInfo;
            printInteraction.showsPageRange = YES;
            
            UIViewPrintFormatter *formatter = [webView viewPrintFormatter];
            printInteraction.printFormatter = formatter;
            
            [printInteraction presentFromBarButtonItem:actionButtonItem
                                              animated:YES
                                     completionHandler:
             ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
             }
             ];
        }
    }
    
    if (req != nil) {
        [req release];
        req = nil;
    }    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _longPressActionSheet)
    {
        _longPressActionSheet = nil;
    }
}

#pragma mark -
#pragma mark MFMailComposeViewController delegates

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
    
    NSString *mailError = nil;
    
    switch (result) {
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            mailError = CIALBrowserLocalizedString(@"Failed sending email, please try again...",@"");
            break;
        default:
            break;
    }
    
    if (mailError != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:mailError
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark -
#pragma mark UIPrintInteractionControllerDelegate
- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    NSLog(@"printInteractionControllerDidDismissPrinterOptions");
    printInteraction = nil;
}

#pragma mark -
#pragma mark UILongPressGestureRecognizer handling

- (void)longPressRecognized:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:webView];
        
        // convert point from view to HTML coordinate system
        CGSize viewSize = [webView frame].size;
        CGSize windowSize = [webView windowSize];
        
        CGFloat f = windowSize.width / viewSize.width;
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.) {
            point.x = point.x * f;
            point.y = point.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [webView scrollOffset];
            point.x = point.x * f + offset.x;
            point.y = point.y * f + offset.y;
        }
                
        // Load the JavaScript code from the Resources and inject it into the web page
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CIALBrowser" ofType:@"bundle"]];

        NSString *path = [bundle pathForResource:@"JSTools" ofType:@"js"];
        NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [webView stringByEvaluatingJavaScriptFromString: jsCode];
        
        // get the Tags at the touch location
        NSString *tags = [webView stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        
        NSString *tagsHREF = [webView stringByEvaluatingJavaScriptFromString:
                              [NSString stringWithFormat:@"MyAppGetLinkHREFAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        
        NSString *tagsSRC = [webView stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@"MyAppGetLinkSRCAtPoint(%i,%i);",(NSInteger)point.x,(NSInteger)point.y]];
        NSLog(@"tags : %@",tags);
        NSLog(@"href : %@",tagsHREF);
        NSLog(@"src : %@",tagsSRC);
        
        NSString *url = nil;
        if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
            url = tagsSRC;
        }
        if ([tags rangeOfString:@",A,"].location != NSNotFound) {
            url = tagsHREF;
        }
        NSLog(@"url : %@",url);
        
        NSArray *urlArray = [[url lowercaseString] componentsSeparatedByString:@"/"];
        NSString *urlBase = nil;
        if ([urlArray count] > 2) {
            urlBase = [urlArray objectAtIndex:2];
        }
        
        if ((url != nil) &&
            ([url length] != 0)) {
            // Release any previous request
            [req release], req = nil;
            // Save URL for the request
            _urlToHandle = [[NSURL alloc] initWithString:url];
            
            // ask user what to do
            _longPressActionSheet = [[UIActionSheet alloc] initWithTitle:[_urlToHandle.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:nil];
            _longPressActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            
            openLinkButtonIndex = [_longPressActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Open",@"")];
            copyButtonIndex = [_longPressActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Copy",@"")];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                CGPoint touchPosition = [gestureRecognizer locationInView:webView];
                [_longPressActionSheet showFromRect:CGRectMake(touchPosition.x, touchPosition.y, 1, 1)
                                             inView:webView
                                           animated:YES];
            } else {
                _longPressActionSheet.cancelButtonIndex = [_longPressActionSheet addButtonWithTitle:CIALBrowserLocalizedString(@"Cancel",@"")];
                [_longPressActionSheet showInView:self.view];
            }
            [_longPressActionSheet release];
        }        
    }
}

#pragma mark -
#pragma mark Bookmark delegates

- (void)openThisURL:(NSURL *)url {
    [self loadURL:url];
}

- (void)dismissViewBookmMarkViewController:(ViewBookmarkViewController *)viewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.bookmarkPopoverController dismissPopoverAnimated:YES];
    } else {
        [viewController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark addBookmark delegates

- (void)dismissAddBookmMarkViewController:(AddBookmarkViewController *)viewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.addBookmarkPopoverController dismissPopoverAnimated:YES];
    } else {
        [viewController dismissModalViewControllerAnimated:YES];
    }
}

@end
