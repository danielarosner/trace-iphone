//
//  AchievementViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/14.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TracesMgr.h"
#import "TraceData.h"

@interface AchievementViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) TracesMgr *tracesMgr;
@property (assign) NSInteger traceIndex;
@property (assign) NSInteger walkDuration;
@property (strong, nonatomic) TraceData *traceData;
@property (strong, nonatomic) NSOperationQueue *directionsOperationQueue;
@property (assign) Boolean directionsComplete;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@end
