//
//  AudioRecordViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/11.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AnnotationData.h"

@interface AudioRecordViewController : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *avRecorder;
    AVAudioPlayer *avPlayer;
}

@property (weak, nonatomic) AnnotationData *annotationEdit;
@property (strong, nonatomic) NSURL *tempRecordingUrl;
@property (assign) Boolean updatedRecording;

@property (weak, nonatomic) IBOutlet UIButton *recordStartButton;
@property (weak, nonatomic) IBOutlet UIButton *recordStopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *attachButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) NSTimer *updateUserTimer;
@property (weak, nonatomic) IBOutlet UILabel *mTimerLabel;

- (IBAction)recStart:(id)sender;
- (IBAction)recordStop:(id)sender;
- (IBAction)play:(id)sender;

@end
