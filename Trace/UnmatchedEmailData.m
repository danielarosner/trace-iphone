//
//  UnmatchedEmailData.m
//  Trace Map
//
//  Created by Steve Cahill on 2/12/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "UnmatchedEmailData.h"

@implementation UnmatchedEmailData

- (id)init
{
    if ((self = [super init]))
    {
        self.email = nil;
        self.dateEmailedInvitaion = nil;
        
        return self;
    } else {
        return nil;
    }
}

@end
