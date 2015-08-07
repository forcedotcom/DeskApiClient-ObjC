//
//  DSAPIListProvider.m
//  DeskKit
//
//  Created by Desk.com on 1/27/15.
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

#import "DSAPIListProvider.h"
#import "DSAPIPage.h"

@interface DSAPIListProvider ()

@property (nonatomic) NSUInteger totalResources;
@property (nonatomic, strong) id<DSAPIListEndpoint> endpoint;
@property (nonatomic, strong) NSMutableDictionary *loadedPages;
@property (nonatomic) NSOperationQueue *APICallbackQueue;

@end

@implementation DSAPIListProvider

- (instancetype)initWithEndpoint:(id<DSAPIListEndpoint>)endpoint
{
    NSParameterAssert(endpoint);
    self = [super init];
    if (self) {
        _endpoint = endpoint;
        _APICallbackQueue = [NSOperationQueue new];
        [self reset];
    }
    return self;
}

- (void)reset
{
    self.loadedPages = [NSMutableDictionary new];
    self.totalResources = 0;
    [self.APICallbackQueue cancelAllOperations];
}

- (NSInteger)totalPages
{
    return (NSInteger)ceil([@(self.totalResources) floatValue] / self.resourcesPerPage);
}

- (NSUInteger)resourcesPerPage
{
    return [self.endpoint perPage];
}

- (NSInteger)numberOfResourcesOnPageNumber:(NSUInteger)pageNumber
{
    NSInteger remainingResources = self.totalResources - ((pageNumber - 1) * self.resourcesPerPage);
    return remainingResources > self.resourcesPerPage ? self.resourcesPerPage : remainingResources;
}

- (void)fetchResourcesOnPageNumber:(NSUInteger)pageNumber
{
    if ([self shouldFetchResourcesOnPageNumber:pageNumber]) {
        [self sendWillFetchPageNumber:pageNumber];
        [self sendFetchResourcesOnPageNumber:pageNumber];
    }
}

- (void)sendFetchResourcesOnPageNumber:(NSUInteger)pageNumber
{
    [self.endpoint listResourcesOnPageNumber:pageNumber
                                       queue:self.APICallbackQueue
                                     success:^(DSAPIPage *page) {
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             [self handleLoadedResourcesOnPage:page];
                                         });
                                     }
                                     failure:^(NSHTTPURLResponse *response, NSError *error) {
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             [self sendFetchDidFailOnPageNumber:pageNumber];
                                         });
                                     }];
}

- (BOOL)shouldFetchResourcesOnPageNumber:(NSUInteger)pageNumber
{
    if ([self alreadyLoadedResourcesOnPageNumber:pageNumber]) {
        return NO;
    }
    if (pageNumber == 1) {
        // always load page 1
        return YES;
    }
    return [self pageNumberIsFetchable:pageNumber];
}

- (BOOL)alreadyLoadedResourcesOnPageNumber:(NSUInteger)pageNumber
{
    return (BOOL)[self.loadedPages objectForKey: @(pageNumber)];
}

- (BOOL)pageNumberIsFetchable:(NSUInteger)pageNumber
{
    return (pageNumber > 0 && pageNumber <= self.totalPages);
}

- (void)handleLoadedResourcesOnPage:(DSAPIPage *)page
{
    self.totalResources = [page.totalEntries integerValue];
    if (self.totalResources > 0) {
        [self.loadedPages setObject:page forKey:@(page.pageNumber)];
        [self sendDidFetchPage:page];
    } else {
        [self sendNoResults];
    }
}

- (void)sendWillFetchPageNumber:(NSUInteger)pageNumber
{
    if ([self.delegate respondsToSelector:@selector(listProvider:willFetchPageNumber:)]) {
        [self.delegate listProvider:self willFetchPageNumber:pageNumber];
    }
}

- (void)sendDidFetchPage:(DSAPIPage *)page
{
    if ([self.delegate respondsToSelector:@selector(listProvider:didFetchPage:)]) {
        [self.delegate listProvider:self didFetchPage:page];
    }
}

- (void)sendNoResults
{
    if ([self.delegate respondsToSelector:@selector(listProviderDidFetchNoResults:)]) {
        [self.delegate listProviderDidFetchNoResults:self];
    }
}

- (void)sendFetchDidFailOnPageNumber:(NSUInteger)pageNumber
{
    if ([self.delegate respondsToSelector:@selector(listProvider:fetchDidFailOnPageNumber:)]) {
        [self.delegate listProvider:self fetchDidFailOnPageNumber:pageNumber];
    }
}

- (DSAPIResource *)resourceOnPageNumber:(NSUInteger)pageNumber inRow:(NSUInteger)row
{
    DSAPIPage *page = [self loadedPageNumber:pageNumber];
    return [page.entries objectAtIndex:row];
}

- (DSAPIPage *)loadedPageNumber:(NSInteger)pageNumber
{
    return [self.loadedPages objectForKey:@(pageNumber)];
}

@end
