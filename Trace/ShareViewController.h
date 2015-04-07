//
//  ShareViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/29.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TraceData.h"

@interface ShareViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) TraceData *traceData;

@property (weak, nonatomic) IBOutlet UITextField *traceTitle;
@property (weak, nonatomic) IBOutlet UITextView *traceDescription;
@property (weak, nonatomic) IBOutlet UILabel *recipientsSummaryLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (weak, nonatomic) IBOutlet UILabel *listofusers;

@property (strong, nonatomic) NSMutableArray *traceUsers;       // PFUsers
@property (strong, nonatomic) NSMutableArray *unmatchedEmails;  //UnmatchedEmailData

@property (strong, nonatomic) NSArray *temporaryArray;
@property (strong, nonatomic) NSArray *userLs;

-(IBAction)saveButtonPressed:(id)sender;

@end
