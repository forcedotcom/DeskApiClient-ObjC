//
//  DSAPIETagCacheTests.m
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

#import "DSAPITestCase.h"
#import "DSAPIETagCache.h"

@interface DSAPIETagCacheTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;
@property (nonatomic, strong) DSAPILink *link1;
@property (nonatomic, strong) DSAPILink *link2;
@property (nonatomic, strong) DSAPILink *link3;

@end

@interface DSAPIETagCache()

@property (nonatomic, strong) NSMutableDictionary *eTagCache;

- (void)loadETagCache;

@end

@implementation DSAPIETagCacheTests

- (void)setUp
{
    [super setUp];
    NSURL *baseURL = [NSURL URLWithString:@"https://www.google.com"];
    _client = [DSAPITestUtils APIClientBasicAuth];
    
    _link1 = [[DSAPILink alloc] initWithDictionary:@{kHrefKey: @"/api/v2/cases/41",
                                                    kClassKey: @"case"
                                                    } baseURL:baseURL];
    
    _link2 = [[DSAPILink alloc] initWithDictionary:@{kHrefKey: @"/api/v2/cases/41",
                                                    kClassKey: @"case"
                                                     } baseURL:baseURL];
    
    _link3 = [[DSAPILink alloc] initWithDictionary:@{kHrefKey: @"/api/v2/cases/42",
                                                     kClassKey: @"case"
                                                     } baseURL:baseURL];
}

- (void)testSetAndGetEtag
{
    [[DSAPIETagCache sharedManager] setETag:@"1234567" forURL:_link1.URL nextPageURL:_link2.URL];
    expect([[DSAPIETagCache sharedManager] eTagForURL:_link1.URL]).to.equal(@"1234567");
    expect([[DSAPIETagCache sharedManager] eTagForURL:_link2.URL]).to.equal(@"1234567");
    expect([[DSAPIETagCache sharedManager] nextPageURLForURL:_link1.URL].relativeString).to.equal(_link2.href);
    expect([[DSAPIETagCache sharedManager] eTagForURL:_link3.URL]).to.beNil();
}

- (void)testSettingETagUpdatesPlistFile
{
    [[DSAPIETagCache sharedManager] setETag:@"1234567" forURL:_link1.URL nextPageURL:_link2.URL];
    
    NSURL *plistURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"eTagCache.plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    
    expect([[plist valueForKey:_link1.URL.absoluteString] valueForKey:@"ETag"]).to.equal(@"1234567");
}

- (void)testLoadsFromFileWhenMemoryCacheIsNil
{
    [[DSAPIETagCache sharedManager] setETag:@"1234567" forURL:_link1.URL nextPageURL:_link2.URL];
    
    [DSAPIETagCache sharedManager].eTagCache = nil;
    
    id mockCache = [OCMockObject partialMockForObject:[DSAPIETagCache sharedManager]];
    [[mockCache expect] loadETagCache];
    
    __unused NSString *etag = [mockCache eTagForURL:_link1.URL];
    [mockCache verify];
}

- (void)testCache
{
    [[DSAPIETagCache sharedManager] setETag:@"1234567" forURL:_link1.URL nextPageURL:_link2.URL];
    
    expect([[DSAPIETagCache sharedManager] eTagForURL:_link1.URL]).to.equal(@"1234567");
}

- (void)testClearCache
{
    [[DSAPIETagCache sharedManager] setETag:@"1234567" forURL:_link1.URL nextPageURL:_link2.URL];
    [[DSAPIETagCache sharedManager] clearCache];
    
    expect([[DSAPIETagCache sharedManager] eTagForURL:_link1.URL]).to.beNil();
}

- (void)testnextPageURL
{
    [[DSAPIETagCache sharedManager] setETag:@"1234567" forURL:_link1.URL nextPageURL:_link2.URL];
    
    expect([[DSAPIETagCache sharedManager] nextPageURLForURL:_link1.URL].relativeString).to.equal(_link2.href);
}

- (void)testnextPageURLIsNull
{
    [[DSAPIETagCache sharedManager] setETag:@"1234567" forURL:_link1.URL nextPageURL:nil];
    expect([[DSAPIETagCache sharedManager] nextPageURLForURL:_link1.URL]).to.beNil();
}

- (void)testEtagCachingForGroups
{
    [[DSAPIETagCache sharedManager] clearCache];
    XCTestExpectation *expectation = [self expectationWithDescription:@"should receive 304 response"];
    
    [DSAPIGroup listGroupsWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [DSAPIGroup listGroupsWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
            [expectation fulfill];
        } notModified:^(DSAPIPage *notModifiedPage) {
            expect(notModifiedPage.notModified).to.beTruthy();
            [expectation fulfill];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [expectation fulfill];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout handler:nil];
}

- (void)testEtagCachingForLabels
{
    [[DSAPIETagCache sharedManager] clearCache];
    XCTestExpectation *expectation = [self expectationWithDescription:@"should receive 304 response"];
    
    [DSAPILabel listLabelsWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [DSAPILabel listLabelsWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
            [expectation fulfill];
        } notModified:^(DSAPIPage *page){
            expect(page.notModified).to.beTruthy();
            [expectation fulfill];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [expectation fulfill];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout * 2.0 handler:nil];
}

- (void)test304ReponseShouldLoadNextPage
{
    [[DSAPIETagCache sharedManager] clearCache];
    XCTestExpectation *expectation = [self expectationWithDescription:@"should receive 304 response"];
    
    [DSAPILabel listLabelsWithParameters:@{@"per_page": @2} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [DSAPILabel listLabelsWithParameters:@{@"per_page": @2} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
            [expectation fulfill];
        } notModified:^(DSAPIPage *page){
            expect(page.shouldLoadNextPage).to.beTruthy();
            [expectation fulfill];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [expectation fulfill];
        }];
    } notModified:^(DSAPIPage *page) {
        EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout * 2.f handler:nil];
}

- (void)testEtagCachingForUsers
{
    [[DSAPIETagCache sharedManager] clearCache];
    XCTestExpectation *expectation = [self expectationWithDescription:@"should receive 304 response"];
    
    [DSAPIUser listUsersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [DSAPIUser listUsersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
            [expectation fulfill];
        } notModified:^(DSAPIPage *page){
            expect(page.notModified).to.beTruthy();
            [expectation fulfill];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [expectation fulfill];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout * 2.0 handler:nil];
}

- (void)testEtagCachingForFilters
{
    [[DSAPIETagCache sharedManager] clearCache];
    XCTestExpectation *expectation = [self expectationWithDescription:@"should receive 304 response"];
    
    [DSAPIFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [DSAPIFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
            [expectation fulfill];
        } notModified:^(DSAPIPage *page){
            expect(page.notModified).to.beTruthy();
            [expectation fulfill];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [expectation fulfill];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout handler:nil];
}

- (void)testEtagCachingForFilterCases
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should receive 304 response"];
    
    [DSAPIFilter listFiltersWithParameters:@{@"per_page":@1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPIFilter *filter = (DSAPIFilter *)page.entries[0];
        [filter listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            [filter listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
                EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
                [expectation fulfill];
            } notModified:^(DSAPIPage *page){
                expect(page.notModified).to.beTruthy();
                [expectation fulfill];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
                [expectation fulfill];
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [expectation fulfill];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout * 3.f handler:nil];
}

- (void)testPageNotModifiedIsFalseFor200Response
{
    [[DSAPIETagCache sharedManager] clearCache];
    XCTestExpectation *expectation = [self expectationWithDescription:@"should receive 200 response"];
    
    [DSAPILabel listLabelsWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        expect(page.notModified).toNot.beTruthy();
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout * 3.0 handler:nil];
}

- (void)testConcurrentSaveDoesNotCrash
{
    [[DSAPIETagCache sharedManager] clearCache];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    NSUInteger n = 100;
    __block NSMutableArray *operations = [NSMutableArray arrayWithCapacity:n];
    NSOperation *operation;
    for (int i = 0; i < n; i++) {
        operation = [NSBlockOperation blockOperationWithBlock:^{
            NSString *etag = [NSString stringWithFormat:@"etag %@", @(i)];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://test%@.com", @(i)]];
            NSURL *nextURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://test%@.com", @(i+1)]];
            [[DSAPIETagCache sharedManager] setETag:etag forURL:url nextPageURL:nextURL];
        }];
        operations[i] = operation;
    }
    
    [queue addOperations:operations waitUntilFinished:YES];
}

@end
