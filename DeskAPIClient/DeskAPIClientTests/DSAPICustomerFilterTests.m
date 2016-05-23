//
//  DSAPICustomerFilterTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 4/13/16.
//  Copyright (c) 2016, Salesforce.com, Inc.
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

@interface DSAPICustomerFilterTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPICustomerFilterTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListFiltersReturnsAtLeastOneFilter
{
    __block NSArray *_filters = nil;
    
    [DSAPICustomerFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.beGreaterThan(0);
    expect(_filters[0]).will.beKindOf([DSAPICustomerFilter class]);
}

- (void)testListFiltersCanSetPerPage
{
    __block NSArray *_filters = nil;
    [DSAPICustomerFilter listFiltersWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.equal(1);
    expect(_filters[0]).will.beKindOf([DSAPICustomerFilter class]);
}

- (void)testShowFilter
{
    __block DSAPICustomerFilter *_filter = nil;
    [DSAPICustomerFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICustomerFilter *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICustomerFilter *filter) {
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
    expect(_filter).will.beKindOf([DSAPICustomerFilter class]);
    expect(_filter[@"name"]).willNot.beNil();
    expect(_filter[@"position"]).willNot.beNil();
}

- (void)testListCustomers
{
    __block NSArray *_customers = nil;
    [DSAPICustomerFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICustomerFilter *)page.entries[0] listCustomersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            _customers = page.entries;
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
    expect(_customers.count).will.beGreaterThan(0);
    expect(_customers[0][@"id"]).willNot.beNil();
    expect(_customers[0]).will.beKindOf([DSAPICustomer class]);
}

@end
