//
//  AppDelegate.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/15.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// @property (strong, nonatomic) NSMutableArray *tracePoints_x;
// @property (strong, nonatomic) NSMutableArray *tracePoints_y;
// @property (strong, nonatomic) NSMutableArray *annotationPoints_x;
// @property (strong, nonatomic) NSMutableArray *annotationPoints_y;
// @property (strong, nonatomic) NSMutableString *textAnnotation;
// @property (strong, nonatomic) NSMutableArray *textIndex;
// @property (strong, nonatomic) UIImage *image;
// @property (strong, nonatomic) NSString *traceTitle;
// @property (strong, nonatomic) NSString *traceDescriptionl;

// @property (strong, nonatomic) NSData *photoData;

// @property (strong, nonatomic) NSMutableArray *traceRead_x;
// @property (strong, nonatomic) NSMutableArray *traceRead_y;
// @property (strong, nonatomic) NSMutableArray *annotationRead_x;
// @property (strong, nonatomic) NSMutableArray *annotationRead_y;
// @property (strong, nonatomic) NSMutableString *textAnnotationRead;
// @property (strong, nonatomic) NSMutableArray *textIndexRead;
// @property (strong, nonatomic) NSMutableArray *distanceRead;

// @property (strong, nonatomic) NSMutableArray *audioAnnotation;
// @property (strong, nonatomic) NSMutableArray *photoAnnotation;
// @property (strong, nonatomic) NSMutableArray *audioAnnotationRead;
// @property (strong, nonatomic) NSMutableArray *photoAnnotationRead;
// @property (nonatomic) int photoNumber;

// @property (nonatomic) NSInteger pickerDuration;
// @property (nonatomic) NSMutableArray *totalDistance;
// @property (nonatomic) NSInteger numberOfAnnotation;
// @property (nonatomic) NSInteger numberOfAudio;
// @property (nonatomic) NSInteger numberOfPhoto;

// @property (nonatomic, strong) NSArray *audioFilesFound;
// @property (nonatomic, strong) NSArray *photoFilesFound;

// @property (nonatomic, strong) NSString *held4TextView;
// @property (nonatomic, strong) NSString *traceTitleRead;

// @property (strong, nonatomic) NSArray *users;
// @property (strong, nonatomic) NSArray *arr;

@property (nonatomic) float userLocation_latitude;          // set in MapViewController
@property (nonatomic) float userLocation_longitude;         // 

// @property (strong, nonatomic) UIImage *traceDownloaded;

@end

