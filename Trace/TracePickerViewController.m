//
//  TracePickerViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/02.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "TracePickerViewController.h"
#import "DurationPickerViewController.h"


@implementation TracePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mShowTrace = NO;      // DEBUG
    
    self.navigationController.navigationBarHidden = NO;
    
    self.mDateFormatter = [[NSDateFormatter alloc] init] ;
    [self.mDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.mDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTracesLoaded:)
                                                 name:kTracesLoadedNotification
                                               object:nil];
    if ([self.tracesMgr isLoadingTraces]) {
        [self.mActivityIndicator startAnimating];
        self.traceIndex = 0;
    }
    else {
        [self.mActivityIndicator stopAnimating];
        
        NSInteger traceCount = [[self.tracesMgr tracesArray] count];
        self.traceIndex = traceCount - 1;
    }
    
    [self updateUserText:self.traceIndex];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleTracesLoaded:(NSNotification *)notification
{
    [self.mActivityIndicator stopAnimating];
    
    NSInteger traceCount = [[self.tracesMgr tracesArray] count];
    self.traceIndex = traceCount - 1;
    [self updateUserText:self.traceIndex];
}

//  Set the display text
//
-(void) updateUserText:(NSInteger) traceIndex
{
    TraceData *traceData = [self.tracesMgr getTraceDataAtIndex:traceIndex withAnnotations:NO];    // [self.tracesMgr getNthDrawing:traceIndex ];
    if (traceData)
    {
        [self.drawnByLabel setHidden:NO];
        self.traceTitle.text = traceData.traceTitle;
        self.descriptionTextView.text = traceData.traceDescription;
        if (traceData.creator) {
            self.userName.text = [traceData.creator username];
        }
        else {
            self.userName.text = @"";
        }
        
        NSString *labelData = [self.mDateFormatter stringFromDate:traceData.createdAt];
        self.timeStamp.text = labelData;
    
        if (self.mShowTrace)
        {
            // image can be nil
            if (traceData.image) {
                [self.mTraceImageView setImage:traceData.image];
            }
            else {
                [self.mTraceImageView setImage:nil];
            }
        }
        
        CGFloat redColored = (traceIndex%6)*0.08 + 0.5059;
        self.canvas.backgroundColor = [UIColor colorWithRed:redColored green:0.8078 blue:0.8078 alpha:1.0];
    }
    else {
        if (self.mActivityIndicator)
        {
            [self.drawnByLabel setHidden:YES];
            self.traceTitle.text = NSLocalizedString(@"PickTrace_Loading", nil);
            self.descriptionTextView.text = @"";
            self.timeStamp.text = @"";
            self.userName.text = @"";
            
            if (self.mShowTrace) {
                [self.mTraceImageView setImage:nil];
            }
        }
        else
        {
            // out of range
            [self.drawnByLabel setHidden:YES];
            self.traceTitle.text = NSLocalizedString(@"PickTrace_NoTraces", nil);
            self.descriptionTextView.text = NSLocalizedString(@"PickTrace_RequestOne", nil);
            self.timeStamp.text = @"";
            self.userName.text = @"";

            if (self.mShowTrace) {
                [self.mTraceImageView setImage:nil];
            }
        }
    }
}

#pragma mark - Navigation

- (IBAction)gotoNextButtonPressed:(id)sender
{
    NSInteger traceCount = [[self.tracesMgr tracesArray] count];
    
    self.traceIndex++;
    if (self.traceIndex >= traceCount) {
        self.traceIndex = 0;
    }
    [self updateUserText:self.traceIndex];
}


- (IBAction)gotoPrevButtonPressed:(id)sender
{
    NSInteger traceCount = [[self.tracesMgr tracesArray] count];
    
    self.traceIndex--;
    if (self.traceIndex < 0) {
        self.traceIndex = traceCount - 1;
    }
    [self updateUserText:self.traceIndex];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickDuration"])
    {
        DurationPickerViewController *durationPicker = (DurationPickerViewController *) [segue destinationViewController];
        [durationPicker setTracesMgr: self.tracesMgr];
        [durationPicker setTraceIndex:self.traceIndex];
        
        if (self.traceIndex >= 0)
        {
            // - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Call server to load Annotations so they return by
            // the time the User gets to the Map (or soon after)
            //
            [self.tracesMgr loadAnnotationsForNthDrawing:self.traceIndex
                                           withforceLoad:NO];
            // - - - - - - - - - - - - - - - - - - - - - - - - - - -
        }
    }
    
    /*
     OLD
    if ([segue.identifier isEqualToString:@"GoToMap"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.traceRead_x         = [NSMutableArray array];
        appDelegate.traceRead_y         = [NSMutableArray array];
        appDelegate.distanceRead        = [NSMutableArray array];
        appDelegate.annotationRead_x    = [NSMutableArray array];
        appDelegate.annotationRead_y    = [NSMutableArray array];
        appDelegate.textAnnotationRead  = [NSMutableString string];
        appDelegate.textIndex           = [NSMutableArray array];
        appDelegate.audioAnnotationRead = [NSMutableArray array];
        appDelegate.photoAnnotationRead = [NSMutableArray array];
        appDelegate.audioFilesFound     = [NSArray array];
        appDelegate.photoFilesFound     = [NSArray array];
        
//        traceIndex = 20;       // STC play
        
        appDelegate.traceRead_x         = [[appDelegate.arr[_traceIndex] valueForKey:@"trace_x"] mutableCopy];
        appDelegate.traceRead_y         = [[appDelegate.arr[_traceIndex] valueForKey:@"trace_y"] mutableCopy];
        appDelegate.distanceRead        = [[appDelegate.arr[_traceIndex] valueForKey:@"trace_d"] mutableCopy];
        appDelegate.annotationRead_x    = [[appDelegate.arr[_traceIndex] valueForKey:@"annot_x"] mutableCopy];
        appDelegate.annotationRead_y    = [[appDelegate.arr[_traceIndex] valueForKey:@"annot_y"] mutableCopy];
        appDelegate.textAnnotationRead  = [[appDelegate.arr[_traceIndex] valueForKey:@"annot_t"] mutableCopy];
        appDelegate.textIndexRead       = [[appDelegate.arr[_traceIndex] valueForKey:@"annot_i"] mutableCopy];
        appDelegate.audioAnnotationRead = [[appDelegate.arr[_traceIndex] valueForKey:@"audio_annotation"] mutableCopy];
        appDelegate.photoAnnotationRead = [[appDelegate.arr[_traceIndex] valueForKey:@"photo_annotation"] mutableCopy];
        appDelegate.traceTitleRead      =  [appDelegate.arr[_traceIndex] valueForKey:@"trace_title"];
        
        NSData *imageData = [NSData data];
        imageData = [appDelegate.arr[_traceIndex] valueForKey:@"traceImage"];
        appDelegate.traceDownloaded = [[UIImage alloc] initWithData:imageData];
        
        / *
        PFFile *imagePFFile = [appDelegate.arr[traceIndex] valueForKey:@"image"];
        if (imagePFFile.isDataAvailable){
            imageData = [imagePFFile getData];
            appDelegate.traceDownloaded = [[UIImage alloc] initWithData:imageData];
            NSLog(@"acquired");
        } else {
            appDelegate.traceDownloaded = nil;
            NSLog(@"Not acquired");
            // return;
        }
         * /
        
        // NSLog(@"HHHHH %lu", (unsigned long)appDelegate.textIndexRead.count);
        
        
        PFQuery *audioQuery = [PFQuery queryWithClassName:@"audioObject"];
        // audioQuery.limit = 500;
        [audioQuery whereKey:@"audioFilesNumber" equalTo:[NSString stringWithFormat:@"%lu", _traceIndex]];
        appDelegate.audioFilesFound = [audioQuery findObjects];
        
        PFQuery *photoQuery = [PFQuery queryWithClassName:@"photoObject"];
        // photoQuery.limit = 500;
        [photoQuery whereKey:@"photoFilesNumber" equalTo:[NSString stringWithFormat:@"%lu", _traceIndex]];
        appDelegate.photoFilesFound = [photoQuery findObjects];
        
        
        // NSLog(@"piclerNumber: %lu(long)", traceIndex);
        NSLog(@"%@", appDelegate.audioFilesFound);
        NSLog(@"%@", appDelegate.photoFilesFound);
        
        
        
        // NSLog(@"%@", appDelegate.audioFilesFound);
        // NSLog(@"Number of Audio Files: %d", appDelegate.audioFilesFound.count);
        // NSLog(@"Picker Number: %@", [NSString stringWithFormat:@"%d", traceIndex]);
        // NSLog(@"IntexRead: %@", appDelegate.audioFilesFound);

        / *
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                appDelegate.arr = objects;
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        * /
        // NSLog (@"data %@", appDelegate.traceRead_x);
        
        // [self.tracePoints_x removeAllObjects];
        // [self.tracePoints_y removeAllObjects];
    }
    */
}


@end
