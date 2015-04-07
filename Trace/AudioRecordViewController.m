//
//  AudioRecordViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/11.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "AudioRecordViewController.h"
#import "AppDelegate.h"


@implementation AudioRecordViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.updatedRecording = NO;
    
    // AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // appDelegate.numberOfAudio++;
    // appDelegate.numberOfAudio = 1;      // just use the one file
    
    // Use a single temporary file for recording
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *fileBase = @"rec.mp4";    // @"rec.caf";
    NSString *tempFilepath = [documentDir stringByAppendingPathComponent:fileBase];
    self.tempRecordingUrl = [NSURL fileURLWithPath:tempFilepath];
    
    if ([self.annotationEdit audioData] == nil) {
        [self.playButton setHidden:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self recordStop:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Record

//  m4a, kAudioFormatMPEGLayer3 is supported on both Android and iOS
//  http://stackoverflow.com/questions/10549023/iphone-app-recording-audio-in-mp3
//
//
- (IBAction)recStart:(id)sender
{    
    // AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    // 使用している機種が録音に対応しているか
    if ([audioSession isInputAvailable]) {
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    }
    if(error){
        NSLog(@"audioSession: %@ %lu %@", [error domain], (long)[error code], [[error userInfo] description]);
    }
    // 録音機能をアクティブにする
    [audioSession setActive:YES error:&error];
    if(error){
        NSLog(@"audioSession: %@ %lu %@", [error domain], (long)[error code], [[error userInfo] description]);
    }
        
    /*
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *fileBase = @"rec.caf";
    NSString *fileNumb = [NSString stringWithFormat:@"%lu", (long)appDelegate.numberOfAudio];
    NSString *path = [documentDir stringByAppendingPathComponent:[fileNumb stringByAppendingString:fileBase]];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
     */
    
    
     
     NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                               [NSNumber numberWithFloat:16000.0],AVSampleRateKey,
                               [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                               [NSNumber numberWithInt: 32000], AVEncoderBitRateKey,
                               [NSNumber numberWithInt:AVAudioQualityMin],AVEncoderAudioQualityKey,
                               nil];
    /*
        [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
        [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
        [NSNumber numberWithInt: 8], AVLinearPCMBitDepthKey,
        [NSNumber numberWithInt:16], AVEncoderBitRateKey,
        [NSNumber numberWithFloat: 16000.0], AVSampleRateKey,
        [NSNumber numberWithInt: AVAudioQualityMedium], AVEncoderAudioQualityKey,
        nil]; */
    /*
     [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
     nil];
     */
     
    avRecorder = [[AVAudioRecorder alloc] initWithURL:self.tempRecordingUrl
                                              settings:settings
                                                 error:&error];
    
    
    // 録音中に音量をとる場合はYES
    //    AvRecorder.meteringEnabled = YES;
    // avRecorder = [[AVAudioRecorder alloc] initWithURL:self.tempRecordingUrl settings:nil error:&error];
    
    if ([avRecorder prepareToRecord])
    {
        [self.playButton setHidden:YES];
        
        avRecorder.delegate=self;
        [avRecorder record];
        [self startUserTimer];
    }
    else
    {
        NSLog(@"error = %@",error);
        return;
    }
}

// 録音が終わったら呼ばれるメソッド

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    /*
     NSURL *recordingURL = recorder.url;
     player = [[AVAudioPlayer alloc]initWithContentsOfURL:recordingURL error:nil];
     player.delegate = self;
     //    player.volume=1.0;
     [player play];
     */
}

- (IBAction)recordStop:(id)sender
{
    self.updatedRecording = YES;        // save on exit
    
    [self stopUserTimer];
    
    if ([avRecorder isRecording]) {
        [avRecorder stop];
        [self.playButton setHidden:NO];
    }
    if ([avPlayer isPlaying]) {
        [avPlayer stop];
        [self.recordStartButton setHidden:NO];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
}

#pragma mark -

-(void) startUserTimer
{
    [self updateTimerDisplay];
    self.updateUserTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                            target:self
                                                          selector:@selector(updateTimerDisplay)
                                                          userInfo:nil
                                                           repeats:YES];
}

-(void) showTimeInSecs:(NSTimeInterval)showTime
{
    NSInteger mins;
    NSInteger secs;
    NSString *timeStr;
    
    if (showTime >= 0)
    {
        mins = showTime / 60;
        secs = showTime - (mins * 60);
        timeStr = [NSString stringWithFormat:@"%02li:%02li", (long) mins, (long) secs];
        [self.mTimerLabel setText:timeStr];
    }
    else
    {
        [self.mTimerLabel setText:@"-:-"];
    }
}

// From recording timer
//
-(void) updateTimerDisplay
{
    NSTimeInterval curTime;
    
    
    if ((avRecorder) && (avRecorder.isRecording))
    {
        curTime = [avRecorder currentTime];
        [self showTimeInSecs:curTime];
    }
    else if ((avPlayer) && (avPlayer.playing))
    {
        curTime = [avPlayer currentTime];
        [self showTimeInSecs:curTime];
    }
    else {
        [self showTimeInSecs:0];
    }
}

-(void) stopUserTimer
{
    if (self.updateUserTimer)
    {
        [self.updateUserTimer invalidate];
        self.updateUserTimer = nil;
    }
}

#pragma mark - Play

- (IBAction)play:(id)sender
{
    // AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    // AVAudioSessionCategoryAmbient will be silent if the Silent switch set to silent
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    /*
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *fileBase = @"rec.caf";
    NSString *fileNumb = [NSString stringWithFormat:@"%ld", (long)appDelegate.numberOfAudio];
    NSString *path = [documentDir stringByAppendingPathComponent:[fileNumb stringByAppendingString:fileBase]];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    */
    NSError *error = nil;
    if (self.updatedRecording)
    {
        avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.tempRecordingUrl
                                                   fileTypeHint:AVFileTypeMPEG4
                                                          error:&error];
    }
    else
    {
        avPlayer = [[AVAudioPlayer alloc] initWithData:self.annotationEdit.audioData error:&error];
    }
    avPlayer.delegate = self;
    avPlayer.volume=1.0;
    if ([avPlayer prepareToPlay])
    {
        [avPlayer play];
        [self startUserTimer];
        [self.recordStartButton setHidden:YES];
    }
    else {
        NSLog(@"AudioRecordViewController play error: %@", [error description]);
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //    [player release];
    
    [self stopUserTimer];
    [self.recordStartButton setHidden:NO];
}

#pragma mark -

- (IBAction)onSave:(UIBarButtonItem *)sender
{
    /*
    // NSLog(@"attached");
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.audioAnnotation addObject:[NSNumber numberWithInteger:appDelegate.numberOfAnnotation]];
    */
    
    if (self.updatedRecording)
    {
        NSString *filePath = [self.tempRecordingUrl path];
        self.annotationEdit.audioData = [NSData dataWithContentsOfFile:filePath];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onCancel:(UIBarButtonItem *)sender
{
    /* NSLog(@"calceled");
    
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *fileBase = @"rec.caf";
    NSString *fileNumb = [NSString stringWithFormat:@"%ld", (long)appDelegate.numberOfAudio];
    NSString *path = [documentDir stringByAppendingPathComponent:[fileNumb stringByAppendingString:fileBase]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager removeItemAtPath:path error:nil]) {
        NSLog(@">> Error <<");
    }
    
    appDelegate.numberOfAudio--;
    */
    
    // It would not hurt to delete the single temporary file...
    
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil]; 
}



@end