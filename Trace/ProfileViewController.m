//
//  ProfileViewController.m
//  Trace
//
//  Created by Steve Cahill on 2/6/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "ProfileViewController.h"
#import "Parse.h"
#import "TermsOfUseViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *infoStr = [NSString stringWithFormat:@"%@ v%@",
                            infoDict[(NSString *)kCFBundleNameKey],
                            infoDict[(NSString*)kCFBundleVersionKey]];
    [self.mVersionLabel setText:infoStr];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    [self.mUsernameLabel setText:currentUser.username];
    if ([currentUser.email length] > 0) {
        [self.mEmailLabel setText:currentUser.email];
    }
    else {
        [self.mEmailLabel setText:@"?"];
    }
    
    // little green check mark for verified email
    if ([[currentUser objectForKey:@"emailVerified"] boolValue])
    {
        [self.mCheckLabel setHidden:NO];
    }
    else
    {
        [self.mCheckLabel setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onLogout:(UIButton *)sender
{
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)onTermsOfUse:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"TermsFromProfile" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TermsFromProfile"])
    {
        TermsOfUseViewController *termsViewController = (TermsOfUseViewController *) segue.destinationViewController;
        termsViewController.agreementRequired = NO;
    }
}

@end
