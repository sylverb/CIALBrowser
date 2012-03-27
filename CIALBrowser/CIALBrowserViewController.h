//
//  CIALBrowserViewController.h
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "ViewBookmarkViewController.h"
#import "AddBookmarkViewController.h"

@interface CIALBrowserViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, ViewBookmarkDelegate, AddBookmarkDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate> {
    UIToolbar *toolBar;
    UIBarButtonItem *backButtonItem;
    UIBarButtonItem *forwardButtonItem;
    UIBarButtonItem *actionButtonItem;
    UIButton *stopReloadButton;
    UIButton *bookmarkButton;
    UINavigationItem *navigationItem;
    UIBarButtonItem *closeButtonItem;
    UIBarButtonItem *doneButtonItem;
    UITextField *locationField;
    UIWebView *webView;
    UINavigationBar *navigationBar;
    NSURL *_urlToLoad;
    NSURL *_urlToHandle;
    
    UIPopoverController *_bookmarkPopoverController;
    UIPopoverController *_addBookmarkPopoverController;
    UIActionSheet *_actionActionSheet;
    UIActionSheet *_longPressActionSheet;
    
    // Buttons Indexes for UIActionSheet (long tap)
    NSInteger copyButtonIndex;
    NSInteger openLinkButtonIndex;
    
    // Buttons Indexes for UIActionSheet (action button)
    NSInteger addBookmarkButtonIndex;
    NSInteger sendUrlButtonIndex;
    NSInteger printButtonIndex;
    NSInteger openWithSafariButtonIndex;
    
    UIPrintInteractionController *printInteraction;
    
    NSMutableURLRequest* req;
}

+ (CIALBrowserViewController *)modalBrowserViewControllerWithURL:(NSURL *)url;

@property (nonatomic, retain, setter=loadURL:) NSURL *url;
@property (nonatomic, retain) UIPopoverController *bookmarkPopoverController;
@property (nonatomic, retain) UIPopoverController *addBookmarkPopoverController;
@property (nonatomic, retain) UIActionSheet *actionActionSheet;
@property (getter = isModal) BOOL modal;
@property BOOL enabledSafari;

- (id)initWithURL:(NSURL *)url;

- (void)openThisURL:(NSURL *)url;

- (void)dismissViewBookmMarkViewController:(ViewBookmarkViewController *)viewController;
- (void)dismissAddBookmMarkViewController:(AddBookmarkViewController *)viewController;

@end
