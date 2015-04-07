//
//  AnnotationEditViewController.h
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/30.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TraceData.h"

@interface AnnotationEditViewController : UIViewController <UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) TraceData *traceData;
@property (weak, nonatomic) AnnotationData *annotationMaster;
@property (strong, nonatomic) AnnotationData *annotationEdit;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImage;
@property (weak, nonatomic) IBOutlet UIButton *deleteRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *removeImageButton;

// @property (nonatomic, strong) NSMutableArray *storeAnnotation_x;
// @property (nonatomic, strong) NSMutableArray *storeAnnotation_y;

- (IBAction)mediaAttachPressed:(id)sender;

@end
