//
//  EndToEndTest.h
//  SwitchList
//
//  Created by bowdidge on 7/27/14.
//
//

#import "LayoutTest.h"
#import <CoreData/NSPersistentStore.h>

// Test harness for doing end-to-end checks that the sample layouts can advance correctly,
// and that switchlists can render correctly.
// This is an abstract superclass; the subclasses should set layoutFileName_ and write a test that calls
// doTestLayout.
@interface EndToEndTest : LayoutTest {
    // Prefix only.
    NSString* layoutFileName_;
}
- (void) doTestLayout;
@end
