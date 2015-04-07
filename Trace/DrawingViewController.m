//
//  DrawingViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/22.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "DrawingViewController.h"
#import "AnnotatingViewController.h"
#import "DataLogger.h"
#import "AppDelegate.h"


@interface DrawingViewController ()
{
    UIBezierPath *bezierPath;
    UIImage *lastDrawImage;
    CGPoint startPoint;
    BOOL drawEnabled;
    float total_distance;
    
    UIImage *bgLastImage;
}
@end


@implementation DrawingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    self.clearButton.enabled = NO;
    
    self.traceData = [[TraceData alloc] init];
    drawEnabled = YES;
    // CGRect rect = CGRectMake(0, 0, 320, 441);
    // self.backgroundCanvas =  [[UIImageView alloc]initWithFrame:rect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Disable iOS 7 back gesture
    // https://bhaveshdhaduk.wordpress.com/2014/05/17/ios-7-enable-or-disable-back-swipe-gesture-in-uinavigationcontroller/
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Enable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

// UIGestureRecognizerDelegate
//
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return(NO);
}


- (IBAction)clearButtonPressed:(id)sender
{
    lastDrawImage = nil;
    self.canvas.image = nil;
    [self.traceData.x removeAllObjects];
    [self.traceData.y removeAllObjects];
    drawEnabled = YES;
    
    [[self.traceData annotations] removeAllObjects];
}

- (IBAction)annotateButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"DrawToAnnotate" sender:self];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [[touches anyObject] locationInView:self.canvas];
    if (CGRectContainsPoint(self.clearButton.frame, currentPoint) || !drawEnabled){
        return;
    }
    bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineCapStyle = kCGLineCapRound;
    bezierPath.lineWidth = 3.0;
    [bezierPath moveToPoint:currentPoint];
    self.referencePoint = currentPoint;
    startPoint = currentPoint;
    
    [self.traceData.x addObject:[NSNumber numberWithFloat:currentPoint.x]];
    [self.traceData.y addObject:[NSNumber numberWithFloat:currentPoint.y]];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (bezierPath == nil){
        return;
    }
    CGPoint currentPoint = [[touches anyObject] locationInView:self.canvas];
    [bezierPath addLineToPoint:currentPoint];
    [self drawLine:bezierPath];
    // [self drawLineForBack:bezierPath];
    float distance = sqrt( (self.referencePoint.x - currentPoint.x)*(self.referencePoint.x - currentPoint.x) + (self.referencePoint.y - currentPoint.y)*(self.referencePoint.y - currentPoint.y) );
    if (distance > 25) {
        self.referencePoint = currentPoint;
        [self.traceData.x addObject:[NSNumber numberWithFloat:currentPoint.x]];
        [self.traceData.y addObject:[NSNumber numberWithFloat:currentPoint.y]];
        total_distance += distance;
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (bezierPath == nil){
        return;
    }
    CGPoint currentPoint = [[touches anyObject] locationInView:self.canvas];
    [bezierPath addLineToPoint:currentPoint];
    [bezierPath addLineToPoint:startPoint];
    [self drawLine:bezierPath];
    // [self drawLineForBack:bezierPath];
    lastDrawImage = self.canvas.image;
    [self.traceData.x addObject:[NSNumber numberWithFloat:currentPoint.x]];
    [self.traceData.y addObject:[NSNumber numberWithFloat:currentPoint.y]];
    bezierPath = nil;
    self.clearButton.enabled = YES;
    drawEnabled = NO;
}



- (void)drawLine:(UIBezierPath*)path
{
    // self.canvas.backgroundColor = [UIColor colorWithRed:0.953 green:0.443 blue:0.349 alpha:1.0];
    UIGraphicsBeginImageContext(self.canvas.frame.size);
    [lastDrawImage drawAtPoint:CGPointZero];
    [[UIColor colorWithRed:0.8 green:0.92 blue:0.96 alpha:1.0] setStroke];
    [path stroke];
    self.canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/*
- (void)drawLineForBack:(UIBezierPath*)path
{
    // self.canvas.backgroundColor = [UIColor colorWithRed:0.953 green:0.443 blue:0.349 alpha:1.0];
    UIGraphicsBeginImageContext(self.backgroundCanvas.frame.size);
    [bgLastImage drawAtPoint:CGPointZero];
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0] setStroke];
    [path stroke];
    self.backgroundCanvas.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DrawToAnnotate"])
    {
        AnnotatingViewController *vControl = segue.destinationViewController;
        
        [self.traceData setImage:lastDrawImage];
        [self.traceData setPath_length:total_distance];
        
        [vControl setTraceData:self.traceData];
        
        /*
        AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.tracePoints_x = [NSMutableArray array];
        appDelegate.tracePoints_y = [NSMutableArray array];
        appDelegate.annotationPoints_x = [NSMutableArray array];
        appDelegate.annotationPoints_y = [NSMutableArray array];
        appDelegate.totalDistance = [NSMutableArray array];
        appDelegate.tracePoints_x = [self.tracePoints_x mutableCopy];
        appDelegate.tracePoints_y = [self.tracePoints_y mutableCopy];
        appDelegate.image = lastDrawImage;
        [appDelegate.totalDistance addObject:[NSNumber numberWithFloat:total_distance]];
        vControl.traceImage = lastDrawImage;
        appDelegate.textAnnotation = [NSMutableString string];
        appDelegate.textIndex = [NSMutableArray array];
        // appDelegate.textIndex = [NSMutableArray array];
        // [appDelegate.textIndex addObject:[NSNumber numberWithInt:0]];
        
        [self.tracePoints_x removeAllObjects];
        [self.tracePoints_y removeAllObjects];
        
        appDelegate.audioAnnotation = [NSMutableArray array];
        appDelegate.photoAnnotation = [NSMutableArray array];
        appDelegate.photoData       = [NSData data];
        
        appDelegate.numberOfAnnotation = 0;
        appDelegate.numberOfAudio      = 0;
        appDelegate.numberOfPhoto      = 0;
        */
    }
}

- (IBAction)goBack:(UIStoryboardSegue *)sender
{
    
}

@end
