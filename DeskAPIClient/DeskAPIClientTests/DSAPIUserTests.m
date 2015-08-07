//
//  DSAPIUserTests.m
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

@interface DSAPIUserTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIUserTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListUsersReturnsAtLeastOneCase
{
    __block NSArray *_users = nil;
    [DSAPIUser listUsersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _users = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_users.count).will.beGreaterThan(0);
    expect(_users[0]).will.beKindOf([DSAPIUser class]);
}

- (void)testListUsersCanSetPerPage
{
    __block NSArray *_users = nil;
    [DSAPIUser listUsersWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _users = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_users.count).will.equal(1);
}


- (void)testShowUser
{
    __block DSAPIUser *_user = nil;
    [DSAPIUser listUsersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIUser *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIUser *user) {
            _user = user;
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
    expect(_user).willNot.beNil();
    expect(_user).will.beKindOf([DSAPIUser class]);
    expect(_user[@"email"]).willNot.beNil();
    expect(_user[@"name"]).willNot.beNil();
}

- (void)testListPreferences
{
    __block NSArray *_preferences = nil;
    [DSAPIUser showCurrentUserWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIUser *authenticatedUser) {
        [authenticatedUser listPreferencesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *preferencesPage) {
            _preferences = preferencesPage.entries;
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
    expect(_preferences.count).will.beGreaterThan(0);
    expect(_preferences[0][@"name"]).willNot.beNil();
    expect(_preferences[0][@"value"]).willNot.beNil();
    expect(_preferences[0]).will.beKindOf([DSAPIUserPreference class]);
}

- (void)testListFilters
{
    
    __block NSArray *_filters = nil;
    [DSAPIUser listUsersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPIUser *user = page.entries[0];
        [user listFiltersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *filtersPage) {
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
    expect(_filters[0][@"position"]).willNot.beNil();
    expect(_filters[0]).will.beKindOf([DSAPIFilter class]);
}

- (void)testListGroups
{
    __block NSArray *_groups = nil;
    [DSAPIUser listUsersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPIUser *user = page.entries[0];
        [user listGroupsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *groupsPage) {
            _groups = groupsPage.entries;
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
    expect(_groups.count).will.beGreaterThan(0);
    expect(_groups[0][@"name"]).willNot.beNil();
    expect(_groups[0]).will.beKindOf([DSAPIGroup class]);
}

- (void)testListMacros
{
    [[DSAPIETagCache sharedManager] clearCache];
    __block NSArray *_macros = nil;
    [DSAPIUser listUsersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPIUser *user = page.entries[0];
        [user listMacrosWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *macrosPage) {
            _macros = macrosPage.entries;
            [self done];
        } notModified:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_macros.count).will.beGreaterThan(0);
    expect(_macros[0][@"name"]).willNot.beNil();
    expect(_macros[0]).will.beKindOf([DSAPIMacro class]);
}

- (void)testShowCurrentUser
{
    __block DSAPIUser *_user = nil;
    [DSAPIUser showCurrentUserWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIUser *user) {
        _user = user;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_user).willNot.beNil();
    expect(_user).will.beKindOf([DSAPIUser class]);
    expect(_user[@"email"]).willNot.beNil();
    expect(_user[@"name"]).willNot.beNil();
}

- (void)testListMobileDevices
{
    [[DSAPIETagCache sharedManager] clearCache];
    __block NSArray *_devices = nil;
    [DSAPIUser listMyMobileDevicesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *devicesPage) {
        _devices = devicesPage.entries;
        [self done];
    } notModified:^(DSAPIPage *page) {
        EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_devices.count).will.beGreaterThan(0);
    expect(_devices[0][@"device_token"]).willNot.beNil();
    expect(_devices[0]).will.beKindOf([DSAPIMobileDevice class]);
}

- (void)testLogout
{
    [DSAPIUser logoutCurrentUserWithQueue:self.APICallbackQueue success:^{
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
}

@end
