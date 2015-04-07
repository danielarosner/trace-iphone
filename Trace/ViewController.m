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


#import "ViewController.h"
#import "AppDelegate.h"

// float point_latitude[]  = {  47.6549143,   47.6673079,   47.6672661};
// float point_longitude[] = {-122.3064518, -122.3118407, -122.3437352};


float raw_x[] = { 173.000000, 154.500000, 136.500000, 117.500000, 104.000000, 114.500000, 134.000000, 152.000000, 155.500000, 153.500000, 156.500000, 175.000000, 189.000000, 200.500000, 219.000000, 235.000000, 255.500000, 272.500000, 283.500000, 303.500000, 322.500000, 333.500000, 335.500000, 330.500000, 322.000000, 324.000000, 334.500000, 335.000000, 329.500000, 314.500000, 298.500000, 283.000000, 262.000000, 246.500000, 227.000000, 209.000000, 188.500000, 173.000000, 158.000000, 154.500000, 154.500000, 165.500000, 173.500000, 173.500000,
    
    
    };
float raw_y[] = { 145.500000, 134.500000, 132.500000, 132.500000, 144.000000, 160.000000, 166.500000, 168.500000, 189.000000, 207.500000, 225.500000, 235.000000, 243.500000, 225.000000, 219.500000, 218.500000, 218.500000, 225.500000, 241.500000, 237.000000, 231.000000, 214.500000, 195.000000, 175.500000, 160.000000, 140.500000, 123.500000, 105.000000, 86.000000, 71.000000, 61.500000, 54.000000, 52.000000, 52.000000, 52.000000, 52.500000, 57.000000, 62.500000, 72.500000, 90.000000, 108.500000, 124.500000, 142.000000, 145.000000,
};


static int num_of_points = sizeof(raw_x) / sizeof(raw_x[0]);
// static int num_of_points_y = sizeof(raw_y) / sizeof(raw_y[0]);


@interface ViewController ()

@end


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(47.6763079, -122.3728407);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03, 0.03);
    self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
    
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(47.6763079, -122.3728407);
    
    for (int i=0; i<num_of_points-1; i++)
    {
        
        float point_latitude0  = center.latitude  - (raw_x[i] - raw_x[0])/12000;
        float point_longitude0 = center.longitude + (raw_y[i] - raw_y[0])/12000;
        float point_latitude1  = center.latitude  - (raw_x[i+1] - raw_x[0])/12000;
        float point_longitude1 = center.longitude + (raw_y[i+1] - raw_y[0])/12000;
        
        
        CLLocationCoordinate2D point0 = CLLocationCoordinate2DMake(point_latitude0, point_longitude0);
        MKPlacemark *Placemark0 = [[MKPlacemark alloc] initWithCoordinate:point0 addressDictionary:nil];
        MKMapItem *Item0 = [[MKMapItem alloc] initWithPlacemark:Placemark0];
        
        CLLocationCoordinate2D point1 = CLLocationCoordinate2DMake(point_latitude1, point_longitude1);
        MKPlacemark *Placemark1 = [[MKPlacemark alloc] initWithCoordinate:point1 addressDictionary:nil];
        MKMapItem *Item1 = [[MKMapItem alloc] initWithPlacemark:Placemark1];
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        request.source      = Item0;
        request.destination = Item1;
        request.requestsAlternateRoutes = YES;
        
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
         {
             if (error) {
                 return;
             }
             if ([response.routes count] > 0)
             {
                 MKRoute *route = [response.routes objectAtIndex:0];
                 NSLog(@"distance: %.2f meter", route.distance);
                 [self.mapView addOverlay:route.polyline];
             }
         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.lineWidth = 2.0;
        routeRenderer.strokeColor = [UIColor redColor];
        return routeRenderer;
    }
    else
    {
        return nil;
    }
}


@end
