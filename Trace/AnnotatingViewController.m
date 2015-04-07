//
//  AnnotatingViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/27.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "AnnotatingViewController.h"
#import "DrawingViewController.h"
#import "QBPopupMenu.h"
#import "AnnotationEditViewController.h"
#import "AppDelegate.h"
#import "TraceUsersTableViewController.h"

@interface AnnotatingViewController ()
{
    CGPoint currentPoint;
    UIBezierPath *bezierPath;
    int actionNumber;
    BOOL select;
}

@end


@implementation AnnotatingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    select = true;
    self.selectedAnnotation = nil;
    self.tracePointViews = nil;
    self.canvas.image = [self.traceData image];
    
    // Edit | Delete popup
    //
    QBPopupMenuItem *ls0 = [QBPopupMenuItem itemWithTitle:@"Edit"   target:self action:@selector(actionEdit)];
    QBPopupMenuItem *ls1 = [QBPopupMenuItem itemWithTitle:@"Delete" target:self action:@selector(actionDelete)];
    NSArray *list = @[ls0, ls1];
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:list];
    popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
    self.popupMenu = popupMenu;
    
    /*
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.textIndex.count==0) {
        appDelegate.textIndex = [NSMutableArray array];
        [appDelegate.textIndex addObject:[NSNumber numberWithInt:0]];
    }
    
    self.canvas.image = appDelegate.image;
    
    / * move to viewWillAppear after fixing navigation STC
     
    for (int i=0; i<appDelegate.annotationPoints_x.count; i++) {
        CGPoint aPoint;
        aPoint.x = [appDelegate.annotationPoints_x[i] floatValue];
        aPoint.y = [appDelegate.annotationPoints_y[i] floatValue];
        CGRect rect = CGRectMake(aPoint.x-5, aPoint.y+45, 20, 20);
        UIImageView *imageView4Pic = [[UIImageView alloc]initWithFrame:rect];
        imageView4Pic.image = [UIImage imageNamed:@"trace_annotation.png"];
        [self.view addSubview:imageView4Pic];
    }
    */
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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    select = true;      // not quite sure what is happening here 
    
    [self updatePointSubViews];
}


-(void) updatePointSubViews
{
    AnnotationData *curAnnotation;
    
    // This is brut force...
    // remove old point views
    if (self.tracePointViews != nil)
    {
        [self.tracePointViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    self.tracePointViews = [[NSMutableArray alloc] initWithCapacity:20];
    
    NSInteger cnt = [self.traceData.annotations count];
    for (int i=0; i < cnt; i++)
    {
        curAnnotation = [self.traceData.annotations objectAtIndex:i];
        
        // aPoint.x = [appDelegate.annotationPoints_x[i] floatValue];
        // aPoint.y = [appDelegate.annotationPoints_y[i] floatValue];
        
        CGRect rect = CGRectMake(curAnnotation.x-5, curAnnotation.y+45, 20, 20);
        // STC wrong CGRect rect = CGRectMake(aPoint.x-15, aPoint.y-5, 20, 20);
        UIImageView *imageView4Pic = [[UIImageView alloc]initWithFrame:rect];
        imageView4Pic.image = [UIImage imageNamed:@"trace_annotation.png"];
        [self.view addSubview:imageView4Pic];
        
        [self.tracePointViews addObject:imageView4Pic];     // so can be removed easy
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL elgb = false;
    float x, y;
    float dist;
    NSInteger traceCnt = [self.traceData.x count];
    currentPoint = [[touches anyObject] locationInView:self.canvas];
    for (int i=0; i < traceCnt; i++)
    {
        x = [self.traceData.x[i] floatValue];
        y = [self.traceData.y[i] floatValue];
        dist = sqrt( (currentPoint.x - x) * (currentPoint.x - x) + (currentPoint.y - y) * (currentPoint.y - y) );
        if (dist < 15) {
            elgb = true;
        }
    }
    
    if (!elgb) return;
    
    NSInteger annoCnt = [self.traceData.annotations count];
    AnnotationData *curAnno;
    for (int i=0; i < annoCnt; i++)
    {
        curAnno = [self.traceData.annotations objectAtIndex:i];
        dist = sqrt( (currentPoint.x - curAnno.x) * (currentPoint.x - curAnno.x) + (currentPoint.y - curAnno.y) * (currentPoint.y - curAnno.y) );
        if (dist < 25)
        {
            select = false;
            self.selectedAnnotation = curAnno;
        }
    }
    
    if (select == true)
    {
        // New Annotation
        curAnno = [[AnnotationData alloc] initWithX:currentPoint.x
                                                  y:currentPoint.y];
        self.selectedAnnotation = curAnno;
        
        // do not add until Save in Annotation Edit
        // [self.traceData.annotations addObject:curAnno];
        
        /*
        [appDelegate.annotationPoints_x addObject:[NSNumber numberWithFloat:currentPoint.x]];
        [appDelegate.annotationPoints_y addObject:[NSNumber numberWithFloat:currentPoint.y]];
        appDelegate.numberOfAnnotation = appDelegate.annotationPoints_x.count;
        */
        
        [self performSegueWithIdentifier:@"Annotation" sender:nil];
    }
    
    if (select == false) {
        CGRect rect = CGRectMake(currentPoint.x-5, currentPoint.y+45, 20, 20);
        // STC wrong CGRect rect = CGRectMake(currentPoint.x-5, currentPoint.y, 20, 20);
        [self.popupMenu showInView:self.view targetRect:rect animated:YES];
    }
}


- (void)drawLine:(UIBezierPath*)path
{
    UIGraphicsBeginImageContext(self.canvas.frame.size);
    [self.lastDrawImage drawAtPoint:CGPointZero];
    [[UIColor blueColor] setStroke];
    [path stroke];
    self.canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SelectRecipients"])
    {
        TraceUsersTableViewController *usersTableView = segue.destinationViewController;
        
        [usersTableView setTraceData:self.traceData];
    }
    else if ([segue.identifier isEqualToString:@"Annotation"])
    {
        AnnotationEditViewController *vControl = segue.destinationViewController;
        
        [vControl setTraceData:self.traceData];
        [vControl setAnnotationMaster:self.selectedAnnotation];
        
        /*
        vControl.imageCaptured = self.traceImage;
        
        appDelegate.held4TextView = NULL;
        
        if (select==false) {
            int target_length = 0;
            for (int i=0; i<ant+1; i++) {
                target_length += [appDelegate.textIndex[i] intValue];
            }
            appDelegate.held4TextView = [appDelegate.textAnnotation substringWithRange:NSMakeRange(target_length, [appDelegate.textIndex[ant+1] intValue])];
            NSLog(@"%@", appDelegate.textAnnotation);
            NSLog(@"NA: %d", ant);
            NSLog(@"TL: %d", target_length);
            NSLog(@"LT: %d", [appDelegate.textIndex[ant+1] intValue]);
            
            [appDelegate.textAnnotation deleteCharactersInRange:NSMakeRange(target_length, [appDelegate.textIndex[ant+1] integerValue])];
            [appDelegate.textIndex removeObjectAtIndex:ant+1];
            
        }
         */
    }
}


- (IBAction)sendButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"SelectRecipients" sender:nil];
}


- (void)actionEdit
{
    [self performSegueWithIdentifier:@"Annotation" sender:nil];
}


- (void)actionDelete
{
    /*STC [self performSegueWithIdentifier:@"Reload" sender:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.annotationPoints_x removeObjectAtIndex:ant];
    [appDelegate.annotationPoints_y removeObjectAtIndex:ant];
    int target_length = 0;
    for (int i=0; i<ant+1; i++) {
        target_length += [appDelegate.textIndex[i] intValue];
    }
    [appDelegate.textAnnotation deleteCharactersInRange:NSMakeRange(target_length, [appDelegate.textIndex[ant+1] integerValue])];
    [appDelegate.textIndex removeObjectAtIndex:ant+1];
    
    for (int i=0; i<appDelegate.audioAnnotation.count; i++) {
        if ([appDelegate.audioAnnotation[i] intValue] > ant+1){
            [appDelegate.audioAnnotation replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[appDelegate.audioAnnotation[i] intValue]-1] ];
        }else if ([appDelegate.audioAnnotation[i] intValue] == ant+1) [appDelegate.audioAnnotation replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:-1]];
        // NSLog(@"%d", [appDelegate.audioAnnotation[i] intValue]);
        // NSLog(@"%d", ant+1);
    }
    for (int i=0; i<appDelegate.photoAnnotation.count; i++) {
        if ([appDelegate.photoAnnotation[i] intValue] > ant+1){
            [appDelegate.photoAnnotation replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[appDelegate.photoAnnotation[i] intValue]-1] ];
        }else if ([appDelegate.photoAnnotation[i] intValue] == ant+1) [appDelegate.photoAnnotation replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:-1]];
        // NSLog(@"%d", [appDelegate.photoAnnotation[i] intValue]);
        // NSLog(@"%d", ant+1);
    }
    */
    
    // could use removeObject, but make sure in Annotations array
    NSUInteger annoIndex = [self.traceData.annotations indexOfObject: self.selectedAnnotation];
    if (annoIndex != NSNotFound)  {
        [self.traceData.annotations removeObjectAtIndex:annoIndex];
    }
    else {
        NSLog(@"Error: AnnotatingViewController could not find Annotation to delete");
    }
    
    [self updatePointSubViews];     // STC
    select = true;                 // STC
}



@end
