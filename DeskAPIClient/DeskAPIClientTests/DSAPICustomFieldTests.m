//
//  DSAPICustomFieldTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 2/12/14.
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

@interface DSAPICustomFieldTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPICustomFieldTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testListCustomFieldsReturnsAtLeastOneCustomFields
{
    __block NSArray *_customFields = nil;
    
    [DSAPICustomField listCustomFieldsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _customFields = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_customFields.count).will.beGreaterThan(0);
    expect(_customFields[0]).will.beKindOf([DSAPICustomField class]);
}


- (void)testListCustomFieldsCanSetPerPage
{
    __block NSArray *_customFields = nil;
    
    [DSAPICustomField listCustomFieldsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _customFields = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_customFields.count).will.equal(1);
}


- (void)testListCustomFieldsCanRetrieveNextPage
{
    __block DSAPILink *previousLink = nil;
    
    [DSAPICustomField listCustomFieldsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPICustomField listCustomFieldsWithParameters:nextLink.parameters queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
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


- (void)testShowCustomField
{
    __block DSAPIResource *_customField = nil;
    [DSAPICustomField listCustomFieldsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICustomField *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICustomField *customField) {
            _customField = customField;
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
    expect(_customField).willNot.beNil();
    expect(_customField).will.beKindOf([DSAPICustomField class]);
    expect(_customField[@"name"]).willNot.beNil();
}

@end
