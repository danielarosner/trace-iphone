//
//  ViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/15.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

//
//  ViewController.m
//  MKDirectionsSample
//
#import "MapViewController.h"
#import "AppDelegate.h"
#import "AchievementViewController.h"
#import "PhotoAnnotationShowViewController.h"

static float human_walk = 0.0006;

@interface MapViewController (){
    CLLocation *recentLocation;
}

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapView setDelegate:self];
    ready = false;
    manualOperation = false;
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(47.6763079, -122.3728407);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
    NSLog(@"stepCoord %f, %f",usrPos.latitude, usrPos.longitude);
    
    self.mapView.showsUserLocation = NO;
    [self startUpdatingLocationIfAllowed];
    onePathDone = true;
    pathNumber = 1;

    // in case Annotations have not returned from the server yet
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAnnotationsLoaded:)
                                                 name:kAnnotationsLoaded
                                               object:nil];

    // Note that Annotations may NOT have returned from the server yet,
    // but should be coming soon.
    self.traceData = [self.tracesMgr getTraceDataAtIndex:self.traceIndex withAnnotations:YES];
    if (self.traceData) {
        clearPathNum = [[self.traceData x] count];
        
        self.traceTitle.text = [self.traceData traceTitle];
    }
    else {
        clearPathNum = 0;
        NSLog(@"MapViewController Bad Data: no data at %li", (long)self.traceIndex);
    }
    
    [self clearAnnotationsDisplayedArray];
    
    /* old
    
    // kokokara
    
    annotationDisplayed = [NSMutableArray array];
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // self.traceTitle.text = appDelegate.traceTitleRead;
    for (int i=0; i<appDelegate.annotationRead_x.count; i++) {
        [annotationDisplayed addObject:[NSNumber numberWithInt:1]];
    }
    
    clearPathNum = appDelegate.traceRead_x.count;
    audioData = [NSData data];
    [appDelegate.traceRead_x addObject:[NSNumber numberWithFloat:[appDelegate.traceRead_x[0] floatValue]]];
    [appDelegate.traceRead_y addObject:[NSNumber numberWithFloat:[appDelegate.traceRead_y[0] floatValue]]];
    
    
    // kokomade
    */
}

-(void) clearAnnotationsDisplayedArray
{
    // annotationDisplayed is an Array to flag if Nth annotation displayed yet
    //
    annotationDisplayed = [NSMutableArray array];
    NSInteger annotationsCnt = [[self.traceData annotations] count];
    for (int i=0; i < annotationsCnt; i++) {
        [annotationDisplayed addObject:[NSNumber numberWithInt:1]];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([avPlayer isPlaying])
    {
        [avPlayer stop];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // ready = true;
    
    if ([self.traceData areAnnotaionsAvailable] == NO)
    {
        // Annotations have not come back from the server yet
        // so make sure they are coming.
        if (self.tracesMgr.loadingAnnotationIndex == [self.traceData traceIndex])
        {
            NSLog(@"MapViewController is waiting for Annotations");
        }
        else
        {
            // try to get Annotations again
            // should have fired in TracePickerViewController::prepareForSegue
            //
            [self.tracesMgr loadAnnotationsForNthDrawing:[self.traceData traceIndex]
                                           withforceLoad:NO];
        }
    }
    
    self.activeAnnotation = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
 
    [self cleanUpLocationManager];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

-(void) handleAnnotationsLoaded:(NSNotification *)notification
{
    NSLog(@"Annotations loaded (MapViewController)");
    
    if ([self.tracesMgr setAnnotations: self.traceData])
    {
        [self clearAnnotationsDisplayedArray];
    }
}

// STC
//
- (void)startUpdatingLocationIfAllowed
{
    nextStep = 0;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.authorizationStatus = [CLLocationManager authorizationStatus];
    if (self.authorizationStatus == kCLAuthorizationStatusNotDetermined)
    {
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [_locationManager requestWhenInUseAuthorization];     // for foreground only, iOS 8
        }
        else
        {
            //  iOS 7 does not require map authorization
            [self startUpdatingLocation];
        }
    }
    else if (self.authorizationStatus == kCLAuthorizationStatusDenied)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LocationServiceDisabledTitle", nil)
                                    message:NSLocalizedString(@"LocationServiceDisabledMsg", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
    else if (self.authorizationStatus == kCLAuthorizationStatusRestricted)
    {
        // This app is not authorized to use location services.
        // The user cannot change this app’s status, possibly due to active restrictions
        // such as parental controls being in place.
        //
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LocationServiceDisabledTitle", nil)
                                    message:NSLocalizedString(@"LocationServiceRestrictedMsg", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
    else
    {
        [self startUpdatingLocation];
    }
}

// Must have permission, otherwise call startUpdatingLocationIfAllowed first
//
-(void) startUpdatingLocation
{
    self.mapView.showsUserLocation = YES;
    [_locationManager startUpdatingLocation];
    self.startUpdatingLocationAt = [NSDate date];

    NSLog(@"Start updating location. timestamp:%@", [[NSDate date] description]);
}

#pragma mark - CLLocationManagerDelegate

// STC
-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.authorizationStatus = status;
    
    if ((self.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) ||
        (self.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways))
    {
        [self startUpdatingLocation];
    }
    else if (self.authorizationStatus == kCLAuthorizationStatusDenied)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LocationServiceDisabledTitle", nil)
                                    message:NSLocalizedString(@"LocationServiceDisabledMsg", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
    else if (self.authorizationStatus == kCLAuthorizationStatusRestricted)
    {
        // This app is not authorized to use location services.
        // The user cannot change this app’s status, possibly due to active restrictions
        // such as parental controls being in place.
        //
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LocationServiceDisabledTitle", nil)
                                    message:NSLocalizedString(@"LocationServiceRestrictedMsg", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    recentLocation = locations.lastObject;
    if (recentLocation.timestamp.timeIntervalSince1970 < _startUpdatingLocationAt.timeIntervalSince1970) {
        // Ignore old location.
        return;
    }
    
    [_mapView setCenterCoordinate:recentLocation.coordinate animated:YES];


    // was already commented out...
    //if (_mapAnnotation == nil) {
    //    _mapAnnotation = [[MKPointAnnotation alloc] init];
     //   [_mapView addAnnotation:_mapAnnotation];
    //}
    //_mapAnnotation.coordinate = recentLocation.coordinate;
    
    //NSLog(@"Updated location:%f %f timestamp:%@", recentLocation.coordinate.latitude, recentLocation.coordinate.longitude, recentLocation.timestamp.description);
    
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    //ユーザ位置とステップ開始点からの距離を取得
    if(onePathDone) {//GPS起動時は現在地をスタート地点にして経路探索 - GPS startup to the current location to the start point and route search
        if (usrPos.latitude == 0.0) {
            initUsrPos = recentLocation.coordinate;
            appDelegate.userLocation_latitude  = initUsrPos.latitude;
            appDelegate.userLocation_longitude = initUsrPos.longitude;
        }
        usrPos = recentLocation.coordinate;
        NSLog(@"User: %f, %f",usrPos.latitude, usrPos.longitude);
        [self searchPath:recentLocation];
        onePathDone = false;
        
    }else {//それ以外の時は次のステップまでの距離を取得 - Get the distance to the next step when otherwise
        
        //サーバからまだ経路が返ってきてないかもよ処理 -By might not come back is still the route from the server processing
        if (!stepCoord) {
            NSLog(@"madayo!");
            return;
        }
        [self checkDis:recentLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_locationManager stopUpdatingLocation];
    [[[UIAlertView alloc] initWithTitle:nil
                                message:NSLocalizedString(@"Failed to get your location.", nil)
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}


-(void) cleanUpLocationManager
{
    if (self.locationManager)
    {
        [_locationManager stopUpdatingLocation];
        [_locationManager stopUpdatingHeading];
        [_locationManager stopMonitoringSignificantLocationChanges];
        _locationManager.delegate = nil;
        self.locationManager = nil;
    }
}

#pragma mark -

//ユーザ位置が更新された時に次のステップ開始点との距離を取得したりとかごにょごにょするやつ
// Guy to Gonyogonyo Toka or obtain the distance between the next step starting point when the user position has been updated
- (void) checkDis:(CLLocation *)usr
{
    if (manualOperation) return;
    
    if (pathNumber==1 && nextStep==0) {
        MKRouteStep *step = route.steps[0];
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:step.instructions
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        self.instruction.text = step.instructions;
        nextStep++;
        ready = true;
    }
    
    NSLog(@"PN: %d", pathNumber);
    NSLog(@"NS: %d / %d", nextStep, (int)route.steps.count);
    
    if (nextStep==0) {
        MKRouteStep *step = route.steps[0];
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:step.instructions
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        if (!manualOperation) self.instruction.text = step.instructions;
        nextStep++;
    }
    
    CLLocationDistance dis = [usr distanceFromLocation:[[CLLocation alloc] initWithLatitude:stepCoord[nextStep].latitude longitude:stepCoord[nextStep].longitude]];
    NSLog(@"dis:%.2f",dis);
    NSLog(@"next:%d",nextStep);
    self.distanceShow.text = [NSString stringWithFormat:@"%.2f [m]", dis];
    
    if (dis<20.0) {
        if (nextStep==1){
            [self.mapView removeOverlays:self.mapView.overlays];
            [self.mapView addOverlay:route.polyline];
        }
        MKRouteStep *step = route.steps[nextStep];
        if (nextStep<route.steps.count-1) {
            
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:step.instructions
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
        if (!manualOperation) self.instruction.text = step.instructions;
        nextStep++;
        
    }
    
    CLLocationDistance distodes = [usr distanceFromLocation:[[CLLocation alloc] initWithLatitude:stepCoord[route.steps.count-1].latitude longitude:stepCoord[route.steps.count-1].longitude]];
    NSLog(@"%f", distodes);
    if(nextStep == route.steps.count && distodes<20.0){
        if (pathNumber == clearPathNum) [self performSegueWithIdentifier:@"Completed" sender:nil];
        nextStep = 0;
        onePathDone = true;
        pathNumber++;
    }
    
    // AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float scale = (self.walkDuration * human_walk) / ([self.traceData path_length]);
    
    AnnotationData *curAnnotation;
    CLLocationDistance distance;
    CLLocationCoordinate2D antCoordinate;
    NSInteger annotationsCnt = [[self.traceData annotations] count];
    if ((annotationsCnt > 0) && ready)
    {
        for (int i=0; ((i < annotationsCnt) && (self.activeAnnotation == nil)); i++)
        {
            curAnnotation = [self.traceData.annotations objectAtIndex:i];
            
            antCoordinate = CLLocationCoordinate2DMake(initUsrPos.latitude - (curAnnotation.y  - [self.traceData.y[0] floatValue]) * scale, initUsrPos.longitude + (curAnnotation.x - [self.traceData.x[0] floatValue]) * scale);
            
            distance = [recentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:antCoordinate.latitude longitude:antCoordinate.longitude]];
            
            if (distance<30.0 && [annotationDisplayed[i] intValue]==1)
            {
                [annotationDisplayed replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                NSLog(@"distance:%.2f",distance);
                
                self.activeAnnotation = curAnnotation;
                
                if (curAnnotation.image)
                {
                    // [NSThread sleepForTimeInterval:1];
                    NSLog(@"Show photo for annotation #%i", i);
                    
                    [self performSegueWithIdentifier:@"PhotoShowing" sender:self];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:curAnnotation.text
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK", nil] show];
                }
                
                if (curAnnotation.audioData)
                {
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
                    avPlayer = [[AVAudioPlayer alloc]initWithData:curAnnotation.audioData error:nil];
                    avPlayer.delegate = self;
                    avPlayer.volume = 1.0;
                    [avPlayer play];
                }
            }
        }
        
    }
    
    /* STC old code
     
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float path_length = [appDelegate.distanceRead[0] floatValue];
    float scale = (self.walkDuration  * human_walk) / path_length;
    
    if (appDelegate.annotationRead_x.count>0 && ready) {
        
        for (int i=0; i<appDelegate.annotationRead_x.count; i++) {
            CLLocationCoordinate2D antCoordinate = CLLocationCoordinate2DMake(initUsrPos.latitude - ([appDelegate.annotationRead_y[i] floatValue] - [appDelegate.traceRead_y[0] floatValue]) * scale, initUsrPos.longitude + ([appDelegate.annotationRead_x[i] floatValue] - [appDelegate.traceRead_x[0] floatValue]) * scale);
            
            CLLocationDistance distance = [recentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:antCoordinate.latitude longitude:antCoordinate.longitude]];
            
            if (distance<30.0 && [annotationDisplayed[i] intValue]==1) {
                
                [annotationDisplayed replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                NSLog(@"distance:%.2f",distance);
                
                NSInteger target_wdlength = 0;
                for (int j=0; j<i+1; j++) {
                    target_wdlength += [appDelegate.textIndexRead[i] integerValue];
                }
                
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:[appDelegate.textAnnotationRead substringWithRange:NSMakeRange(target_wdlength, [appDelegate.textIndexRead[i+1] intValue])]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
                
                
                int audioNum = -1;
                for (int j=0; j<appDelegate.audioAnnotationRead.count; j++) {
                    if ([appDelegate.audioAnnotationRead[j] integerValue] == i+1) audioNum = j+1;
                    //NSLog(@"Audio Annotation: %d", [appDelegate.audioAnnotationRead[j] integerValue]);
                    //NSLog(@"Incremental i: %d", i+1);
                }
                if (audioNum > -1) {
                    PFFile *audioPFFile = [appDelegate.audioFilesFound[0] valueForKey:[@"audioFile" stringByAppendingString:[NSString stringWithFormat:@"%d", audioNum]] ];
                    // NSLog(@"I'm here working");
                    audioData = [audioPFFile getData];
                    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
                    avPlayer = [[AVAudioPlayer alloc]initWithData:audioData error:nil];
                    avPlayer.delegate = self;
                    avPlayer.volume=1.0;
                    [avPlayer play];
                }
                
                
                appDelegate.photoNumber = -1;
                for (int j=0; j<appDelegate.photoAnnotationRead.count; j++) {
                    if ([appDelegate.photoAnnotationRead[j] integerValue] == i+1) appDelegate.photoNumber = j+1;
                }
                if (appDelegate.photoNumber > -1) {
                    [NSThread sleepForTimeInterval:1];
                    NSLog(@"Photo Number is %d", appDelegate.photoNumber);
                    [self performSegueWithIdentifier:@"PhotoShowing" sender:nil];
                    
                }
                // NSLog(@"Photo Number is %d", appDelegate.photoNumber);
                
            }
        }
        
    }
    */
}

- (IBAction)manualAutomaticSwitchPressed:(id)sender
{
    if (self.manualAutomatic.on == YES) {
        self.manualAutomaticState.text = @" ";
        manualOperation = false;
    }else{
        self.manualAutomaticState.text = @"manual";
        manualOperation = true;
    }
}


- (void)searchPath:(CLLocation *)usr
{
    NSLog(@"Path Number is %d", pathNumber);
    // 近所の座標
    //
    // float path_length = [appDelegate.distanceRead[0] floatValue];
    float scale = (self.walkDuration * human_walk) / ([self.traceData path_length]);
    
    NSInteger cnt = [[self.traceData x] count];
    if (pathNumber == cnt)
    {
        [self performSegueWithIdentifier:@"Completed" sender:nil];
        return;
    }
    
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(initUsrPos.latitude - ([self.traceData.y[pathNumber-1] floatValue] - [self.traceData.y[0] floatValue]) * scale, initUsrPos.longitude + ([self.traceData.x[pathNumber-1] floatValue]   - [self.traceData.x[0] floatValue]) * scale);
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(initUsrPos.latitude - ([self.traceData.y[pathNumber] floatValue] - [self.traceData.y[0] floatValue]) * scale, initUsrPos.longitude + ([self.traceData.x[pathNumber] floatValue]   - [self.traceData.x[0] floatValue]) * scale);
    
    // CLLocationCoordinate2D から MKPlacemark を生成
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate addressDictionary:nil];
    // MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:usrPos addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate addressDictionary:nil];
    
    // MKPlacemark から MKMapItem を生成
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    // MKMapItem をセットして MKDirectionsRequest を生成
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = fromItem;
    request.destination = toItem;
    request.requestsAlternateRoutes = YES;
    request.transportType = MKDirectionsTransportTypeWalking;
    
    // MKDirectionsRequest から MKDirections を生成
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    // 経路検索を実行
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         if (error) return;
         
         if ([response.routes count] > 0)
         {
             route = [response.routes objectAtIndex:0];
             stepCoord = malloc(sizeof(CLLocationCoordinate2D)*route.steps.count);
             stepPoints = malloc(sizeof(MKMapPoint)*route.steps.count);
             
             for(int i=0;i<route.steps.count; i++) {
                 MKRouteStep *step = route.steps[i];
                 NSRange range;
                 range.location = 0;
                 range.length = 1;
                 
                 [step.polyline getCoordinates:&stepCoord[i] range:range];
                 NSLog(@"stepCoord %f, %f",stepCoord[i].latitude, stepCoord[i].longitude);
                 
                 NSLog(@"%lu",(unsigned long)step.polyline.pointCount);
                 NSLog(@"%@",step.instructions);
                 
             }
             //
             [self checkDis:usr];
             if (pathNumber==1) {
                 [self.mapView addOverlay:route.polyline];
             }
         }
     }];
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    //    [player release];
}

- (IBAction)prevButtonPressed:(id)sender
{
    if (!manualOperation) return;
    if (pathNumber <= 1) return;
    
    if (pathNumber>1)
    {
        [self.mapView removeOverlays:self.mapView.overlays];
        pathNumber--;
        nextStep = 0;
    }
    
    [self searchPath:recentLocation];
    [self.mapView addOverlay:route.polyline];
    MKRouteStep *step = route.steps[nextStep];
    self.instruction.text = step.instructions;
    nextStep++;
    
}


- (IBAction)nextButtonPressed:(id)sender
{
    if (!manualOperation) return;

    if (nextStep==1){
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addOverlay:route.polyline];
    }
    if (nextStep > route.steps.count-2)
    {
        if (pathNumber == clearPathNum) [self performSegueWithIdentifier:@"Completed" sender:nil];
        nextStep = 0;
        pathNumber++;
        [self searchPath:recentLocation];
    }
    
    MKRouteStep *step = route.steps[nextStep];
    self.instruction.text = step.instructions;
    nextStep++;
    
    
}

- (IBAction)goBack:(UIStoryboardSegue *)sender
{
    
}


- (IBAction)goBack0:(UIStoryboardSegue *)sender
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (([segue.identifier isEqualToString:@"Cheat"]) ||
        ([segue.identifier isEqualToString:@"Completed"]))
    {
        [self cleanUpLocationManager];
        
        AchievementViewController *achView = (AchievementViewController *) [segue destinationViewController];
        [achView setTracesMgr:self.tracesMgr];
        [achView setTraceIndex:self.traceIndex];
        [achView setWalkDuration: self.walkDuration];
        [achView setTraceData: self.traceData];
    }
    else if ([segue.identifier isEqualToString:@"PhotoShowing"])
    {
        PhotoAnnotationShowViewController *photoView = (PhotoAnnotationShowViewController *) [segue destinationViewController];
        [photoView setAnnotation:self.activeAnnotation];
    }
}

#pragma mark - MKMapViewDelegate

// 地図上に描画するルートの色などを指定（これを実装しないと何も表示されない）
// Specify, for example, the root of the color to be drawn on the map (nothing is displayed if you do not implement this)
//
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *aRoute = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:aRoute];
        routeRenderer.lineWidth = 2.0;
        routeRenderer.strokeColor = [UIColor redColor];
        return routeRenderer;
    }
    else {
        return nil;
    }
}

@end
