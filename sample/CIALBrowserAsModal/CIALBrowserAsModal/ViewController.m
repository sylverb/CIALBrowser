//
//  ViewController.m
//  CIALBrowserAsModal
//
//  Created by Ito Katsuyoshi on 12/03/19.
//  Copyright (c) 2012年 ITO SOFT DESIGN Inc. All rights reserved.
//

#import "ViewController.h"
#import "CIALBrowserViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize urlTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setUrlTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)open:(id)sender
{
    NSURL *url = [NSURL URLWithString:self.urlTextField.text];
    CIALBrowserViewController *controller = [CIALBrowserViewController modalBrowserViewControllerWithURL:url];
    [self presentModalViewController:controller animated:YES];
}

- (void)dealloc {
    [urlTextField release];
    [super dealloc];
}
@end
