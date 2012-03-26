//
//  ViewController.h
//  CIALBrowserAsModal
//
//  Created by Ito Katsuyoshi on 12/03/19.
//  Copyright (c) 2012年 ITO SOFT DESIGN Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *urlTextField;
@property (retain, nonatomic) IBOutlet UISwitch *enabeldSafariSwitch;

- (IBAction)open:(id)sender;

@end
