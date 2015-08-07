//
//  DSAPIFilterTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/25/13.
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

@interface DSAPIFilterTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIFilterTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListFiltersReturnsAtLeastOneFilter
{
    __block NSArray *_filters = nil;
    [DSAPIFilter listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.beGreaterThan(0);
    expect(_filters[0]).will.beKindOf([DSAPIFilter class]);
    expect(_filters[0]).will.beKindOf([DSAPIFilter class]);
}


- (void)testListFiltersCanSetPerPage
{
    __block NSArray *_filters = nil;
    [DSAPIFilter listFiltersWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.equal(1);
    expect(_filters.count).will.beGreaterThan(0);
}

- (void)testShowFilter
{
    __block DSAPIFilter *_filter = nil;
    [DSAPIFilter listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIFilter *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIFilter *filter) {
            _filter = filter;
            [self done];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filter).willNot.beNil();
    expect(_filter).will.beKindOf([DSAPIFilter class]);
    expect(_filter[@"position"]).willNot.beNil();
}

- (void)testListCases
{
    __block NSArray *_cases = nil;
    [DSAPIFilter listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIFilter *)page.entries[0] listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *casesPage) {
            _cases = casesPage.entries;
            [self done];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_cases.count).will.beGreaterThan(0);
    expect(_cases[0][@"subject"]).willNot.beNil();
    expect(_cases[0]).will.beKindOf([DSAPICase class]);
}

- (void)testListCaseChanges
{
    __block DSAPIPage *caseChanges = nil;
    NSTimeInterval pollTime = (NSInteger)[[NSDate date] timeIntervalSince1970];
    
    [[DSAPIETagCache sharedManager] clearCache];
    [DSAPIFilter listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
            DSAPIFilter *filter = (DSAPIFilter *)page.entries[0];
            [filter listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *casesPage) {
                NSArray *cases = casesPage.entries;
                NSMutableArray *caseIds = [NSMutableArray new];
                [cases enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [caseIds addObject:obj[@"id"]];
                }];
                [filter listCaseChanges:caseIds
                         lastPolledTime:pollTime
                             parameters:nil
                                  queue:self.APICallbackQueue
                                success:^(DSAPIPage *polledCasesPage) {
                                    caseChanges = polledCasesPage;
                                    [self done];
                                }
                                failure:^(NSHTTPURLResponse *response, NSError *error) {
                                    EXPFail(self, __LINE__, __FILE__, [error description]);
                                }];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(caseChanges[@"time"]).will.beInTheRangeOf(pollTime-5, pollTime+5);
    expect(caseChanges[@"positions"]).will.beKindOf([NSArray class]);
    expect(caseChanges.newEntries).will.beKindOf([NSArray class]);
    expect(caseChanges.changedEntries).will.beKindOf([NSArray class]);
    expect(caseChanges.removedEntries).will.beKindOf([NSArray class]);
    expect(caseChanges.positions).will.beKindOf([NSArray class]);
    expect(caseChanges.positions.firstObject).will.beKindOf([NSNumber class]);
    expect(caseChanges.time).will.beKindOf([NSNumber class]);
}

- (void)testNilSuccessBlockInList
{
    [DSAPIFilter listFiltersWithParameters:nil queue:self.APICallbackQueue success:nil failure:nil];
    expect(YES).to.beTruthy();
}

- (void)testNilSuccessBlockInShow
{
    [DSAPIFilter listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [((DSAPIFilter *)page.entries.firstObject) showWithParameters:nil queue:self.APICallbackQueue success:nil failure:nil];
        [self done];
    } failure:nil];
    expect([self isDone]).will.beTruthy();
}

- (void)testNilSuccessBlockInUpdate
{
    [DSAPIFilter listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [((DSAPIFilter *)page.entries.firstObject) updateWithDictionary:nil queue:self.APICallbackQueue success:nil failure:nil];
        [self done];
    } failure:nil];
    expect([self isDone]).will.beTruthy();
}

@end
