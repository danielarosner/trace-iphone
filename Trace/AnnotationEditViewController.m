//
//  AnnotationEditViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/30.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import "AnnotationEditViewController.h"
#import "AnnotatingViewController.h"
#import "AppDelegate.h"
#import "AudioRecordViewController.h"


@implementation AnnotationEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // library = [[ALAssetsLibrary alloc]init];
    
    // to handle Cancel, make a copy and make changes there
    self.annotationEdit = [self.annotationMaster copy];
    
    self.textView.text = [self.annotationEdit text];
    
    [self.navigationController.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
    
    // printf("%d\n", self.heldString.length);
    /* AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.held4TextView.length > 0) {
        self.textView.text = [self.textView.text stringByAppendingString:appDelegate.held4TextView];
    }
    if (appDelegate.textAnnotation.length==0) {
        appDelegate.textAnnotation = [NSMutableString string];
    }
    
    self.textView.delegate = self;
    // [「改行（Return）」キーの設定]
    self.textView.returnKeyType = UIReturnKeyDone;
    */
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateButtonAndImage];
}


-(void) updateButtonAndImage
{
    if ([self.annotationEdit image])
    {
        self.attachedImage.image = [self.annotationEdit image];
        [self.removeImageButton setHidden:NO];
    }
    else
    {
        self.attachedImage.image = nil;
        [self.removeImageButton setHidden:YES];
    }
    
    if ([self.annotationEdit audioData]) {
        [self.deleteRecordingButton setHidden:NO];
    }
    else {
        [self.deleteRecordingButton setHidden:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (IBAction)mediaAttachPressed:(id)sender{
    
    UIActionSheet *sheet =[[UIActionSheet alloc]
                           initWithTitle:@"Media Upload"
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Camera", @"Audio", @"Photo Album", nil];
    
    [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [sheet showInView:self.view];
    
    //    [sheet release];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self showUIImagePicker: UIImagePickerControllerSourceTypeCamera];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"Audio" sender:nil];
            break;
            
        case 2:
            [self showUIImagePicker: UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}


- (void)showUIImagePicker: (UIImagePickerControllerSourceType) sourceType
{
    if (![UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = NO;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)targetImage:(UIImage *)image
didFinishSavingWithError:(NSError *)error
        contextInfo:(void *)context
{
    if (error) {
        
    } else {
        
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    /*
    AppDelegate *appDelegate  = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(targetImage:didFinishSavingWithError:contextInfo:), NULL);
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1f);
    NSUserDefaults *aDefault=[NSUserDefaults standardUserDefaults];
    appDelegate.numberOfPhoto++;
    NSString *nBase = @"photo";
    NSString *nNumb = [NSString stringWithFormat:@"%lu", (long) appDelegate.numberOfPhoto];
    [aDefault setObject:imageData forKey:[nBase stringByAppendingString:nNumb]];
    [aDefault synchronize];
    
    // will update in viewWillAppear now  self.attachedImage.image = image;
     */
    
    [self.annotationEdit setImage:image];
    
    [self updateButtonAndImage];            // iOS 7
    
    // NSLog(@"%ld", imageData.length);
    // NSLog(@"%ld", appDelegate.photoAnnotation);
    // [appDelegate.photoAnnotation addObject:[NSNumber numberWithInt: (int)appDelegate.numberOfAnnotation]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Audio"])
    {
        AudioRecordViewController *audioView = (AudioRecordViewController *) segue.destinationViewController;
        [audioView setAnnotationEdit: self.annotationEdit];
    }
}

- (IBAction)onCancel:(UIBarButtonItem *)sender
{
    // Revert back to annotation without any text/audio/image changes.
    // So just leave because all edits have been on annotationEdit
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSave:(UIBarButtonItem *)sender
{
    // Save the changed data back to original Annotation
    //
    [self.annotationMaster deepCopyFrom: self.annotationEdit];
    [self.annotationMaster setText:self.textView.text];
    
    NSUInteger annoIndex = [self.traceData.annotations indexOfObject: self.annotationMaster];
    if (annoIndex == NSNotFound)
    {
        // *** Add this annotation (an update should already be in traceData.annotations ) ***
        [self.traceData.annotations addObject:self.annotationMaster];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onRemoveImage:(UIButton *)sender
{
    [self.annotationEdit setImage:nil];
    [self.attachedImage setImage:nil];
    [self.removeImageButton setHidden:YES];
}


- (IBAction)onDeleteRecording:(UIButton *)sender
{
    [self.annotationEdit setAudioData:nil];
    [self.deleteRecordingButton setHidden:YES];
    
    // [self performSegueWithIdentifier:@"Audio" sender:self];
}

@end
