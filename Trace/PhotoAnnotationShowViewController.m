//
//  PhotoAnnotationShowViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/24.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "PhotoAnnotationShowViewController.h"

@interface PhotoAnnotationShowViewController (){
    NSData *photoData;
}

@end

@implementation PhotoAnnotationShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.annotation)
    {
        self.imageView.image = self.annotation.image;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
