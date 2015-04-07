//
//  ShowOriginalSketchViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/25.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TraceData.h"

@interface ShowOriginalSketchViewController : UIViewController

@property (strong, nonatomic) TraceData *traceData;

@property (weak, nonatomic) IBOutlet UIImageView *canvas;

@end
