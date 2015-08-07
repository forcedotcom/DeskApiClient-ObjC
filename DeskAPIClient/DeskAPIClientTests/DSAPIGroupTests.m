//
//  DSAPIGroupTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 11/11/13.
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

@interface DSAPIGroupTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPIGroupTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testListGroupsReturnsAtLeastOneGroup
{
    __block NSArray *_groups = nil;
    [DSAPIGroup listGroupsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _groups = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_groups.count).will.beGreaterThan(0);
    expect(_groups[0]).will.beKindOf([DSAPIGroup class]);
}


- (void)testListGroupsCanSetPerPage
{
    __block NSArray *_groups = nil;
    [DSAPIGroup listGroupsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _groups = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_groups.count).will.equal(1);
}


- (void)testListGroupsCanRetrieveNextPage
{
    __block DSAPILink *previousLink = nil;
    [DSAPIGroup listGroupsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPIGroup listGroupsWithParameters:nextLink.parameters queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
            previousLink = nextPage.links[@"previous"][0];
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
    expect([previousLink.parameters[@"page"] integerValue]).will.equal(1);
    expect([previousLink.parameters[@"per_page"] integerValue]).will.equal(1);
}


- (void)testShowGroup
{
    __block DSAPIResource *_group = nil;
    [DSAPIGroup listGroupsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIGroup *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIGroup *group) {
            _group = group;
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
    expect(_group).willNot.beNil();
    expect(_group).will.beKindOf([DSAPIGroup class]);
    expect(_group[@"name"]).willNot.beNil();
}


- (void)testListGroupFilters
{
    __block NSArray *_filters = nil;
    [DSAPIGroup listGroupsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIGroup *)page.entries[0] listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *filtersPage) {
            _filters = filtersPage.entries;
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
    expect(_filters.count).will.beGreaterThan(0);
    expect(_filters[0][@"name"]).willNot.beNil();
    expect(_filters[0]).will.beKindOf([DSAPIFilter class]);
}


- (void)testListUsers
{
    __block NSArray *_users = nil;
    [DSAPIGroup listGroupsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIGroup *)page.entries[0] listUsersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *usersPage) {
            _users = usersPage.entries;
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
    expect(_users.count).will.beGreaterThan(0);
    expect(_users[0][@"public_name"]).willNot.beNil();
    expect(_users[0]).will.beKindOf([DSAPIUser class]);
}

@end
