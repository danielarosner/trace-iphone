//
//  TermsOfUseViewController.h
//  Trace Map
//
//  Created by Steve Cahill on 2/24/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsOfUseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *termsWebView;
@property (strong, nonatomic) UIBarButtonItem *logoutButton;

@property (assign) Boolean agreementRequired;
@property (assign) Boolean showLogout;

// used to hold on the way to the SignUpFromConsent segue
@property (assign) Boolean newUserConsented;
@property (assign) Boolean newUserAllowsNameUse;

@end
