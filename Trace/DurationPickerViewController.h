//
//  DurationPickerViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/01.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TracesMgr.h"

#define kNumberOfDurationPoints     30

@interface DurationPickerViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
{
    UIPickerView *picker;
    NSInteger pickedDuration;
}

@property (weak, nonatomic) TracesMgr *tracesMgr;
@property (assign) NSInteger traceIndex;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
