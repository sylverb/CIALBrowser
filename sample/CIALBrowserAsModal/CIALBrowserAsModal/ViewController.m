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
@synthesize enabeldSafariSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setUrlTextField:nil];
    [self setEnabeldSafariSwitch:nil];
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
    controller.enabledSafari = self.enabeldSafariSwitch.on;
    [self presentModalViewController:controller animated:YES];
}

- (void)dealloc {
    [urlTextField release];
    [enabeldSafariSwitch release];
    [super dealloc];
}
@end
