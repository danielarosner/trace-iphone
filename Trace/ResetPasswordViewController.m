//
//  ResetPasswordViewController.m
//  Trace
//
//  Created by Steve Cahill on 2/6/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "Parse.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onResetPassword:(UIButton *)sender
{
    NSString *errMsg = nil;
    
    [self.mEmailTextField resignFirstResponder];
    
    if ([self.mEmailTextField.text length] <= 0)
    {
        errMsg = NSLocalizedString(@"SignUp_EmailEmpty", nil);
        [self.mEmailTextField becomeFirstResponder];
    }
    
    if (errMsg == nil)
    {
        if ([self.mActivityIndicator isAnimating]) {
            // do nothing, already trying to log in
        }
        else
        {
            [self.mActivityIndicator startAnimating];
            
            [self.mActivityIndicator startAnimating];
            
            // Login
            __weak ResetPasswordViewController *weakSelf = self;
            
            [PFUser requestPasswordResetForEmailInBackground:self.mEmailTextField.text
                                                       block:^(BOOL succeeded, NSError *error) {
                                                           if (succeeded)
                                                           {
                                                               // Do stuff after successful login.
                                                               [weakSelf.mActivityIndicator stopAnimating];
                                                               
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                                                               });
                                                           }
                                                           else
                                                           {
                                                               // The login failed. Check error to see why.
                                                               [weakSelf.mActivityIndicator stopAnimating];
                                                               
                                                               [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ResetPassword_Failed", nil)
                                                                                           message:[error.userInfo objectForKey:@"error"]
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:nil
                                                                                 otherButtonTitles:@"OK", nil] show];
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

@end
