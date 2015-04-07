//
//  LogInViewController.h
//  Trace
//
//  Created by Steve Cahill on 2/5/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#define kUserTag        100
#define kPasswordTag    101

@interface LogInViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mUsenameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *mLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *mNewUserButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@end
