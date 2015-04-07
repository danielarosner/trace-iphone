//
//  LogInViewController.m
//  Trace
//
//  Created by Steve Cahill on 2/5/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "LogInViewController.h"
#import "Parse.h"
#import "TermsOfUseViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)onLogin:(UIButton *)sender
{
    NSString *errMsg = nil;
    
    [self resignAllResponders];
    
    if ([self.mUsenameTextField.text length] <= 0) {
        errMsg = NSLocalizedString(@"Login_UsernameEmpty", nil);
        [self.mUsenameTextField becomeFirstResponder];
    }
    else if ([self.mPasswordTextField.text length] <= 0) {
        errMsg = NSLocalizedString(@"Login_PasswordEmpty", nil);
        [self.mPasswordTextField becomeFirstResponder];
    }
    
    if (errMsg == nil)
    {
        if ([self.mActivityIndicator isAnimating]) {
            // do nothing, already trying to log in
        }
        else
        {
            [self.mActivityIndicator startAnimating];
            
            // Login
            __weak LogInViewController *weakSelf = self;
            
            [PFUser logInWithUsernameInBackground:self.mUsenameTextField.text
                                         password:self.mPasswordTextField.text
                                            block:^(PFUser *user, NSError *error) {
                                                if (user)
                                                {
                                                    // Do stuff after successful login.
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf.mActivityIndicator stopAnimating];
                                                        [weakSelf.navigationController popViewControllerAnimated:YES];
                                                        // [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                    });
                                                }
                                                else
                                                {
                                                    // The login failed. Check error to see why.
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf.mActivityIndicator stopAnimating];
                                                        
                                                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login_Failed", nil)
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

- (IBAction)onNewUser:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"ConsentForNewUser" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ConsentForNewUser"])
    {
        TermsOfUseViewController *termsViewController = (TermsOfUseViewController *) [segue destinationViewController];
        termsViewController.agreementRequired = YES;
    }
}

-(void) resignAllResponders
{
    UIResponder *checkField;
    
    checkField = [self.view viewWithTag:kUserTag];
    if ([checkField isFirstResponder]) {
        [checkField resignFirstResponder];
    }

    checkField = [self.view viewWithTag:kPasswordTag];
    if ([checkField isFirstResponder]) {
        [checkField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

//  The tags are set sequencial numbers in the storyboard TextFields
//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger curFieldTag = [textField tag];
    UIResponder *nextField = [textField.superview viewWithTag:(curFieldTag + 1)];
    if (nextField) {
        [nextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return(NO);
}

@end
