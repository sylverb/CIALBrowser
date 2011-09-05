//
//  BookmarkObject.h
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BookmarkObject : NSObject <NSCoding> {
    NSString *_name;
    NSURL *_url;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSURL *url;

- (id) initWithName:(NSString *)name andURL:(NSURL *)url;

@end
