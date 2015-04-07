//
//  SignUpViewController.h
//  Trace
//
//  Created by Steve Cahill on 2/5/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#define kNewUserTag        200
#define kNewEmailTag       203

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

@property (assign) Boolean newUserConsented;
@property (assign) Boolean newUserAllowsNameUse;

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UITextField *mUsenameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordAgainTextField;
@property (weak, nonatomic) IBOutlet UITextField *mEmailTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@property (weak, nonatomic) UITextField *mActiveField;

@end
