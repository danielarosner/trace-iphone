//
//  AnnotationData.m
//  Trace Map
//
//  Created by Steve Cahill on 2/9/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "AnnotationData.h"

@implementation AnnotationData

- (id)init
{
    if ((self = [super init]))
    {
        self.x = -1.0;
        self.y = -1.0;
        
        return self;
    } else {
        return nil;
    }
}

- (id)initWithX:(float)x y:(float)y
{
    if ((self = [super init]))
    {
        self.x = x;
        self.y = y;
        
        return self;
    } else {
        return nil;
    }
}

// copy override [NSCopying]
//
-(id) copyWithZone:(NSZone *)zone
{
    AnnotationData *aCopy = [[AnnotationData alloc] init];
    [aCopy deepCopyFrom:self];
    
    return(aCopy);
}

-(void) deepCopyFrom:(AnnotationData *)souceAnnotation
{
    self.x = souceAnnotation.x;
    self.y = souceAnnotation.y;
    self.text = [souceAnnotation.text copy];
    self.image = [souceAnnotation.image copy];
    self.audioData = [souceAnnotation.audioData copy];
}

@end
