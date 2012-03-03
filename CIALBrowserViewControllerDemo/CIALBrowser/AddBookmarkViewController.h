//
//  AddBookmarkViewController.h
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkObject.h"

@interface AddBookmarkViewController : UITableViewController<UITextFieldDelegate, UIActionSheetDelegate> {
    id _delegate;
    NSMutableArray *_bookmarksArray;
    BookmarkObject *_bookmark;
    UITextField *_nameTextField;
}

@property (retain,nonatomic) id delegate;
@property (retain,nonatomic) BookmarkObject *bookmark;

- (void)setBookmark:(NSString *)aName url:(NSURL *)aURL;
@end

@protocol AddBookmarkDelegate <NSObject>
- (void)dismissAddBookmMarkViewController:(AddBookmarkViewController *)viewController;
@end
