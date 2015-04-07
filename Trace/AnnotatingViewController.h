//
//  AnnotatingViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/27.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBPopupMenu.h"
#import "TraceData.h"

@interface AnnotatingViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) TraceData *traceData;
@property (strong, nonatomic) AnnotationData *selectedAnnotation;

// STC Most of these classes were not being used...
//STC @property (strong, nonatomic) NSMutableArray *tracePoints_x;
//STC @property (strong, nonatomic) NSMutableArray *tracePoints_y;

// @property (strong, nonatomic) NSMutableArray *annotationPoints_x;
// @property (strong, nonatomic) NSMutableArray *annotationPoints_y;
//STC @property (strong, nonatomic) NSMutableArray *annotationLabel;

//STC @property (strong, nonatomic) NSMutableString *annotatedText;

@property (weak, nonatomic) IBOutlet UIImageView *canvas;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

// @property (nonatomic) UIImage *traceImage;
@property (nonatomic) UIImage *lastDrawImage;

//STC @property (nonatomic) UIImage *temporaryImage;

@property (nonatomic, strong) QBPopupMenu *popupMenu;

@property (strong, nonatomic) NSMutableArray *tracePointViews;        // STC array of point UIView

- (IBAction)sendButtonPressed:(id)sender;


@end
