//
//  SimpleHTTPServer.h
//  Web2PDF Server
//
//  Created by Jürgen on 19.09.06.
//  Copyright 2006 Cultured Code.
//  License: Creative Commons Attribution 2.5 License
//           http://creativecommons.org/licenses/by/2.5/
//

#import <Cocoa/Cocoa.h>

@class SimpleHTTPConnection;

@protocol SimpleHTTPServerDelegate 
- (void) stopProcessing;
- (void) processURL: (NSURL*) url connection: (SimpleHTTPConnection*) conn userAgent: (NSString*) userAgent;
@end

@interface SimpleHTTPServer : NSObject {
    unsigned port;
    NSObject<SimpleHTTPServerDelegate> *delegate;

    NSSocketPort *socketPort;
    NSFileHandle *fileHandle;
    NSMutableArray *connections;
    NSMutableArray *requests;    
    NSDictionary *currentRequest;
}

- (id)initWithTCPPort:(unsigned)po delegate:(id)dl;
- (void) stopResponding;

- (NSArray *)connections;
- (NSArray *)requests;

- (void)closeConnection:(SimpleHTTPConnection *)connection;
- (void)newRequestWithURL:(NSURL *)url connection:(SimpleHTTPConnection *)connection userAgent: (NSString*) userAgent;

// Request currently being processed
// Note: this need not be the most recently received request
- (NSDictionary *)currentRequest;

- (void)replyWithStatusCode:(int)code
                    headers:(NSDictionary *)headers
                       body:(NSData *)body;
- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type;
- (void)replyWithStatusCode:(int)code message:(NSString *)message;

@end
