//
//  StringHelpers.m
//  SwitchList
//
//  Created by bowdidge on 3/6/11.
//
// Copyright (c)2011 Robert Bowdidge,
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

#import "StringHelpers.h"

@implementation NSString (StringHelpers)

-(NSString*)stringByNormalizingCharacterInSet:(NSCharacterSet*)characterSet
                                   withString:(NSString*)replacement {
	NSMutableString* result = [NSMutableString string];
	NSScanner* scanner = [NSScanner scannerWithString:self];
	BOOL atStart = true;
	while (![scanner isAtEnd]) {
		if (atStart == true) {
			atStart = false;
		} else {
			[result appendString: replacement];
		}
		NSString* stringPart = nil;
		if ([scanner scanUpToCharactersFromSet:characterSet intoString:&stringPart]) {
			[result appendString:stringPart];
		}
	}
	return [[result copy] autorelease];
}

- (NSString*) sqlSanitizedString {
	return [self stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"];
}

// Returns the number of times the string appears in the larger string.
- (int) occurrencesOfString: (NSString*) substring {
	// TODO(bowdidge): Implement more efficiently.
	if ([substring length] == 0) {
		return 0;
	}
	int oldLength = (int) [self length];
	NSString *substringRemoved = [self stringByReplacingOccurrencesOfString: substring withString: @""];
	int newLength = (int) [substringRemoved length];
	return (oldLength - newLength) / [substring length];
}
@end
