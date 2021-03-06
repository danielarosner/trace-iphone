//
//  KMZCanvasView.h
//  KMZDraw
//
//  Created by Kentaro Matsumae on 12/06/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMZFrame.h"

@class KMZDrawView;

@protocol KMZDrawViewDelegate
- (void)drawView:(KMZDrawView*)drawView finishDrawLine:(KMZLine*)line;
@end

@interface KMZDrawView : UIImageView

@property (nonatomic, weak) id<KMZDrawViewDelegate> delegate;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic, strong) KMZFrame* currentFrame;
@property (nonatomic, strong) KMZLine* currentLine;

@property KMZLinePenMode penMode;
@property NSUInteger penWidth;
@property (nonatomic, strong) UIColor* penColor;

@property (nonatomic) CGPoint referencePoint;

@property (strong, retain) NSMutableArray* latitudes;
@property (strong, retain) NSMutableArray* longitudes;

@property NSUserDefaults* defaults;
@property NSData* data;



- (void)undo;
- (void)redo;
- (void)save;
- (BOOL)isUndoable;
- (BOOL)isRedoable;
- (BOOL)isSaveEnabled;

@end
