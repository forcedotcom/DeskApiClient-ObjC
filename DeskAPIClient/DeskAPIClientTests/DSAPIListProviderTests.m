//
//  DSAPIListProviderTests.m
//  DeskAPIClient
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DSAPIListProvider.h"

static NSUInteger const DSAPIResourcesPerPageTest = 25;

@interface DSAPIListProvider ()

@property (nonatomic) NSUInteger totalResources;
@property (nonatomic, strong) id<DSAPIListEndpoint> endpoint;
@property (nonatomic, strong) NSMutableDictionary *loadedPages;

- (void)fetchResourcesOnPageNumber:(NSUInteger)pageNumber;
- (void)sendFetchResourcesOnPageNumber:(NSUInteger)pageNumber;
- (BOOL)shouldFetchResourcesOnPageNumber:(NSUInteger)pageNumber;
- (BOOL)alreadyLoadedResourcesOnPageNumber:(NSUInteger)pageNumber;
- (BOOL)pageNumberIsFetchable:(NSUInteger)pageNumber;
- (void)handleLoadedResourcesOnPage:(DSAPIPage *)page;
- (void)sendWillFetchPageNumber:(NSUInteger)pageNumber;
- (void)sendDidFetchPage:(DSAPIPage *)page;
- (void)sendNoResults;
- (DSAPIPage *)loadedPageNumber:(NSInteger)pageNumber;

@end

@interface DSAPIListEndpointTest : NSObject  <DSAPIListEndpoint>

@property (nonatomic) NSUInteger perPage;

@end


@implementation DSAPIListEndpointTest : NSObject

- (void)listResourcesOnPageNumber:(NSUInteger)pageNumber
                            queue:(NSOperationQueue *)queue
                          success:(DSAPIPageSuccessBlock)success
                          failure:(DSAPIFailureBlock)failure
{
    
}

- (NSUInteger)perPage
{
    return DSAPIResourcesPerPageTest;
}

@end

@interface DSAPIListProviderTests : XCTestCase

@property (nonatomic, strong) id<DSAPIListEndpoint> endpoint;

@end

@implementation DSAPIListProviderTests

- (void)setUp
{
    [super setUp];
    self.endpoint = [DSAPIListEndpointTest new];
}

- (void)testLoadsResourcesFromEndpoint
{
    DSAPIListProvider *listProvider = [self testProvider];
    id mock = OCMPartialMock(self.endpoint);
    
    OCMExpect([mock listResourcesOnPageNumber:1 queue:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY]);
    
    [listProvider fetchResourcesOnPageNumber:1];
    
    OCMVerifyAll(mock);
}

- (void)testReset
{
    DSAPIListProvider *listProvider = [self testProvider];
    
    [listProvider reset];
    expect(listProvider.loadedPages).to.equal(@{});
    expect(listProvider.totalResources).to.equal(0);
}

- (void)testShouldFetchResourcesOnPageNumber
{
    DSAPIListProvider *listProvider = [self testProvider];
    
    DSAPIPage *topicsPage = [self testPage];
    expect([listProvider shouldFetchResourcesOnPageNumber:1]).to.beTruthy();
    expect([listProvider shouldFetchResourcesOnPageNumber:2]).to.beFalsy();
    
    [listProvider handleLoadedResourcesOnPage:topicsPage];
    
    expect([listProvider shouldFetchResourcesOnPageNumber:1]).to.beFalsy();
    expect([listProvider shouldFetchResourcesOnPageNumber:2]).to.beTruthy();
    
    NSInteger pageNumberBeyondTotalEntries = 2 + topicsPage.totalEntries.integerValue/self.endpoint.perPage;
    expect([listProvider shouldFetchResourcesOnPageNumber:pageNumberBeyondTotalEntries]).to.beFalsy();
}

- (void)testFetchesResourcesOnPageNumber
{
    DSAPIListProvider *listProvider = [self testProvider];
    id mock = OCMPartialMock(listProvider);
    id endpointMock = OCMPartialMock(self.endpoint);
    
    OCMStub([mock shouldFetchResourcesOnPageNumber:1]).andReturn(YES);
    
    OCMExpect([endpointMock listResourcesOnPageNumber:1 queue:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY]);
    
    [listProvider fetchResourcesOnPageNumber:1];
    
    OCMVerifyAll(mock);
}

- (void)testFetchResourcesInSectionNotifiesDelegate
{
    DSAPIListProvider *listProvider = [self testProvider];
    id mock = OCMPartialMock(listProvider);
    
    OCMStub([mock shouldFetchResourcesOnPageNumber:1]).andReturn(YES);
    
    OCMExpect([mock sendWillFetchPageNumber:1]);
    
    [listProvider fetchResourcesOnPageNumber:1];
    
    OCMVerifyAll(mock);
}

- (void)testAlreadyLoadedResourcesOnPageNumber
{
    DSAPIListProvider *listProvider = [self testProvider];
    
    expect([listProvider alreadyLoadedResourcesOnPageNumber:1]).to.beFalsy();
    
    [listProvider handleLoadedResourcesOnPage:[self testPage]];
    
    expect([listProvider alreadyLoadedResourcesOnPageNumber:1]).to.beTruthy();
    expect([listProvider alreadyLoadedResourcesOnPageNumber:2]).to.beFalsy();
}

- (void)testPageNumberIsFetchable
{
    DSAPIListProvider *listProvider = [self testProvider];
    
    DSAPIPage *topicsPage = [self testPage];
    [listProvider handleLoadedResourcesOnPage:topicsPage];
    expect([listProvider pageNumberIsFetchable:0]).to.beFalsy();
    expect([listProvider pageNumberIsFetchable:1]).to.beTruthy();
    expect([listProvider pageNumberIsFetchable:2]).to.beTruthy();
    expect([listProvider pageNumberIsFetchable:3]).to.beTruthy();
    
    NSInteger pageNumberBeyondTotalEntries = 2 + topicsPage.totalEntries.integerValue/self.endpoint.perPage;
    expect([listProvider pageNumberIsFetchable:pageNumberBeyondTotalEntries]).to.beFalsy();
}

- (void)testHandleLoadedResources
{
    DSAPIListProvider *listProvider = [self testProvider];
    id mock = OCMPartialMock(listProvider);
    
    expect(listProvider.totalResources).to.equal(0);
    OCMExpect([mock sendDidFetchPage:OCMOCK_ANY]);
    
    DSAPIPage *page = [self testPage];
    [listProvider handleLoadedResourcesOnPage:page];
    
    expect(listProvider.totalResources).to.equal(page.totalEntries);
    expect([listProvider.loadedPages objectForKey:@(page.pageNumber)]).to.equal(page);
    
    OCMVerifyAll(mock);
}

- (void)testHandleLoadedResourcesWhenNoResults
{
    DSAPIListProvider *listProvider = [self testProvider];
    id mock = OCMPartialMock(listProvider);
    
    OCMExpect([mock sendNoResults]);
    
    [listProvider handleLoadedResourcesOnPage:[DSAPIPage new]];
    
    OCMVerifyAll(mock);
}

- (void)testTotalPages
{
    DSAPIListProvider *listProvider = [self testProvider];
    
    DSAPIPage *page = [self testPage];
    [listProvider handleLoadedResourcesOnPage:page];
    
    // Fixture has 201 entries, so should be 1 + (total entries / resources per page)
    expect([listProvider numberOfResourcesOnPageNumber:1]).to.equal(self.endpoint.perPage);
    expect(listProvider.totalPages).to.equal(1 + page.totalEntries.integerValue/self.endpoint.perPage);
}

- (void)testResourceOnPageNumberInRowIsNilBeforeLoading
{
    DSAPIListProvider *listProvider = [self testProvider];
    expect([listProvider resourceOnPageNumber:1 inRow:0]).to.beNil();
}

- (void)testResourceOnPageNumberInRowIsNotNilAfterLoading
{
    DSAPIListProvider *listProvider = [self testProvider];
    
    DSAPIPage *page = [self testPage];
    [listProvider handleLoadedResourcesOnPage:page];
    
    expect([listProvider resourceOnPageNumber:1 inRow:0]).toNot.beNil();
}

- (void)testLoadedPageOnPageNumber
{
    DSAPIListProvider *listProvider = [self testProvider];
    
    expect([listProvider loadedPageNumber:1]).to.beNil();
    
    DSAPIPage *page = [self testPage];
    [listProvider handleLoadedResourcesOnPage:page];
    
    expect([listProvider loadedPageNumber:1]).to.equal(page);
}

#pragma mark - Utility

- (DSAPIListProvider *)testProvider
{
    return [[DSAPIListProvider alloc] initWithEndpoint:self.endpoint];
}

- (DSAPIPage *)testPage
{
    NSDictionary *dictionary = [DSAPITestUtils dictionaryFromJSONFile:@"topics"];
    return [[DSAPIPage alloc] initWithDictionary:dictionary];
}

@end
