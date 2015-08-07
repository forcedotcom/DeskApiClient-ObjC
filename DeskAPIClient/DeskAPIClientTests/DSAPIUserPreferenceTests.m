//
//  DSAPIUserPreferenceTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 10/3/13.
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

@interface DSAPIUserPreferenceTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIUserPreferenceTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testShowUserPreference
{
    __block DSAPIUserPreference *_preference = nil;
    // need to find the user that matches the authenticated user making the request
    [DSAPIUser showCurrentUserWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIUser *authenticatedUser) {
        [authenticatedUser listPreferencesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *preferencesPage) {
            [(DSAPIUserPreference *)preferencesPage.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIUserPreference *preference) {
                _preference = preference;
                [self done];
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
    expect(_preference[@"name"]).willNot.beNil();
    expect(_preference[@"value"]).willNot.beNil();
    expect(_preference).will.beKindOf([DSAPIUserPreference class]);
}


- (void)testUpdateUserPreference
{
    __block DSAPIResource *updatedPreference = nil;
    [DSAPIUser showCurrentUserWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIUser *authenticatedUser) {
        [authenticatedUser listPreferencesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *preferencesPage) {
            [(DSAPIUserPreference *)preferencesPage.entries[0] updateWithDictionary:@{@"value":@-2} queue:self.APICallbackQueue success:^(DSAPIUserPreference *preference) {
                updatedPreference = preference;
                [self done];
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
    expect([updatedPreference[@"value"] integerValue]).will.equal(-2);
    expect(updatedPreference).will.beKindOf([DSAPIUserPreference class]);
    
    // revert data back for future tests
    [DSAPIUser showCurrentUserWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIUser *authenticatedUser) {
        [authenticatedUser listPreferencesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *preferencesPage) {
            [(DSAPIUserPreference *)preferencesPage.entries[0] updateWithDictionary:@{@"value":@0} queue:self.APICallbackQueue success:^(DSAPIUserPreference *preference) {
                updatedPreference = preference;
                [self done];
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
    expect([updatedPreference[@"value"] integerValue]).will.equal(0);
    expect(updatedPreference).will.beKindOf([DSAPIUserPreference class]);
}

@end
