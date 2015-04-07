//
//  AchievementViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/14.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "AchievementViewController.h"
#import "AppDelegate.h"
#import "ShowOriginalSketchViewController.h"

@interface AchievementViewController ()

@end


static float human_walk = 0.0006;


@implementation AchievementViewController
//{
//    __strong CLLocationManager *_locationManager;
// }


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    
    // because unused below  self.mapView.showsUserLocation = NO;
    //unused CLLocation *userLocation = self.mapView.userLocation.location;
    //unused CLLocationCoordinate2D uCoordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    
    //unused MKCoordinateRegion region = MKCoordinateRegionMake(uCoordinate, MKCoordinateSpanMake(0.05, 0.05));
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    CLLocationCoordinate2D centerCoordinate = self.mapView.userLocation.location.coordinate;
    printf("latitude:  %f\n", centerCoordinate.latitude);
    printf("longitude: %f\n", centerCoordinate.longitude);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
    self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
    
    [self.view addSubview:_mapView];
    
    if ([self.traceData image] == nil)
    {
        [self.imageButton setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self getPathWalkedInBackground];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.directionsOperationQueue cancelAllOperations];
}

// Watch this is using sleepForTimeInterval instead of calculating to get the directions result!
// The whole thing was put in the background to avoid crashing from not being responsive
// on the main thread.
//
-(void) getPathWalkedInBackground
{
    self.directionsOperationQueue = [[NSOperationQueue alloc] init];
    [_directionsOperationQueue addOperationWithBlock:^{
        // Perform long-running tasks without blocking main thread

        // CLLocationCoordinate2D center = CLLocationCoordinate2DMake(47.6763079, -122.3728407);
        // self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;


        //unused CLLocationCoordinate2D center = self.mapView.userLocation.location.coordinate;
        //unused CLLocation *userLocation = self.mapView.userLocation.location;
        //unused CLLocationCoordinate2D uCoordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        //unused  MKCoordinateRegion region = MKCoordinateRegionMake(uCoordinate, MKCoordinateSpanMake(0.03, 0.03));
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // float path_length = [appDelegate.distanceRead[0] floatValue];
        float path_length = [self.traceData path_length];
        float scale = (self.walkDuration * human_walk) / path_length;
        
        // scale = 9000;
        
        // printf("%f\n", scale);
        NSInteger cnt = [[self.traceData x] count];
        for (int i=0; i< cnt-1; i++)
        {
            [NSThread sleepForTimeInterval:0.2];
            
            float point_latitude0  = appDelegate.userLocation_latitude - ([self.traceData.y[i] floatValue]   - [self.traceData.y[0] floatValue]) * scale;
            float point_longitude0 = appDelegate.userLocation_longitude + ([self.traceData.x[i] floatValue]   - [self.traceData.x[0] floatValue]) * scale;
            float point_latitude1  = appDelegate.userLocation_latitude - ([self.traceData.y[i+1] floatValue] - [self.traceData.y[0] floatValue]) * scale;
            float point_longitude1 = appDelegate.userLocation_longitude + ([self.traceData.x[i+1] floatValue] - [self.traceData.x[0] floatValue]) * scale;
            
            
            CLLocationCoordinate2D point0 = CLLocationCoordinate2DMake(point_latitude0, point_longitude0);
            MKPlacemark *Placemark0 = [[MKPlacemark alloc] initWithCoordinate:point0 addressDictionary:nil];
            MKMapItem *Item0 = [[MKMapItem alloc] initWithPlacemark:Placemark0];
            
            CLLocationCoordinate2D point1 = CLLocationCoordinate2DMake(point_latitude1, point_longitude1);
            MKPlacemark *Placemark1 = [[MKPlacemark alloc] initWithCoordinate:point1 addressDictionary:nil];
            MKMapItem *Item1 = [[MKMapItem alloc] initWithPlacemark:Placemark1];
            
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
            request.source      = Item0;
            request.destination = Item1;
            request.transportType = MKDirectionsTransportTypeWalking;
            request.requestsAlternateRoutes = YES;
            
            MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
            
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
             {
                 if (error) {
                     NSLog(@"AchievementViewController Error: %@", [error description]);
                     return;
                 }
                 if ([response.routes count] > 0)
                 {
                     MKRoute *route = [response.routes objectAtIndex:0];
                     for (int i=0; i<route.steps.count; i++)
                     {
                         MKRouteStep *step = route.steps[i];
                         NSLog(@"notice: %@", step.instructions);
                     }
                     
                     // printf("%d\n", [route.steps count]);
                     NSLog(@"distance: %.2f meter", route.distance);
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.mapView addOverlay:route.polyline];
                     });
                 }
             }];
        }
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HomeSweetHome"])
    {
       // [_locationManager stopUpdatingLocation];
       // _locationManager.delegate=nil;
       // [NSThread sleepForTimeInterval:1];
    }
    else if ([segue.identifier isEqualToString:@"OriginalTraceImage"])
    {
        ShowOriginalSketchViewController *viewController = (ShowOriginalSketchViewController *) [segue destinationViewController];
        [viewController setTraceData:self.traceData];
    }
}


- (IBAction)onDone:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onSeeOriginalImage:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"OriginalTraceImage" sender:nil];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id<MKOverlay>)overlay {
    MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
    view.strokeColor = [UIColor blueColor];
    view.lineWidth = 2.0;
    return view;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
    MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, span);
    [self.mapView setRegion:region animated:YES];
}


@end
