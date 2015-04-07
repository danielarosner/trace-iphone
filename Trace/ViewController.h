//
//  ViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/15.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

