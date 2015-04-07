//
//  SignUpViewController.m
//  Trace
//
//  Created by Steve Cahill on 2/5/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "SignUpViewController.h"
#import "Parse.h"
#import "TracesMgr.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // to adjust for Tranparent Nav bar
    // http://stackoverflow.com/questions/18967859/ios7-uiscrollview-offset-in-uinavigationcontroller
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onLogin:(UIButton *)sender
{
    NSString *errMsg = nil;
    
    if ([self.mUsenameTextField.text length] <= 0) {
        errMsg = NSLocalizedString(@"Login_UsernameEmpty", nil);
        [self.mUsenameTextField becomeFirstResponder];
    }
    else if ([self.mPasswordTextField.text length] <= 0) {
        errMsg = NSLocalizedString(@"Login_PasswordEmpty", nil);
        [self.mPasswordTextField becomeFirstResponder];
    }
    else if ([self.mPasswordAgainTextField.text length] <= 0) {
        errMsg = NSLocalizedString(@"SignUp_Password2Empty", nil);
        [self.mPasswordAgainTextField becomeFirstResponder];
    }
    else if ([self.mPasswordTextField.text compare:self.mPasswordAgainTextField.text] != NSOrderedSame) {
        errMsg = NSLocalizedString(@"SignUp_PasswordsNotSame", nil);
        [self.mPasswordTextField becomeFirstResponder];
    }
    else if ([self.mEmailTextField.text length] <= 0) {
        errMsg = NSLocalizedString(@"SignUp_EmailEmpty", nil);
        [self.mEmailTextField becomeFirstResponder];
    }
    
    if (errMsg == nil) {
        if ([self.mActivityIndicator isAnimating]) {
            // do nothing, already trying to log in
        }
        else
        {
            [self.mActivityIndicator startAnimating];
            
            PFUser *newUser = [PFUser user];
            newUser.username = self.mUsenameTextField.text;
            newUser.password = self.mPasswordTextField.text;
            // force all emails to lowercase so can match up new users to drawing by email
            newUser.email = [self.mEmailTextField.text lowercaseString];
            
            NSDate *nowDate = [NSDate date];
            if (self.newUserConsented)
            {
                newUser[@"consentDate"] = nowDate;
            }
            if (self.newUserAllowsNameUse)
            {
                newUser[@"associateNameDate"] = nowDate;
            }
            
            // Login
            __weak SignUpViewController *weakSelf = self;
            
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (! error) {
                    // successful login with New user
                    //
                    // Walk the UnknownEmail table to check this new
                    // User and link up any Drawings.
                    [TracesMgr linkNewUsersEmailToAwaitingDrawings:newUser
                                                         withBlock:^(BOOL succeeded, NSError *error)
                     {
                         if (succeeded)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf.mActivityIndicator stopAnimating];
                                 [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                             });
                         }
                         else {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                             message:[error.userInfo objectForKey:@"error"]
                                                            delegate:nil
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"OK", nil] show];
                             });
                         }
     
                     }];
                } else {
                    // The login failed. Check error to see why.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.mActivityIndicator stopAnimating];
                    
                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SignUp_Failed", nil)
                                                    message:[error.userInfo objectForKey:@"error"]
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil] show];
                    });
                }
            }];
        }
    }
    else {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:errMsg
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Keyboard resizing

- (void) keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.view convertRect:kbRect fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.mScrollView.contentInset = contentInsets;
    self.mScrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
    if (!CGRectContainsPoint(aRect, self.mActiveField.frame.origin) ) {
        [self.mScrollView scrollRectToVisible:self.mActiveField.frame animated:YES];
    }
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.mScrollView.contentInset = contentInsets;
    self.mScrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.mActiveField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.mActiveField = nil;
}

//  The tags are set sequencial numbers in the storyboard TextFields
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger curFieldTag = [textField tag];
    
    /*
     if (curFieldTag == kNewEmailTag) {
        [textField resignFirstResponder];
        
        [self onLogin:nil];
    }
    else
    */
    {
        UIResponder *nextField = [textField.superview viewWithTag:(curFieldTag + 1)];
        if (nextField) {
            [nextField becomeFirstResponder];
        }
        else {
            [textField resignFirstResponder];
        }
    }
    
    return(NO);
}

@end
