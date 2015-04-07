//
//  TracePickerViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/02.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TracesMgr.h"

@interface TracePickerViewController : UIViewController

@property (weak, nonatomic) TracesMgr *tracesMgr;
@property (strong) NSDateFormatter *mDateFormatter;

@property (weak, nonatomic) IBOutlet UIButton *gotoNextButton;
@property (weak, nonatomic) IBOutlet UIButton *gotoPrevButton;

@property (weak, nonatomic) IBOutlet UIImageView *canvas;

@property (assign) Boolean mShowTrace;
@property (weak, nonatomic) IBOutlet UIImageView *mTraceImageView;

@property (weak, nonatomic) IBOutlet UILabel *traceTitle;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *drawnByLabel;

@property NSInteger traceIndex;
@property UIImage *image;
// @property NSString *groupNumberId;
// @property BOOL nothing;


-(IBAction)gotoNextButtonPressed:(id)sender;
-(IBAction)gotoPrevButtonPressed:(id)sender;

@end
