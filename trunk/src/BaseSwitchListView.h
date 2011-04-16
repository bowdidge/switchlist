//
//  BaseSwitchListView.h
//  SwitchList
//
//  Created by bowdidge on 2/3/11.
//  Copyright 2011 Robert Bowdidge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SwitchListDocumentInterface.h"

@interface BaseSwitchListView : NSView {
	NSObject<SwitchListDocumentInterface> *owningDocument_;
	NSColor *bluePenColor_;
	NSFont *handwritingFont_;
}
- (id) initWithFrame: (NSRect) frameRect withDocument: (NSObject<SwitchListDocumentInterface>*) document;
- (void) drawCenteredString: (NSString*) str centerY: (float) centerY centerX: (float) centerPos attributes: (id) attrs ;
- (NSFont*) titleFontForSize: (float) sz ;
@end
