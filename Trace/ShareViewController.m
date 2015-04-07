

//
//  ShareViewController.m
//  TRACE_v1
//
//  Created by Hidekazu Saegusa on 2014/07/29.
//  Copyright (c) 2014年 University of Washington. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "ShareViewController.h"
#import "AppDelegate.h"
#import "TracesMgr.h"

@interface ShareViewController (){
    PFObject *testObject;
    PFObject *audioObject;
    PFObject *photoObject;
    PFObject *recipientObject;      // STC
}

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[self.traceData traceTitle] length] > 0) {
        self.traceTitle.text = [self.traceData traceTitle];
    }
    
    if ([[self.traceData traceDescription] length] > 0) {
        self.traceDescription.text = [self.traceData traceDescription];
    }
    
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"TestObject_2"];
    query.limit = 500;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.temporaryArray = objects;
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    / *STC
     
     PFQuery *query_users = [PFQuery queryWithClassName:@"UsersList"];
     self.userLs = [query_users findObjects];
     // NSLog(@"%d",self.userLs.count);
     NSString *groupName = NULL;
     for (int i=0; i<self.userLs.count; i++) {
     if([[self.userLs[i] valueForKey:@"UDID"] isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]){
     groupName = [self.userLs[i] valueForKey:@"GroupName"];
     }
     }
     if (groupName!=NULL) {
     NSString *listOfUsers = @"To: ";
     for (int i=0; i<self.userLs.count; i++) {
     if ([[self.userLs[i] valueForKey:@"GroupName"] isEqualToString:groupName]) {
     if([[self.userLs[i] valueForKey:@"UDID"] isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]) {
     }else{
     listOfUsers = [listOfUsers stringByAppendingString:[self.userLs[i] valueForKey:@"Name"]];
     listOfUsers = [listOfUsers stringByAppendingString:@", "];
     }
     }
     }
     self.listofusers.text = listOfUsers;
     }else{
     self.listofusers.text = @"register with your name!";
     }
     * /
    
    testObject  = [PFObject objectWithClassName:@"TestObject_2"];
    audioObject = [PFObject objectWithClassName:@"audioObject" ];
    photoObject = [PFObject objectWithClassName:@"photoObject" ];
    
    PFACL *defaultACL = [PFACL ACLWithUser:[PFUser currentUser]];
    // [defaultACL set]
    [defaultACL setPublicWriteAccess:YES];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    audioObject.ACL = defaultACL;
    photoObject.ACL = defaultACL;
    testObject.ACL  = defaultACL;
    
    [audioObject.ACL setPublicReadAccess:YES];
    [photoObject.ACL setPublicReadAccess:YES];
    [testObject.ACL  setPublicReadAccess:YES];
    */
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *usersInfoStr;
    NSUInteger usersCnt = [self.traceUsers count] + [self.unmatchedEmails count];
    if (usersCnt == 1)
    {
        usersInfoStr = NSLocalizedString(@"Users_SingleUserInfo", nil);
    }
    else
    {
        usersInfoStr = [NSString
                        stringWithFormat:NSLocalizedString(@"Users_CountInfo", nil), usersCnt];
    }
    self.recipientsSummaryLabel.text = usersInfoStr;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveButtonPressed:(id)sender
{
    Boolean okToSave = YES;
    NSString *errMsg = nil;
    
    if ([self.traceTitle.text length] <= 0)
    {
        okToSave = NO;
        errMsg = NSLocalizedString(@"ShareTrace_MissingTitle", nil);
    }
    else if ([self.traceDescription.text length] <= 0)
    {
        okToSave = NO;
        errMsg = NSLocalizedString(@"ShareTrace_MissingDescription", nil);
    }
    else
    {
        NSUInteger usersCnt = [self.traceUsers count] + [self.unmatchedEmails count];
        if (usersCnt <= 0)
        {
            okToSave = NO;
            errMsg = NSLocalizedString(@"ShareTrace_RecipientsNotFound", nil);
        }
    }
    
    if (okToSave) {
        self.traceData.traceTitle = self.traceTitle.text;
        self.traceData.traceDescription = self.traceDescription.text;
        [self saveAllObjects];      // <----
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:errMsg
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
}

/*
- (void) callbackForDrawingSave:(NSNumber *)result error:(NSError *)error
{
    if ([result boolValue])
    {
        NSLog(@"Drawing saved");
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        // can call saveEventually
        
        if ([error code] == kPFErrorConnectionFailed) {
            NSLog(@"ShareViewController save drawing Error: Couldn't even connect to the Parse Cloud!");
        } else if (error) {
            NSLog(@"ShareViewController save drawing Error: %@", [error userInfo][@"error"]);
        }
    }
    
    [self.activityIndicator stopAnimating];
}
*/

- (void)saveAllObjects
{
    PFObject *drawingObject = [TracesMgr buildDrawingForUpload:self.traceData
                                                            to:self.traceUsers];
    NSArray *unmatchedEmailPFObjects = [TracesMgr buildArrayOfUnmatchedEmails: [self unmatchedEmails]
                                                                     linkedTo:drawingObject];

    // [drawingObject saveInBackgroundWithTarget:self selector:@selector(callbackForDrawingSave: error:)];

    __weak ShareViewController *weakSelf = self;
    [drawingObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        if (succeeded)
        {
            NSLog(@"Drawing saved");
            
            if (unmatchedEmailPFObjects)
            {
                [PFObject saveAllInBackground:unmatchedEmailPFObjects
                                        block:^(BOOL succeeded, NSError *error)
                {
                    if (succeeded)
                    {
                        NSInteger cnt = [unmatchedEmailPFObjects count];
                        NSLog(@"%i unmatched emails saved.", (int)cnt);
                    }
                    else
                    {
                        NSLog(@"ShareViewController saving unmatched emails Error: %@", [error userInfo][@"error"]);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    });
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                });
            }
        }
        else {
            // can call saveEventually
            
            if ([error code] == kPFErrorConnectionFailed) {
                NSLog(@"ShareViewController save drawing Error: Couldn't even connect to the Parse Cloud!");
            } else if (error) {
                NSLog(@"ShareViewController save drawing Error: %@", [error userInfo][@"error"]);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[weakSelf activityIndicator] stopAnimating];
                
                NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"ShareTrace_Error", nil), [error.userInfo objectForKey:@"error"]];
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                            message:errMsg
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            });
        }
    }];
     
    [self.activityIndicator startAnimating];
    
    /*
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // NSDate *date = [NSDate date];
    
    testObject[@"trace_x"] = appDelegate.tracePoints_x;
    testObject[@"trace_y"] = appDelegate.tracePoints_y;
    testObject[@"trace_d"] = appDelegate.totalDistance;
    testObject[@"trace_title"] = self.traceTitle.text;
    testObject[@"trace_description"] = self.traceDescription.text;
    testObject[@"annot_x"] = appDelegate.annotationPoints_x;
    testObject[@"annot_y"] = appDelegate.annotationPoints_y;
    testObject[@"annot_t"] = appDelegate.textAnnotation;
    testObject[@"annot_i"] = appDelegate.textIndex;
    // printf("%f\n", appDelegate.image.size.width);
    
    //testObject[@"timestamp"] = date;
    NSDate* date = [NSDate date];
    testObject[@"timestamp"] = date;
    
    testObject[@"UDID"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    // Add User who created this record - 2/4/15 STC
    PFUser *currentUser = [PFUser currentUser];
    testObject[@"createdBy"] = currentUser;
    
    testObject[@"audio_annotation"] = appDelegate.audioAnnotation;
    testObject[@"photo_annotation"] = appDelegate.photoAnnotation;
    
    NSData* data = UIImageJPEGRepresentation(appDelegate.image, 0.5f);
    testObject[@"traceImage"] = data;
    
    / *
    PFFile *imageFile = [PFFile fileWithName:@"traceImage.jpg" data:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [testObject setObject:imageFile forKey:@"image"];
            [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Saved");
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
    * /
    
    for (int i=0; i<appDelegate.audioAnnotation.count; i++) {
        
        NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filenamehead = @"rec.caf";
        NSString *numant = [NSString stringWithFormat:@"%d", i+1];
        // NSString *path = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",numant,filenamehead]];
        NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",numant,filenamehead]];
        // NSURL *url = [NSURL fileURLWithPath:filePath];
        NSData *audioData = [NSData dataWithContentsOfFile:filePath];
        PFFile *audioFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@%@",numant,filenamehead] data:audioData];
        audioObject[[NSString stringWithFormat:@"%@%@",@"audioFile",numant]] = audioFile;
    }
    audioObject[@"audioFilesNumber"] = [NSString stringWithFormat:@"%lu", (unsigned long)self.temporaryArray.count];
    
    
    for (int i=0; i<appDelegate.photoAnnotation.count; i++) {
        NSUserDefaults *aDefault = [NSUserDefaults standardUserDefaults];
        NSString *nBase = @"photo";
        NSString *nNumb = [NSString stringWithFormat:@"%d", i+1];
        NSData *photo = [aDefault objectForKey:[nBase stringByAppendingString:nNumb]];
        PFFile *imageFile = [PFFile fileWithName:[nNumb stringByAppendingString:@"image.jpg"] data:photo];
        photoObject[[NSString stringWithFormat:@"%@%@",@"photoFile",nNumb]] = imageFile;
    }
    photoObject[@"photoFilesNumber"] = [NSString stringWithFormat:@"%lu", (unsigned long)self.temporaryArray.count];
    
    
    
    [testObject  save];
    [audioObject save];
    [photoObject save];
    
    
    
    for (int i=0; i<appDelegate.audioAnnotation.count; i++) {
        
        NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filenamehead = @"rec.caf";
        NSString *numant = [NSString stringWithFormat:@"%d", i+1];
        // NSString *path = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",numant,filenamehead]];
        NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",numant,filenamehead]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager removeItemAtPath:filePath error:nil]) {
            NSLog(@">> Error <<");
        }
    }
    
    for (int i=0; i<appDelegate.photoAnnotation.count; i++) {
        NSUserDefaults *aDefault = [NSUserDefaults standardUserDefaults];
        NSString *nBase = @"photo";
        NSString *nNumb = [NSString stringWithFormat:@"%d", i+1];
        [aDefault removeObjectForKey:[nBase stringByAppendingString:nNumb]];
    }
    */
}

/*
- (void)waitUntilDone
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    float w = indicator.frame.size.width;
    float h = indicator.frame.size.height;
    float x = self.view.frame.size.width/2 - w/2;
    float y = self.view.frame.size.height/2 - h/2;
    indicator.frame = CGRectMake(x, y, w, h);
    
    [indicator startAnimating];
    [self.view addSubview:indicator];
    float time = 2.0 + appDelegate.audioAnnotation.count*1.5 + appDelegate.photoAnnotation.count*2.0;
    [NSThread sleepForTimeInterval:time];
}
*/

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
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
