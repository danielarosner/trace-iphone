//
//  DataLogger.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/31.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLogger : NSObject

@property (nonatomic, strong) NSMutableArray *tracePoints_x;
@property (nonatomic, strong) NSMutableArray *tracePoints_y;
@property (nonatomic, strong) NSMutableArray *annotationPoints_x;
@property (nonatomic, strong) NSMutableArray *annotationPoints_y;
@property (nonatomic, strong) NSMutableString *annotationText;

@end
