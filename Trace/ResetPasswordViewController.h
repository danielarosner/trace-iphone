//
//  ResetPasswordViewController.h
//  Trace
//
//  Created by Steve Cahill on 2/6/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *mEmailTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@end
