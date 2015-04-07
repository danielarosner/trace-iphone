//
//  ViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/15.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TracesMgr.h"
#import "TraceData.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, AVAudioPlayerDelegate>
{
    AVAudioPlayer *avPlayer;
    
    //__strong CLLocationManager *_locationManager;
    __strong MKPointAnnotation *_mapAnnotation;
    //__strong NSDate *_startUpdatingLocationAt;
    
    CLLocationCoordinate2D *stepCoord;
    CLLocationCoordinate2D usrPos;
    CLLocationCoordinate2D initUsrPos;
    MKMapPoint *stepPoints;
    MKRoute *route;
    int nextStep;
    unsigned long clearPathNum;
    BOOL onePathDone;
    int pathNumber;
    NSMutableArray *annotationDisplayed;    // to flag if Nth annotation displayed yet
    // NSData *audioData;
    BOOL ready;
    BOOL manualOperation;
}

@property (weak, nonatomic) TracesMgr *tracesMgr;
@property (assign) NSInteger traceIndex;
@property (assign) NSInteger walkDuration;
@property (strong, nonatomic) TraceData *traceData;

@property (strong, nonatomic) NSDate *startUpdatingLocationAt;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) AnnotationData *activeAnnotation;     // used to pass from segue

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
// @property (strong, nonatomic) IBOutlet CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *traceTitle;

@property (weak, nonatomic) IBOutlet UILabel  *instruction;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISwitch *manualAutomatic;
@property (weak, nonatomic) IBOutlet UILabel  *manualAutomaticState;

@property (weak, nonatomic) IBOutlet UILabel  *distanceShow;

@property (assign) CLAuthorizationStatus authorizationStatus;


-(IBAction)prevButtonPressed:(id)sender;
-(IBAction)nextButtonPressed:(id)sender;
-(IBAction)manualAutomaticSwitchPressed:(id)sender;

@end

