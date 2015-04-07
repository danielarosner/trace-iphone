//
//  TraceUsersTableViewController.h
//  Trace Map
//
//  Created by Steve Cahill on 2/12/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TraceData.h"

#define kPFUsersSection                     0
#define kUnknownUsersSection                1

#define kDoNotSendEmailsButtonIndex         0
#define kSendEmailsButtonIndex              1

@interface TraceUsersTableViewController : UITableViewController<MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *traceUsers;       // PFUsers
@property (strong, nonatomic) NSMutableArray *unmatchedEmails;  // UnmatchedEmailData
@property (weak, nonatomic) TraceData *traceData;

@property (strong, nonatomic) MFMailComposeViewController *mailComposer;

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
