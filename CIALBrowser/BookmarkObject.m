//
//  BookmarkObject.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import "BookmarkObject.h"


@implementation BookmarkObject

@synthesize name = _name;
@synthesize url = _url;

- (id) initWithName:(NSString *)aName andURL:(NSURL *)aUrl {
    if (self = [super init]) {
        self.name = aName;
        self.url = aUrl;
    }
    return self;
}

- (id) initWithCoder: (NSCoder *)coder {
      self = [self init];
    if (self != nil)
    {
        self.name = [coder decodeObjectForKey: @"name"];
        self.url = [coder decodeObjectForKey: @"url"];
    }
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_url forKey:@"url"];
}

- (void) dealloc {
    self.name = nil;
    self.url = nil;
    [super dealloc];
}

@end
