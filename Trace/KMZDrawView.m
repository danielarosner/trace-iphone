//
//  KMZCanvasView.m
//  KMZDraw
//
//  Created by Kentaro Matsumae on 12/06/09.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KMZDrawView.h"

@implementation KMZDrawView

@synthesize delegate;

@synthesize lastPoint;
@synthesize currentFrame;
@synthesize currentLine;

@synthesize penMode;
@synthesize penWidth;
@synthesize penColor;

@synthesize referencePoint;

@synthesize latitudes;
@synthesize longitudes;


- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self _setupWithFrame:self.frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupWithFrame:frame];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.currentFrame = nil;
    self.currentLine = nil;
    
}

#pragma mark private functions

- (void)_setupWithFrame:(CGRect)frame {
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;

    self.currentFrame = [[KMZFrame alloc] initWithSize:frame.size];
    self.penMode = KMZLinePenModePencil;
    self.penWidth = 2;
    self.penColor = [UIColor blackColor];
    self.latitudes = [NSMutableArray array];
    self.longitudes = [NSMutableArray array];
    self.defaults = [NSUserDefaults standardUserDefaults];
}

#pragma mark UIResponder

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if (self.currentFrame.lineCursor < 1) {
        printf("yes\n");
    
        CGPoint pt = [[touches anyObject] locationInView:self];
        self.lastPoint = pt;
        referencePoint = pt;
    
        CGMutablePathRef path = CGPathCreateMutable();
        self.currentLine = [[KMZLine alloc] initWithPenMode:self.penMode width:self.penWidth color:self.penColor path:path];
    
        [self.currentFrame addLine:currentLine];
    
        [currentLine moveToPoint:pt];
        [self.latitudes addObject:[NSNumber numberWithFloat:pt.y]];
        [self.longitudes addObject:[NSNumber numberWithFloat:pt.x]];
    }else{
        self.currentFrame.lineCursor = 1;
    }
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.currentLine) {
		return;
	}
	
    
    if (self.currentFrame.lineCursor < 2) {
        CGPoint pt = [[touches anyObject] locationInView:self];
   
        [self.currentLine addLineToPoint:pt];
	
        UIGraphicsBeginImageContext(self.frame.size);
        [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextRef context = UIGraphicsGetCurrentContext();
        [currentFrame drawLine:context line:currentLine beginPoint:self.lastPoint endPoint:pt];
        float dist = sqrt ((self.referencePoint.x - pt.x) * (self.referencePoint.x - pt.x) + (self.referencePoint.y - pt.y) * (self.referencePoint.y - pt.y) );
    
        if (dist > 20) {
            self.referencePoint = self.lastPoint;
            [self.latitudes addObject:[NSNumber numberWithFloat:pt.y]];
            [self.longitudes addObject:[NSNumber numberWithFloat:pt.x]];
        }
    
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.lastPoint = pt;
    }else{
        self.currentFrame.lineCursor = 1;
    }
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
	if (!self.currentLine) {
		return;
	}
	
    if (self.currentFrame.lineCursor < 2) {
        
        CGPoint pt = [[touches anyObject] locationInView:self];
    
        [self.currentLine addLineToPoint:pt];
	
        UIGraphicsBeginImageContext(self.frame.size);
        [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextRef context = UIGraphicsGetCurrentContext();
        [currentFrame drawLine:context line:self.currentLine beginPoint:self.lastPoint endPoint:pt];
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
	
        self.currentFrame.image = self.image;
    
        [self.delegate drawView:self finishDrawLine:currentLine];
        self.currentLine = nil;
        [self.latitudes addObject:[NSNumber numberWithFloat:pt.y]];
        [self.longitudes addObject:[NSNumber numberWithFloat:pt.x]];
    
        // printf("%f\n", [[self.latitudes objectAtIndex:0] floatValue]);
        // printf("%d\n", [self.latitudes count]);
        // printf("%d\n", self.currentFrame.lineCursor);
        
        //[self.latitudes removeAllObjects];
    }else{
        self.currentFrame.lineCursor = 1;
    }
}

#pragma mark public function

- (void)undo {
    [self.currentFrame undo];
    self.image = self.currentFrame.image;
    self.currentLine = nil;
    [self.latitudes removeAllObjects];
    [self.longitudes removeAllObjects];
    [self setNeedsDisplay];
}

- (void)redo {
    [self.currentFrame redo];
    self.image = self.currentFrame.image;
    self.currentLine = nil;
    [self setNeedsDisplay];
}

- (void)save {
    [self.currentFrame save];
    self.image = self.currentFrame.image;
    self.currentLine = nil;
    [self setNeedsDisplay];
    
    self.data = [NSKeyedArchiver archivedDataWithRootObject:self.latitudes];
    [self.defaults setObject:self.data forKey:@"temp_latitudes"];
    
    BOOL successful = [self.defaults synchronize];
    
    for (int i=0; i<[self.latitudes count]; i++)
    {
        printf("%f, ", [[self.latitudes objectAtIndex:i] floatValue]);
    }
    // printf("%d\n", [self.latitudes count]);
    printf("\n");
    for (int i=0; i<[self.longitudes count]; i++) {
        printf("%f, ", [[self.longitudes objectAtIndex:i] floatValue]);
    }
    printf("\n");
    // printf("%d\n", [self.longitudes count]);
    if (successful) printf("SAVED!\n");
    
}


- (BOOL)isUndoable {
    return [self.currentFrame isUndoable];
}

- (BOOL)isRedoable {
    return [self.currentFrame isRedoable];
}

- (BOOL)isSaveEnabled {
    return [self.currentFrame isSaveEnabled];
}

@end
