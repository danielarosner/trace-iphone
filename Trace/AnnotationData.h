//
//  AnnotationData.h
//  Trace Map
//
//  Created by Steve Cahill on 2/9/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnnotationData : NSObject<NSCopying>

@property (assign) NSInteger x;
@property (assign) NSInteger y;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *audioData;

- (id)initWithX:(float)x y:(float)y;
-(void) deepCopyFrom:(AnnotationData *)souceAnnotation;

@end
