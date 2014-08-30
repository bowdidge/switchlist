//
//  main.m
//  generate_classifier_file
//
// Given an XML file describing common industries and cargos, generate a BKClassifier training file to convert industry
// names into likely category of business.
//
// Copyright (c)2014 Robert Bowdidge,
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

#import <Foundation/Foundation.h>

#import "TypicalIndustryStore.h"

int main(int argc, const char * argv[]){
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (argc < 3) {
        fprintf(stderr, "Usage: generate_classifier_file training-xml-file output-classifier-file\n");
        exit(1);
    }
    NSString *trainingFile = [NSString stringWithUTF8String: argv[1]];
    NSString *outputFile = [NSString stringWithUTF8String: argv[2]];
    
    TypicalIndustryStore *store = [[TypicalIndustryStore alloc] initWithIndustryPlistFile: trainingFile];
    [store.classifier printInformations];
    [store.classifier writeToFile: outputFile];
    [pool release];

    return 0;
}
