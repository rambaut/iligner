//
//  KDTextView.h
//  LineNumbering
//
//  Created by Koen van der Drift on Sat May 01 2004.
//  Copyright (c) 2004 Koen van der Drift. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KDTextView : NSTextView
{
    BOOL                drawNumbersInMargin;
    BOOL                drawLineNumbers;
	BOOL				drawOverlay;
    NSMutableDictionary *marginAttributes;
	NSMutableDictionary *selectionAttributes;
	
	NSString *unit;
}

-(void)initLineMargin:(NSRect)frame;

- (BOOL)drawNumbersInMargin;
- (void)setDrawNumbersInMargin:(BOOL)newDrawNumbersInMargin;

- (BOOL)drawLineNumbers;
- (void)setDrawLineNumbers:(BOOL)newDrawLineNumbers;

- (BOOL)drawOverlay;
- (void)setDrawOverlay:(BOOL)newDrawOverlay;

- (NSString *)unit;
- (void)setUnit:(NSString *)newUnit;

-(void)updateMargin;
-(void)updateLayout;

-(void)drawEmptyMargin:(NSRect)aRect;
-(void)drawNumbersInMargin:(NSRect)aRect;
-(void)drawOneNumberInMargin:(unsigned) aNumber inRect:(NSRect)aRect;
-(void)drawSelectionOverlayInTextview: (NSRect)rect;
-(void)drawOverlayInTextview: (NSRect)rect;

-(NSRect)marginRect;



@end
