//
//  PhotoAnnotationShowViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/24.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "AnnotationData.h"

@interface PhotoAnnotationShowViewController : UIViewController

@property (strong, nonatomic) AnnotationData *annotation;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
