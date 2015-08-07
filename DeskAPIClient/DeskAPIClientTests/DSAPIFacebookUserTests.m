//
//  DSAPIFacebookUserTests.m
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

@interface DSAPIFacebookUserTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPIFacebookUserTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testListFacebookusersReturnsAtLeastOneFacebookUser
{
    __block NSArray *_facebookUsers = nil;
    
    [DSAPIFacebookUser listFacebookUsersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _facebookUsers = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_facebookUsers.count).will.beGreaterThan(0);
    expect(_facebookUsers[0]).will.beKindOf([DSAPIFacebookUser class]);
}


- (void)testListFacebookUsersCanSetPerPage
{
    __block NSArray *_facebookUsers = nil;
    
    [DSAPIFacebookUser listFacebookUsersWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _facebookUsers = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_facebookUsers.count).will.equal(1);
}


- (void)testShowFacebookUser
{
    __block DSAPIResource *_facebookUser = nil;
    [DSAPIFacebookUser listFacebookUsersWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIFacebookUser *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIFacebookUser *facebookUser) {
            _facebookUser = facebookUser;
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
    expect(_facebookUser).willNot.beNil();
    expect(_facebookUser).will.beKindOf([DSAPIFacebookUser class]);
    expect(_facebookUser[@"profile_url"]).willNot.beNil();
}

@end
