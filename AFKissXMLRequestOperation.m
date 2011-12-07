// AFKissXMLRequestOperation.m
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFKissXMLRequestOperation.h"

static dispatch_queue_t af_kissxml_request_operation_processing_queue;
static dispatch_queue_t kissxml_request_operation_processing_queue() {
    if (af_kissxml_request_operation_processing_queue == NULL) {
        af_kissxml_request_operation_processing_queue = dispatch_queue_create("com.alamofire.networking.kissxml-request.processing", 0);
    }
    
    return af_kissxml_request_operation_processing_queue;
}

@interface AFKissXMLRequestOperation ()
@property (readwrite, nonatomic, retain) DDXMLDocument *responseXMLDocument;
@property (readwrite, nonatomic, retain) NSError *error;

+ (NSSet *)defaultAcceptableContentTypes;
+ (NSSet *)defaultAcceptablePathExtensions;
@end

@implementation AFKissXMLRequestOperation
@synthesize responseXMLDocument = _responseXMLDocument;
@synthesize error = _XMLError;

+ (AFKissXMLRequestOperation *)XMLDocumentRequestOperationWithRequest:(NSURLRequest *)urlRequest 
                                                              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, DDXMLDocument *XMLDocument))success 
                                                              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, DDXMLDocument *XMLDocument))failure
{
    AFKissXMLRequestOperation *operation = [[[self alloc] initWithRequest:urlRequest] autorelease];
    operation.completionBlock = ^ {
        if ([operation isCancelled]) {
            return;
        }
        
        if (operation.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(operation.request, operation.response, operation.error, [(AFKissXMLRequestOperation *)operation responseXMLDocument]);
                });
            }
        } else {
            dispatch_async(kissxml_request_operation_processing_queue(), ^(void) {
                DDXMLDocument *XMLDocument = operation.responseXMLDocument;
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        success(operation.request, operation.response, XMLDocument);
                    });
                }
            });
        }
    };
    
    return operation;
}

+ (NSSet *)defaultAcceptableContentTypes {
    return [NSSet setWithObjects:@"application/xml", @"text/xml", @"text/html", @"application/xhtml+xml", nil];
}

+ (NSSet *)defaultAcceptablePathExtensions {
    return [NSSet setWithObjects:@"xml", @"html", nil];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[self class] defaultAcceptableContentTypes];
    
    return self;
}

- (void)dealloc {
    [_XMLDocument release];
    [_XMLError release];
    [super dealloc];
}

- (DDXMLDocument *)responseXMLDocument {
    if (!_responseXMLDocument && [self isFinished]) {
        NSError *error = nil;
        self.responseXMLDocument = [[DDXMLDocument alloc] initWithData:self.responseData options:0 error:&error];
        self.error = error;
    }
    
    return _responseXMLDocument;
}

- (NSError *)error {
    if (_XMLError) {
        return _XMLError;
    } else {
        return [super error];
    }
}

#pragma mark - NSOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)request {
    return [[self defaultAcceptableContentTypes] containsObject:[request valueForHTTPHeaderField:@"Accept"]] || [[self defaultAcceptablePathExtensions] containsObject:[[request URL] pathExtension]];
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    self.completionBlock = ^ {
        if ([self isCancelled]) {
            return;
        }
        
        if (self.error) {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    failure(self, self.error);
                });
            }
        } else {
            if (success) {
                success(self, self.responseXMLDocument);
            }
        }
    };    
}

@end
