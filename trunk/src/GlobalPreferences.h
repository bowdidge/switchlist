//
//  GlobalPreferences.h
//  SwitchList
//
//  Created by bowdidge on 2/21/11.
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
//

#import <Cocoa/Cocoa.h>

// Settings for global app preferences dictionary.

// DEPRECATED: Preferred switch list style.  Value is enum value from SwitchListStyle enum.
extern NSString *GLOBAL_PREFS_SWITCH_LIST_DEFAULT_STYLE;

// Preferred switch list style.  Value is string name.  If named template does not exist,
// then the default template should be used.
extern NSString *GLOBAL_PREFS_SWITCH_LIST_DEFAULT_TEMPLATE;

// Indicates whether the web server control panel should be visible.  Boolean.
extern NSString *GLOBAL_PREFS_DISPLAY_WEB_SERVER;

// Indicates whether the web server should be running.  Boolean.
extern NSString *GLOBAL_PREFS_ENABLE_WEB_SERVER;

// Constants handy for defaults.
// Name for the default template as displayed in the switchlist
// preference pop up.
extern NSString *DEFAULT_SWITCHLIST_TEMPLATE;