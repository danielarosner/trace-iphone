//
//  HomeViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/24.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TracesMgr.h"

@interface HomeViewController : UIViewController

@property (strong, nonatomic) TracesMgr *tracesMgr;

@property (weak, nonatomic) IBOutlet UIButton *bigDrawButton;
@property (weak, nonatomic) IBOutlet UIButton *bigWalkButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mActivityIndicator;

@end
