//
//  UnpreventableUILongPressGestureRecognizer.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 01/09/10.
//  Copyright 2011 CodeIsALie. All rights reserved.
//

#import "UnpreventableUILongPressGestureRecognizer.h"

@implementation UnpreventableUILongPressGestureRecognizer

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return NO;
}

@end
