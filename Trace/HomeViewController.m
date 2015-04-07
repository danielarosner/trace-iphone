//
//  HomeViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/24.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "LogInViewController.h"
#import "TracePickerViewController.h"
#import "TermsOfUseViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tracesMgr = [[TracesMgr alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // User login - STC 2/5/15
    //
    static Boolean sAllowLogInAsOriginalTatUser = NO;
    
    PFUser *currentUser = [PFUser currentUser];
    Boolean needToLogin;
    if (currentUser) {
       
        // do stuff with the user
        if ([currentUser.username isEqualToString:@"tat"]) {
            needToLogin = NO;
            if (! sAllowLogInAsOriginalTatUser) {
                // this was the original User that was ALWAYS used
                needToLogin = YES;
                [PFUser logOut];
            }
            else {
                needToLogin = NO;
            }
        }
        else {
            // valid User that is not 'tat'
            needToLogin = NO;
        }
    } else {
        // show the signup or login screen
        needToLogin = YES;
    }
    
    if (needToLogin)
    {
        sAllowLogInAsOriginalTatUser = YES;     // so can use old data for now
        
        // NSLog(@"Login");
        
        // displatched because still loading Home view
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"Login" sender:self];
        });
    }
    else
    {
        // if the User has not agreed to the current Terms of Use
        NSDate *consentDate = currentUser[@"consentDate"];
        if (! consentDate)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"TermsFromHome" sender:self];
            });
        }
    }

    
    // Old all Users used...
    //    [PFUser logInWithUsernameInBackground:@"tat" password:@"tatat"
    //
    // NSLog(@"Your Current UUID is: %@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
    // NSLog(@"%@", [PFUser currentUser]);
}

#pragma mark - Navigation

- (IBAction)onSmallDrawButtonDown:(UIButton *)sender
{
    [self.bigDrawButton setSelected:YES];
}

- (IBAction)onSmallDrawButton:(UIButton *)sender
{
    [self.bigDrawButton setSelected:NO];
    
    // Because buttons not square, this fudges a better click area for Draw
    // Note that the main button connects directly to the segue.
    [self performSegueWithIdentifier:@"Drawing" sender:nil];
}

- (IBAction)onSmallWalkButtonDown:(UIButton *)sender
{
    [self.bigWalkButton setSelected:YES];
}

- (IBAction)onSmallWalkButton:(id)sender
{
    [self.bigWalkButton setSelected:NO];
    
    // Because buttons not square, this fudges a better click area for Walk
    // Note that the main button connects directly to the segue.
    [self performSegueWithIdentifier:@"PickTrace" sender:nil];
}


 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     
     if ([segue.identifier isEqualToString:@"Drawing"]) {
         // the Drawing area has a different Navigation Bar color
         [self.navigationController.navigationBar setBarTintColor:kRedDrawColor];
     }
     else {
         [self.navigationController.navigationBar setBarTintColor:kTraceColor];
     }
     
     if ([segue.identifier isEqualToString:@"PickTrace"])
     {
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // Start loading the Traces for this User while transitioning the view
         [self.tracesMgr loadTracesForUser:[PFUser currentUser]];
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         
         TracePickerViewController *destTracePicker = (TracePickerViewController *) [segue destinationViewController];
         [destTracePicker setTracesMgr:self.tracesMgr];
     }
     else if ([segue.identifier isEqualToString:@"TermsFromHome"])
     {         
         TermsOfUseViewController *termsViewController = (TermsOfUseViewController *) [segue destinationViewController];
         termsViewController.agreementRequired = YES;
         termsViewController.showLogout = YES;
     }
     
 }


@end
