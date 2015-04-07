//
//  TermsOfUseViewController.m
//  Trace Map
//
//  Created by Steve Cahill on 2/24/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "TermsOfUseViewController.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"

@interface TermsOfUseViewController ()

@end

@implementation TermsOfUseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.showLogout)
    {
        self.logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(onLogout:)];
        
        // [self.navigationController.navigationItem setLeftBarButtonItem:self.logoutButton];
        [self.navigationItem setLeftBarButtonItem:self.logoutButton];
    }
    
    if (! self.agreementRequired)
    {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    NSError *error;
    NSString *consentHtmlFilepath = [[NSBundle mainBundle] pathForResource:@"consent" ofType:@"html"];
    NSMutableString *consentHtml = [NSMutableString stringWithContentsOfFile:consentHtmlFilepath encoding:NSUTF8StringEncoding error:&error];
    if (self.agreementRequired)
    {
        // Add agreement checkboxes if first time
        //
        NSString *questionsHtmlFilepath = [[NSBundle mainBundle] pathForResource:@"consent_questions" ofType:@"html"];
        NSString *questionsHtml = [NSString stringWithContentsOfFile:questionsHtmlFilepath encoding:NSUTF8StringEncoding error:&error];
        [consentHtml appendString:questionsHtml];
    }
    [self.termsWebView loadHTMLString:consentHtml baseURL:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onLogout:(UIBarButtonItem *)sender
{
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onDone:(UIBarButtonItem *)sender
{
    self.newUserConsented = NO;
    self.newUserAllowsNameUse = NO;
    
    if (self.agreementRequired)
    {
        // Grab the HTML check box states from the web view
        //
        NSString *agreeCheckboxStr = [self.termsWebView stringByEvaluatingJavaScriptFromString:
                                      @"document.getElementById('consented').checked"];
        
        NSString *associate_nameCheckboxStr = [self.termsWebView stringByEvaluatingJavaScriptFromString:
                                      @"document.getElementById('associate_name').checked"];
        
        Boolean userConsented = [agreeCheckboxStr isEqualToString:@"true"];
        Boolean userAllowedNameUse = [associate_nameCheckboxStr isEqualToString:@"true"];
        
        if (userConsented)
        {
            PFUser *curUser = [PFUser currentUser];
            
            if (curUser)
            {
                // updating an existing User
                NSDate *nowDate = [NSDate date];
                
                curUser[@"consentDate"] = nowDate;
                
                if (userAllowedNameUse)
                {
                    curUser[@"associateNameDate"] = nowDate;
                }
                
                [curUser saveInBackground];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                // in the process of creating a new User
                self.newUserConsented = userConsented;
                self.newUserAllowsNameUse = userAllowedNameUse;
                [self performSegueWithIdentifier:@"SignUpFromConsent" sender:nil];
            }
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:NSLocalizedString(@"ConsentNotCheckedMsg", nil)
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
    }
    else
    {
        // just viewing from Profile
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SignUpFromConsent"])
    {
        SignUpViewController *signUp = (SignUpViewController *) [segue destinationViewController];
        
        signUp.newUserConsented = self.newUserConsented;
        signUp.newUserAllowsNameUse = self.newUserAllowsNameUse;
    }
}


@end
