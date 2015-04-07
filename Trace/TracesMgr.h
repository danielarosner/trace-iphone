//
//  TracesMgr.h
//  Trace Map
//
//  Created by Steve Cahill on 2/6/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Parse.h"
#import "TraceData.h"

/*
@protocol TracesMgrDelegate <NSObject>

@optional

-(void) tracesLoaded;

@end
*/

@interface TracesMgr : NSObject

// PFObject array of Traces for the current User
@property (strong, nonatomic) NSArray *tracesArray;

// parallel array to tracesArray that has array of linked Annotation PFObjects
// objects will be nil if not yet fetched
@property (strong, nonatomic) NSMutableArray *annotationsArray;
@property (assign) Boolean isLoadingTraces;
@property (assign) NSInteger loadingAnnotationIndex;

@property (weak, nonatomic) AppDelegate *appDelegate;

-(void) loadTracesForUser:(PFUser *)user;
-(void) loadAnnotationsForNthDrawing:(NSInteger)drawingIndex withforceLoad:(Boolean)forceLoad;

-(PFObject *) getNthDrawing:(NSInteger)index;
-(NSArray *)  getNthAnnotationsArray:(NSInteger)index;

-(TraceData *) getTraceDataAtIndex:(NSInteger)traceIndex withAnnotations:(Boolean)loadAnnotations;
-(Boolean) setAnnotations:(TraceData *)traceData;

+(PFObject *) buildDrawingForUpload:(TraceData *)traceData
                                 to:(NSMutableArray *)recipientsPFUserArray;

+(NSArray *) buildArrayOfUnmatchedEmails: (NSMutableArray *)unmatchedEmails
                                linkedTo:(PFObject *)drawingPFObject;

+(PFUser *) checkTraceUsername:(NSString *)username;
+(PFUser *) checkTraceEmail:(NSString *)email;

+(void) linkNewUsersEmailToAwaitingDrawings:(PFUser *)newUser withBlock:(PFBooleanResultBlock)block;

@end
