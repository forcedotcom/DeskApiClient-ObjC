//
//  DSAPIETagCache.m
//  DeskAPIClient
//
//  Created by Desk.com on 12/20/13.
//  Copyright (c) 2015, Salesforce.com, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided
//  that the following conditions are met:
//  
//     Redistributions of source code must retain the above copyright notice, this list of conditions and the
//     following disclaimer.
//  
//     Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
//     the following disclaimer in the documentation and/or other materials provided with the distribution.
//  
//     Neither the name of Salesforce.com, Inc. nor the names of its contributors may be used to endorse or
//     promote products derived from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "DSAPIETagCache.h"

#define kNumEndpointsWithETags 4
#define kETagPlistFilename @"eTagCache.plist"
#define kVersionKey @"Version"
#define kVersionValue @2
#define kETagKey @"ETag"
#define kNextPageURLKey @"NextPageURL"
#define kNullValue @"null"

@interface DSAPIETagCache()

@property (nonatomic, strong) NSMutableDictionary *eTagCache;

- (NSURL *)applicationCachesDirectory;
- (NSURL *)eTagPlistURL;
- (BOOL)saveETagCache;
- (void)loadETagCache;
- (NSMutableDictionary *)newETagCache;
- (NSURL *)URLWithAbsoluteURLString:(NSString *)absoluteURLString relativeToBaseOfURL:(NSURL *)baseOfURL;

@end

@implementation DSAPIETagCache

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [DSAPIETagCache new];
    });
    return sharedInstance;
}


- (NSURL *)applicationCachesDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)eTagPlistURL
{
    return [[self applicationCachesDirectory] URLByAppendingPathComponent:kETagPlistFilename];
}

- (BOOL)saveETagCache
{
    return [self.eTagCache writeToURL:self.eTagPlistURL atomically:YES];
}

- (void)loadETagCache
{
    NSMutableDictionary *eTagCache = [[NSDictionary dictionaryWithContentsOfURL:self.eTagPlistURL] mutableCopy];
    
    if (![eTagCache.allKeys containsObject:kVersionKey]) {
        // clear out old cache
        eTagCache = [self newETagCache];
    }
    
    self.eTagCache = eTagCache;
}

- (void)setETag:(NSString *)eTag forURL:(NSURL *)url nextPageURL:(NSURL *)nextPageURL
{
    if (!self.eTagCache) {
        self.eTagCache = [self newETagCache];
    }
    NSDictionary *valueDictionary = @{kETagKey:eTag, kNextPageURLKey: nextPageURL.absoluteString ? nextPageURL.absoluteString : kNullValue};
    [self.eTagCache setValue:valueDictionary forKey:url.absoluteString];
    [self saveETagCache];
}

- (NSString *)eTagForURL:(NSURL *)url
{
    if (!self.eTagCache) {
        [self loadETagCache];
    }
    NSDictionary *valueDictionary = [self.eTagCache valueForKey:url.absoluteString];
    return valueDictionary[kETagKey];
}

- (NSURL *)pageURLForURL:(NSURL *)url
{
    return [self URLWithAbsoluteURLString:url.absoluteString relativeToBaseOfURL:url];
}

- (NSURL *)nextPageURLForURL:(NSURL *)url
{
    if (!self.eTagCache) {
        [self loadETagCache];
    }
    
    NSDictionary *valueDictionary = [self.eTagCache valueForKey:url.absoluteString];
    NSString *nextPageURLAbsoluteString = [valueDictionary valueForKey:kNextPageURLKey];
    
    if ([nextPageURLAbsoluteString isEqualToString:kNullValue] || !nextPageURLAbsoluteString) {
        return nil;
    } else {
        return [self URLWithAbsoluteURLString:nextPageURLAbsoluteString relativeToBaseOfURL:url];
    }
}

- (NSURL *)URLWithAbsoluteURLString:(NSString *)absoluteURLString relativeToBaseOfURL:(NSURL *)baseOfURL
{
    NSArray *components = [absoluteURLString componentsSeparatedByString:baseOfURL.host];
    if (components.count > 1) {
        NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", baseOfURL.scheme, baseOfURL.host]];
        return [NSURL URLWithString:components[1] relativeToURL:baseURL];
    } else {
        return nil;
    }
}

- (void)clearCache
{
    self.eTagCache = [self newETagCache];
    [self saveETagCache];
}

- (NSMutableDictionary *)newETagCache
{
    NSMutableDictionary *newCache = [[NSMutableDictionary alloc] initWithCapacity:kNumEndpointsWithETags];
    newCache[kVersionKey] = kVersionValue;
    return newCache;
}
@end
