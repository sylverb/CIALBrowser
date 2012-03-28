//
//  CIALBrowser.m
//  CIALBrowser
//
//  Created by Sylver Bruneau on 28/03/12.
//  Copyright 2012 CodeIsALie. All rights reserved.
//

#import "CIALBrowser.h"

NSString * CIALBrowserLocalizedStringFormat(NSString *key);

// Handle localized strings stored in a bundle

NSString * CIALBrowserLocalizedStringFormat(NSString *key)
{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSBundle *cialBrowserBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CIALBrowser" ofType:@"bundle"]];
        bundle = [NSBundle bundleWithPath:[cialBrowserBundle pathForResource:[[NSLocale preferredLanguages] objectAtIndex:0] ofType:@"lproj"]];
        if (bundle == nil) {
            // If there is no localized strings for default language, select english language
            bundle = [NSBundle bundleWithPath:[cialBrowserBundle pathForResource:@"en" ofType:@"lproj"]];
        }
    }
    return [bundle localizedStringForKey:key value:key table:nil];
}

NSString* CIALBrowserLocalizedString(NSString *key, ...) 
{
	// Localize the format
	NSString *localizedStringFormat = CIALBrowserLocalizedStringFormat(key);
	
	va_list args;
    va_start(args, key);
    NSString *string = [[[NSString alloc] initWithFormat:localizedStringFormat arguments:args] autorelease];
    va_end(args);
	return string;
}
