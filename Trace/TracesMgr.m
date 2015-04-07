//
//  TracesMgr.m
//  Trace Map
//
//  Created by Steve Cahill on 2/6/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "TracesMgr.h"
#import "UnmatchedEmailData.h"

@implementation TracesMgr

// what format of the data to use
//  NO  = iOS TestObject_2, UsersList, photoObject, audioObject
//  YES = Android compatable Drawing, Annotation, and build in User
Boolean gUseNewAndroidDataFormat = YES;

- (id)init
{
    if ((self = [super init]))
    {
        self.tracesArray = nil;
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.isLoadingTraces = NO;
        self.loadingAnnotationIndex = -1;
        
        return self;
    } else {
        return nil;
    }
}

-(void) loadTracesForUser:(PFUser *)user
{
    NSString *dbName;
    
    if (gUseNewAndroidDataFormat) {
        dbName = @"Drawing";
    } else
    {
        dbName = @"TestObject_2";
    }
    PFQuery *query = [PFQuery queryWithClassName:dbName];
    
    if (gUseNewAndroidDataFormat)
    {
        [query includeKey:@"creator"];                  // do creator lookup for PFUser details
        query.limit = 100;      // 100 default, 1000 max
        [query whereKey:@"receiver_list" equalTo:user]; // lookup receiver list
    }
    else {
        // this will load All dbs
        query.limit = 500;      // 100 default, 1000 max
        
        [query includeKey:@"createdBy"];        // also do creator lookup for PFUser details
    }
    self.isLoadingTraces = YES;
    
    __weak TracesMgr *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            weakSelf.tracesArray = objects;     // store the array of "Drawing" PFObjects
            
            // Annotations will not be loaded until requested,
            // but allocate the array to hold the arrays of annotations now
            weakSelf.annotationsArray = [[NSMutableArray alloc] initWithCapacity:[weakSelf.tracesArray count]];
            NSInteger cnt = [weakSelf.tracesArray count];
            NSInteger x;
            for (x = 0; x < cnt; x++) {
                [weakSelf.annotationsArray addObject:[NSNull null]];
            }
            
            weakSelf.isLoadingTraces = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTracesLoadedNotification object:self];
            
            // NSLog(@"Traces: %@", [self.tracesArray description]);
        }
        else {
            weakSelf.isLoadingTraces = NO;
            // Log details of the failure
            NSLog(@"TracesMgr Drawing objects load Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // sync... self.tracesArray = [query findObjects];
}

// Load the related Annotations for the given drawingObj
//
//  drawingIndex - index of drawingObj (in self.tracesArray)
//  forceLoad - call server even if annotations exist in self.annotationsArray
//
-(void) loadAnnotationsForNthDrawing:(NSInteger)drawingIndex withforceLoad:(Boolean)forceLoad
{
    if (gUseNewAndroidDataFormat)
    {
        Boolean loadAnnotations = forceLoad;
        PFObject *drawingObj = [self getNthDrawing:drawingIndex];
        if (drawingObj)
        {
            if (! forceLoad)
            {
                // see if the Annotations are already loaded
                //
                id checkExistingAnnotations = [self.annotationsArray objectAtIndex:drawingIndex];
                if (checkExistingAnnotations == [NSNull null]) {
                    loadAnnotations = YES;
                }
                else {
                    loadAnnotations = NO;
                }
                
                // may need to check if already fetching...
            }
            
            if (loadAnnotations)
            {
                self.loadingAnnotationIndex = drawingIndex;
                __weak TracesMgr *weakSelf = self;
                
                // annotationsArray is an array of Annotation PFObject
                NSArray *annotationsArray = (NSArray *)[drawingObj objectForKey:@"annotation_list"];
                // NSLog(@"Annotations Array: %@", [annotationsArray description]);
                
                [PFObject fetchAllInBackground:annotationsArray
                                         block:^(NSArray *objects, NSError *error)
                {
                    if (!error)
                     {
                         [weakSelf.annotationsArray setObject:objects atIndexedSubscript:drawingIndex];
                         
                         weakSelf.loadingAnnotationIndex = -1;
                         
                         // Broadcast that the Annotations have been loaded for the Nth trace Drawing
                         //
                         NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:drawingIndex]
                                                                              forKey:kAnnotationDrawingIndexLoadedKey];
                         [[NSNotificationCenter defaultCenter] postNotificationName:kAnnotationsLoaded
                                                                             object:self
                                                                           userInfo:dataDict];
                         
                         NSLog(@"%lu Annotations loaded for Drawing #%li", (unsigned long)[objects count], (long)drawingIndex);
                     }
                     else {
                         weakSelf.loadingAnnotationIndex = -1;
                         // Log details of the failure
                         NSLog(@"TracesMgr Annotation objects load Error: %@ %@", error, [error userInfo]);
                     }
                 }];
            }
        }
    }
}

#pragma mark - Wrappers

-(PFObject *) getNthDrawing:(NSInteger)index
{
    NSInteger cnt = [self.tracesArray count];
    PFObject *drawingObject = nil;
    
    if ((index >= 0) && (index < cnt))
    {
        drawingObject = [self.tracesArray objectAtIndex:index];
    }
    
    return(drawingObject);
}

// Array of PFObject with Annotations
//
-(NSArray *) getNthAnnotationsArray:(NSInteger)index
{
    NSInteger cnt = [self.annotationsArray count];
    id annotationsOrNull;
    NSArray *annotations = nil;
    
    if ((index >= 0) && (index < cnt))
    {
        annotationsOrNull = [self.annotationsArray objectAtIndex:index];
        
        if (annotationsOrNull == [NSNull null])
        {
            // return cleaner nil
            annotations = nil;
        }
        else
        {
            // Annotaions available
            annotations = annotationsOrNull;
        }
    }
    
    return(annotations);
}

//  Load new drawing db into similar data structures that were defined in AppDelegate.h
//  Note that Annotations may not be available because it is a separate Query
//
-(TraceData *) getTraceDataAtIndex:(NSInteger)traceIndex withAnnotations:(Boolean)loadAnnotations
{
    TraceData *traceData = nil;
    NSArray *tempTraceRead_x;
    NSArray *tempTraceRead_y;
    float distanceRead;
    UIImage *traceImage = nil;
    NSData *imageData = nil;
    
    PFObject *holdDrawingObject = [self getNthDrawing:traceIndex];
    if (holdDrawingObject)
    {
        traceData = [[TraceData alloc] init];
        traceData.traceIndex = traceIndex;          // set the index for the PFObject, which matches the related raw annotations array
        
        traceData.createdAt = [holdDrawingObject valueForKey:@"createdAt"];
        
        if (gUseNewAndroidDataFormat)
        {
#warning  Original Android db missing 'path_length' float, 'traceImage' file, and 'title' String (uses description)

            traceData.traceTitle = holdDrawingObject[@"title"];
            traceData.traceDescription = holdDrawingObject[@"description"];
            
            tempTraceRead_x = holdDrawingObject[@"px_x_list"];
            tempTraceRead_y = holdDrawingObject[@"px_y_list"];
            
            traceData.creator = [holdDrawingObject valueForKey:@"creator"];

            id pathLength = holdDrawingObject[@"path_length"];
            if (pathLength) {
                // add type check
                distanceRead = [pathLength floatValue];
            }
            else {
                // fake length on existing Android data?
                distanceRead = 700.0;
            }
            
            // load drawn Trace image
            //
            PFFile *imagePhotoFile = [holdDrawingObject valueForKey:@"traceImage"];
            if (imagePhotoFile)
            {
                if ([imagePhotoFile isDataAvailable])
                {
                    // if imagePhotoFile was not already in memory, then Parse would make a synchronous server call
                    // but it still warns in the log https://parse.com/questions/pffile-getdata-generates-warnparseoperationonmainthread-when-isdataavailable-is-true
                    //
                    imageData = [imagePhotoFile getData];
                    
                    if ((imageData) && ([imageData length] > 0))
                    {
                        // OK, in memory
                        traceImage = [[UIImage alloc] initWithData:imageData];
                        traceData.image = traceImage;
                    }
                    else {
                        NSLog(@"TracesMgr Error: empty synchronous drawing image");
                    }
                }
                else
                {
                    // *** Asynchronous image load ***
                    // So the first time called the image for the trace drawing will be delayed
                    // In the current design, that should not be a problem
                    //
                    __weak TraceData *weakTraceData = traceData;
                    [imagePhotoFile getDataInBackgroundWithBlock:^(NSData *asyncImageData, NSError *error)
                    {
                        if (!error)
                        {
                            if ((asyncImageData) && ([asyncImageData length] > 0))
                            {
                                // OK, threaded
                                [weakTraceData setImage: [[UIImage alloc] initWithData:asyncImageData]];
                            }
                            else {
                                NSLog(@"TracesMgr Error: empty asynchronous drawing image");
                            }
                        }
                        else {
                            NSLog(@"TracesMgr Error: failed to load drawing image: %@\n  Error:%@",  [weakTraceData traceTitle], [error description]);
                        }
                    }];
                }
            }
            
            
            
        }
        else {
            // iOS db
            traceData.traceTitle = holdDrawingObject[@"trace_title"];
            traceData.traceDescription = holdDrawingObject[@"trace_description"];
            
            tempTraceRead_x = holdDrawingObject[@"trace_x"];
            tempTraceRead_y = holdDrawingObject[@"trace_y"];
            
            traceData.creator = [holdDrawingObject valueForKey:@"createdBy"];
            
            NSArray *distanceArray = holdDrawingObject[@"trace_d"];
            if ((distanceArray) && ([distanceArray count] > 0)) {
                distanceRead = [[distanceArray objectAtIndex:0] floatValue];
            }
            else
            {
                distanceRead = 700.0;       // should NOT be missing!
                NSLog(@"Warning:  distanceRead, trace_d, should not be missing");
            }
            
            imageData = [holdDrawingObject valueForKey:@"traceImage"];
            if ((imageData) && ([imageData length] > 0))
            {
                traceImage = [[UIImage alloc] initWithData:imageData];
            }
            traceData.image = traceImage;
        }
        
        traceData.x = [[NSMutableArray alloc] initWithArray: tempTraceRead_x];
        traceData.y = [[NSMutableArray alloc] initWithArray: tempTraceRead_y];
        
        // Add closing point?
        [traceData.x addObject:[NSNumber numberWithFloat:[tempTraceRead_x[0] floatValue]]];
        [traceData.y addObject:[NSNumber numberWithFloat:[tempTraceRead_y[0] floatValue]]];
        
        traceData.path_length = distanceRead;
        
        if (loadAnnotations)
        {
            [self setAnnotations:traceData];
        }
    }
    
    return(traceData);
}

//  Load Annotaions from PFObjects array in to the passed in
//  traceData's AnnotationData array
//
//  Assumes loadAnnotationsForNthDrawing was already called and returned!
//
//  Warning: Sound and image files will be downloaded asynchronously.
//      This could cause as many threads/delays as annotations with
//      sounds and images you are loading.
//
-(Boolean) setAnnotations:(TraceData *)traceData
{
    Boolean loaded = NO;
    NSInteger cnt;
    NSArray *annotationsPFObjectArray;
    PFObject *curPFObjectAnnotation;
    AnnotationData *curAnnotationData;
    PFFile *imageFile;
    NSData *imageData;
    UIImage *image;
    PFFile *audioFile;
    NSData *audioData;
    
    if (traceData)
    {
        annotationsPFObjectArray = [self getNthAnnotationsArray:traceData.traceIndex];
        if (annotationsPFObjectArray)
        {
            cnt = [annotationsPFObjectArray count];
            traceData.annotations = [[NSMutableArray alloc] initWithCapacity:cnt];
            for (curPFObjectAnnotation in annotationsPFObjectArray)
            {
                curAnnotationData = [[AnnotationData alloc] init];
                
                // Android format (with added image and audio)
                // id tempObj = curPFObjectAnnotation[@"px_x"];
                // NSLog(@"%@ type:%s", [tempObj description], [tempObj objCType]);
                //
                
                curAnnotationData.x = [curPFObjectAnnotation[@"px_x"] integerValue];
                curAnnotationData.y = [curPFObjectAnnotation[@"px_y"] integerValue];
                curAnnotationData.text = curPFObjectAnnotation[@"text"];
                if (gUseNewAndroidDataFormat)
                {
                    // optional Annotation image
                    imageFile = curPFObjectAnnotation[@"image"];
                    if (imageFile)
                    {
                        if ([imageFile isDataAvailable])
                        {
                            // if imageFile was not already in memory, then Parse would make a synchronous server call
                            // but it still warns in the log https://parse.com/questions/pffile-getdata-generates-warnparseoperationonmainthread-when-isdataavailable-is-true
                            //
                            imageData = [imageFile getData];
                            if ((imageData) && ([imageData length] > 0))
                            {
                                // OK, in memory
                                image = [[UIImage alloc] initWithData:imageData];
                                curAnnotationData.image = image;
                            }
                            else {
                                NSLog(@"TracesMgr Error: empty synchronous annotation image");
                            }
                        }
                        else
                        {
                            // *** Asynchronous image load ***
                            // So the first time called the annotation image will be delayed
                            //
                            __weak AnnotationData *weakAnnotationData = curAnnotationData;
                            [imageFile getDataInBackgroundWithBlock:^(NSData *asyncImageData, NSError *error)
                            {
                                if (!error)
                                {
                                    if ((asyncImageData) && ([asyncImageData length] > 0))
                                    {
                                        // OK, threaded
                                        [weakAnnotationData setImage: [[UIImage alloc] initWithData:asyncImageData]];
                                    }
                                }
                                else {
                                    NSLog(@"TracesMgr Error: failed to load annotation image: %@\n  Error:%@",  [weakAnnotationData text], [error description]);
                                }
                            }];
                        }
                    }
                
                    // optional Annotation audio note
                    // optional Annotation image
                    audioFile = curPFObjectAnnotation[@"audio"];
                    if (audioFile)
                    {
                        if ([audioFile isDataAvailable])
                        {
                            // if was not in memory, then would make a synchronous server call
                            audioData = [audioFile getData];
                            if ((audioData) && ([audioData length] > 0))
                            {
                                // OK, in memory
                                curAnnotationData.audioData =  audioData;
                            }
                            else {
                                NSLog(@"TracesMgr Error: empty synchronous annotation audio note");
                            }
                        }
                        else
                        {
                            // *** Asynchronous audio note load ***
                            // So the first time called the annotation audio will be delayed
                            //
                            __weak AnnotationData *weakAnnotationData = curAnnotationData;
                            [audioFile getDataInBackgroundWithBlock:^(NSData *asyncAudioData, NSError *error)
                             {
                                 if (!error)
                                 {
                                     if ((asyncAudioData) && ([asyncAudioData length] > 0))
                                     {
                                         // OK, threaded
                                         [weakAnnotationData setAudioData: asyncAudioData];
                                     }
                                     else {
                                         NSLog(@"TracesMgr Error: empty asynchronous annotation audio note");
                                     }
                                 }
                                 else {
                                     NSLog(@"TracesMgr Error: failed to load annotation audio: %@\n  Error:%@",  [weakAnnotationData text], [error description]);
                                 }
                             }];
                        }
                    }
                }
                
                [traceData.annotations addObject:curAnnotationData];
            }
            loaded = YES;
        }
        else
        {
            // Annotations not loaded yet
            traceData.annotations = nil;
        }
    }
    return(loaded);
}

#pragma mark - Upload

// Build drawing object that will need to be uploaded.
//  recipientsPFUserArray - Array of PFUsers to receive the Trace
//
+(PFObject *) buildDrawingForUpload:(TraceData *)traceData
                                 to:(NSMutableArray *)recipientsPFUserArray
{
    CGFloat imageCompression = 0.8;     // 0 - 1.0 jpeg compression quality
    PFFile *curImagePFFile;
    NSData *curImageData;
    PFFile *curAudioFile;
    
    PFObject *drawing;      // <---master 'Drawing' object
    PFUser *currentUser = [PFUser currentUser];
    
    // Drawing table - drawing with annotation and User links
    //
    drawing = [PFObject objectWithClassName:@"Drawing"];
    
    // All Users can read the Trace
    PFACL *drawingACL = [PFACL ACLWithUser:currentUser];
    [drawingACL setPublicReadAccess:YES];
    [drawingACL setPublicWriteAccess:YES];
    drawing.ACL = drawingACL;
    
    // Android naming
    drawing[@"creator"] = currentUser;
    drawing[@"receiver_list"] = recipientsPFUserArray;  // Recipients
    drawing[@"title"] = traceData.traceTitle;   // Android just uses "description"
    drawing[@"description"] = traceData.traceDescription;
    drawing[@"px_x_list"] = traceData.x;        // Arrary
    drawing[@"px_y_list"] = traceData.y;        // Arrary
    
    // New
    drawing[@"path_length"] = [NSNumber numberWithFloat: traceData.path_length];
    
    if (traceData.image)
    {
        curImageData = UIImageJPEGRepresentation(traceData.image, imageCompression);
        curImagePFFile = [PFFile fileWithName:@"trace_image.jpg" data:curImageData];
        drawing[@"traceImage"] = curImagePFFile;
    }
    
    // Annotation table
    //
    PFObject *curAnnotationPFObject;    // Annotation
    AnnotationData *curAnnotationData;
    NSInteger cnt = [traceData.annotations count];
    NSMutableArray *annotationPFObjects = [[NSMutableArray alloc] initWithCapacity:cnt];

    for (curAnnotationData in traceData.annotations)
    {
        curAnnotationPFObject = [PFObject objectWithClassName:@"Annotation"];
        
        curAnnotationPFObject[@"px_x"] = [NSNumber numberWithFloat:curAnnotationData.x];
        curAnnotationPFObject[@"px_y"] = [NSNumber numberWithFloat:curAnnotationData.y];
        curAnnotationPFObject[@"text"] = curAnnotationData.text;

        // Image
        if (curAnnotationData.image)
        {
            curImageData = UIImageJPEGRepresentation(curAnnotationData.image, imageCompression);
            curImagePFFile = [PFFile fileWithName:@"anno_image.jpg" data:curImageData];
            curAnnotationPFObject[@"image"] = curImagePFFile;
        }
        
        // Audio
        if (curAnnotationData.audioData)
        {
            curAudioFile = [PFFile fileWithName:@"voice_memo.mp4" data:curAnnotationData.audioData];
            curAnnotationPFObject[@"audio"] = curAudioFile;
        }
        [annotationPFObjects addObject:curAnnotationPFObject];
    }
    drawing[@"annotation_list"] = annotationPFObjects;
    
    return(drawing);
}

// Build objects array that will need to be uploaded.
// Not in drawing ojbect, stored in separate table.
// The UnmatchedEmail table should be checked when a new
// User is created and then link the new User to the Drawing.
//
+(NSArray *) buildArrayOfUnmatchedEmails: (NSMutableArray *)unmatchedEmails
                                linkedTo:(PFObject *)drawingPFObject
{
    NSMutableArray *unmatchedEmailPFObjects = nil;
    
    // UnmatchedEmail table - emails for people not on Trace Map yet
    //
    PFObject *unmatchedEmailObj;
    UnmatchedEmailData *curUnmatchedEmailData;
    NSInteger cnt = [unmatchedEmails count];
    if (cnt > 0)
    {
        unmatchedEmailPFObjects = [[NSMutableArray alloc]initWithCapacity:cnt];
        
        for (curUnmatchedEmailData in unmatchedEmails)
        {
            unmatchedEmailObj = [PFObject objectWithClassName:@"UnmatchedEmail"];
            unmatchedEmailObj[@"email"] = curUnmatchedEmailData.email;
            unmatchedEmailObj[@"drawing"] = drawingPFObject;
            
            [unmatchedEmailPFObjects addObject:unmatchedEmailObj];
        }
    }
    return(unmatchedEmailPFObjects);
}

#pragma mark - Recipient Users support

// Build an array of PFUsers from raw User entered string
// Used to create Drawing.receiver_list
/*
+(NSMutableArray *) buildUsersArray:(NSString *)rawString
{
    NSMutableArray *arrayOfPFUsers = nil;
    // PFUser *targetUser;
    NSError *error;
    
    if ((rawString) && ([rawString length] > 0))
    {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:rawString]; // find User

        NSArray *users = [query findObjects: &error];   // *synchronously*
        if (error == nil)
        {
            if ([users count] > 0)
            {
                arrayOfPFUsers = [[NSMutableArray alloc] initWithArray:users];
            }
        }
        else
        {
            NSLog(@"TracesMgr Error resolving PFUsers: %@", [error debugDescription]);
        }
    }
    
    // [arrayOfPFUsers addObject: [PFUser currentUser]];
    
    return(arrayOfPFUsers);
}
*/

+(PFUser *) checkTraceUsername:(NSString *)username
{
    PFUser *targetUser = nil;
    NSError *error;
    
    if ((username) && ([username length] > 0))
    {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:username]; // find User
        
        NSArray *users = [query findObjects: &error];   // *synchronously*
        if (error == nil)
        {
            if ([users count] > 0)
            {
                targetUser = [users objectAtIndex:0];
            }
        }
        else
        {
            NSLog(@"TracesMgr Error resolving PFUser %@: %@", username, [error debugDescription]);
        }
    }
    return(targetUser);
}

+(PFUser *) checkTraceEmail:(NSString *)email
{
    PFUser *targetUser = nil;
    NSError *error;
    
    if ((email) && ([email length] > 0))
    {
        PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:email]; // find User
        
        NSArray *users = [query findObjects: &error];   // *synchronously*
        if (error == nil)
        {
            if ([users count] > 0)
            {
                targetUser = [users objectAtIndex:0];
            }
        }
        else
        {
            NSLog(@"TracesMgr Error resolving PFUser email %@: %@", email, [error debugDescription]);
        }
    }
    return(targetUser);
}

/*
 
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
*/
+(void) linkNewUsersEmailToAwaitingDrawings:(PFUser *)newUser withBlock:(PFBooleanResultBlock)block
{
    NSString *emailStr = [newUser email];
    
    if ([emailStr length] > 0)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"UnmatchedEmail"];
        [query includeKey:@"drawing"];
        [query whereKey:@"email" equalTo:emailStr];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 NSInteger matchingCnt = [objects count];
                 if (matchingCnt > 0)
                 {
                     NSMutableArray *drawingObjectsArray = [[NSMutableArray alloc] initWithCapacity: matchingCnt];

                     NSLog(@"TracesMgr %@ linked to %i drawings.", emailStr, (int)[objects count]);
                     PFObject *curUnmatchedEmailObject;
                     PFObject *curDrawingObject;
                     for (curUnmatchedEmailObject in objects)
                     {
                         curDrawingObject = curUnmatchedEmailObject[@"drawing"];
                         // Add new User to the end of the drawing.receiver_list
                         [curDrawingObject addObject:newUser forKey:@"receiver_list"];
                         
                         /*
                            PFRelation *usersDrawingRelation;
                             // add newly created User
                             usersDrawingRelation = [curDrawingObject relationForKey:@"receiver_list"];
                             [usersDrawingRelation addObject:newUser];
                           */
                             // [curDrawingObject saveInBackground];
                         
                             [drawingObjectsArray addObject:curDrawingObject];
                     }
                    
                     [PFObject saveAllInBackground:drawingObjectsArray
                                             block:^(BOOL succeeded, NSError *error)
                     {
                         // Delete the UnmatchedEmail rows that match this new user's email
                         //
                         [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error)
                         {
                             if (succeeded) {
                                 NSLog(@"TracesMgr unmatchedEmails deleted");
                                 
                                 block(YES, nil);  // done!!!!!
                             }
                             else {
                                 NSLog(@"TracesMgr unmapped email delete; Error: %@ %@", error, [error userInfo]);
                                 block(NO, error);
                             }
                         }];
                     }];
                 }
                 else {
                     NSLog(@"TracesMgr No pending drawings for new User.");
                     block(YES, nil);
                 }
             }
             else
             {
                 NSLog(@"TracesMgr unmapped email Error: %@ %@", error, [error userInfo]);
                 block(NO, error);
             }
         }];
    }
    else {
        block(YES, nil);
    }
}


@end
