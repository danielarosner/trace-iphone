//
//  DrawingViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/22.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TraceData.h"

@interface DrawingViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *canvas;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *annotateButton;

@property (weak, nonatomic) UIImageView *backgroundCanvas;

@property (nonatomic) CGPoint referencePoint;

@property (strong, nonatomic) TraceData *traceData;
// @property (strong, nonatomic) NSMutableArray *tracePoints_x;
// @property (strong, nonatomic) NSMutableArray *tracePoints_y;

- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)annotateButtonPressed:(id)sender;

@end
