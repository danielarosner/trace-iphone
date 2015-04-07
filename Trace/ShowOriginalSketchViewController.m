//
//  ShowOriginalSketchViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/25.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "ShowOriginalSketchViewController.h"
#import "AppDelegate.h"

@interface ShowOriginalSketchViewController ()

@end

@implementation ShowOriginalSketchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    // NSLog(@"%f",appDelegate.traceDownloaded.size.height);

    if (self.traceData)
    {
        self.canvas.image = [self.traceData image];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
