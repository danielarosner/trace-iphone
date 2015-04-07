//
//  DurationPickerViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/08/01.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "DurationPickerViewController.h"
#import "AppDelegate.h"
#import "MapViewController.h"


@implementation DurationPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pickedDuration = 40;        // default duration
    
	picker = [[UIPickerView alloc] init];
    picker.frame = CGRectMake(0, 600, 320, 216);
    picker.showsSelectionIndicator = YES;
    picker.delegate = self;
    picker.dataSource = self;
    [picker selectRow:3 inComponent:0 animated:NO];     // zero indexed
    [self.view addSubview:picker];
    
    _textField.delegate = self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self showPicker];
    return NO;
}

- (void)showPicker {
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	picker.frame = CGRectMake(0, 280, 320, 216);
	[UIView commitAnimations];
    
	if (!self.navigationItem.rightBarButtonItem) {
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [self.navigationItem setRightBarButtonItem:done animated:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidePicker];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)done:(id)sender {
	[self hidePicker];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)hidePicker {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	picker.frame = CGRectMake(0, 600, 320, 216);
	[UIView commitAnimations];
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return(kNumberOfDurationPoints);
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [NSString stringWithFormat:@"%lu mins", (unsigned long)(10+row*10)];
            break;
            
        default:
            return 0;
            break;
    }
}
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    _textField.text = [NSString stringWithFormat:@"%lu mins", (unsigned long)(10 + row*10)];
    pickedDuration = row * 10 + 10;
    
    [self hidePicker];
    // pickerView.hidden = YES;
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

 #pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"WalkTrace"])
     {
         MapViewController *mapView = (MapViewController *) [segue destinationViewController];
         [mapView setTracesMgr:self.tracesMgr];
         [mapView setTraceIndex:self.traceIndex];
         [mapView setWalkDuration: pickedDuration];
     }
 }

@end
     
