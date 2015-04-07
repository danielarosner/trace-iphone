//
//  TraceData.m
//  Trace Map
//
//  Created by Steve Cahill on 2/8/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "TraceData.h"

@implementation TraceData

- (id)init
{
    if ((self = [super init]))
    {
        self.traceIndex = -1;
        self.path_length = 0;
        self.x = [[NSMutableArray alloc] initWithCapacity:64];
        self.y = [[NSMutableArray alloc] initWithCapacity:64];
        self.annotations = [[NSMutableArray alloc] initWithCapacity:32];
        
        return self;
    } else {
        return nil;
    }
}

-(Boolean) areAnnotaionsAvailable
{
    Boolean annotationsLoaded = !(self.annotations == nil);
    
    return(annotationsLoaded);
}

@end
