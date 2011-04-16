//
//  BaseSwitchListView.m
//  SwitchList
//
//  Created by bowdidge on 2/3/11.
//  Copyright 2011 Robert Bowdidge. All rights reserved.
//

#import "BaseSwitchListView.h"


@implementation BaseSwitchListView
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSObject<SwitchListDocumentInterface>*) document {
	[super initWithFrame: frameRect];
	owningDocument_ = [document retain];
	bluePenColor_ = [[NSColor colorWithDeviceRed:0.0 green: 0.0 blue: 0.4 alpha: 1.0] retain];
	
	// TODO(bowdidge): Why the alternate font?  How much does the alternate font mess layout up?
	handwritingFont_ =  [NSFont fontWithName: @"Handwriting - Dakota" size: 18];
	if (handwritingFont_ == nil) {
		handwritingFont_ =  [NSFont fontWithName: @"Chalkboard" size: 18];
	}
	
	return self;
}

- (void) dealloc {
	[owningDocument_ release];
	[bluePenColor_ release];
	[super dealloc];
}
// Routines for drawing the text.  We're doing this by hand (rather than with a special text widget) so
// we need to do placement, etc. by hand.
- (void) drawCenteredString: (NSString *) str centerY: (float) centerY centerX: (float) centerPos attributes: attrs {
	NSSize stringSize = [str sizeWithAttributes: attrs];
	
	[str drawInRect: NSMakeRect(centerPos-stringSize.width/2 , centerY-stringSize.height/2, stringSize.width, stringSize.height)
	 withAttributes: attrs];
}
- (NSFont*) titleFontForSize: (float) sz {
	NSFont *font = [NSFont fontWithName: @"Egyptian" size: sz];
	if (font == nil) {
		font = [NSFont fontWithName: @"Copperplate" size: sz];
	}
	return font;
}
@end
