//
//  PasteboardHelpers.h
//  SwitchList
//
//  Created by bowdidge on 1/21/15.
//
// Copyright (c)2015 Robert Bowdidge,
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.

#import <Cocoa/Cocoa.h>

#import "Cargo.h"
#import "FreightCar.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "Yard.h"

// Extensions to model classes to allow cut and paste on MacOS.

@interface Cargo (Pasteboard)<NSPasteboardWriting,NSPasteboardReading>
@end

@interface FreightCar (Pasteboard)<NSPasteboardWriting,NSPasteboardReading>
@end

@interface Industry (Pasteboard)<NSPasteboardWriting,NSPasteboardReading>
@end

@interface Place (Pasteboard)<NSPasteboardWriting,NSPasteboardReading>
@end

@interface ScheduledTrain (Pasteboard)<NSPasteboardWriting,NSPasteboardReading>
@end

@interface Yard (Pasteboard)<NSPasteboardWriting,NSPasteboardReading>
@end