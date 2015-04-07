//
//  TraceData.h
//  Trace Map
//
//  Created by Steve Cahill on 2/8/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"
#import "AnnotationData.h"

@interface TraceData : NSObject

@property (assign) NSInteger traceIndex;

@property (strong, nonatomic) NSString *traceTitle;
@property (strong, nonatomic) NSString *traceDescription;
@property (strong, nonatomic) UIImage *image;       // from the creators trace drawing
@property (strong, nonatomic) PFUser *creator;
@property (strong, nonatomic) NSDate *createdAt;

// Replaceing AppDelegate variables
@property (strong, nonatomic) NSMutableArray *x;    // appDelegate.traceRead_x
@property (strong, nonatomic) NSMutableArray *y;    // appDelegate.traceRead_y
@property (assign) float path_length;               // appDelegate.distanceRead[0]

// AnnotationData array
@property (strong, nonatomic) NSMutableArray *annotations;

-(Boolean) areAnnotaionsAvailable;

@end
