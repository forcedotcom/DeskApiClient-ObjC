//
//  DSAPISiteTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 11/10/14.
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
#import "DSAPITestCase.h"

@interface DSAPISiteTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPISiteTests

- (void)setUp {
    [super setUp];

    [Expecta setAsynchronousTestTimeout:5.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testShowCurrentSite
{
    __block DSAPISite *_site = nil;
    
    [DSAPISite showCurrentSiteWithQueue:self.APICallbackQueue success:^(DSAPISite *site) {
        _site = site;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_site).willNot.beNil();
    expect(_site).will.beKindOf([DSAPISite class]);
    expect(_site[@"id"]).willNot.beNil();
    expect(_site[@"subdomain"]).willNot.beNil();
}

- (void)testShowCurrentSiteWithParameters
{
    __block DSAPISite *_site = nil;
    
    [DSAPISite showCurrentSiteWithParameters:@{}
                                       queue:self.APICallbackQueue
                                     success:^(DSAPISite *site) {
                                         _site = site;
                                         [self done];
                                     } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                         EXPFail(self, __LINE__, __FILE__, [error description]);
                                     }];

    expect([self isDone]).will.beTruthy();
    expect(_site).willNot.beNil();
    expect(_site).will.beKindOf([DSAPISite class]);
}

- (void)testShowWithSuccessAndFailure
{
    __block DSAPISite *_site = nil;
    
    [DSAPISite showCurrentSiteWithQueue:self.APICallbackQueue success:^(DSAPISite *site) {
        [site showWithQueue:self.APICallbackQueue success:^(DSAPISite *site) {
            _site = site;
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
    expect(_site).will.beKindOf([DSAPISite class]);
    expect(_site).willNot.beNil();
    expect(_site[@"id"]).willNot.beNil();
    expect(_site[@"subdomain"]).willNot.beNil();
}

- (void)testShowWithParameters
{
    __block DSAPISite *_site = nil;
    
    [DSAPISite showCurrentSiteWithQueue:self.APICallbackQueue success:^(DSAPISite *site) {
        [site showWithParameters:@{}
                           queue:self.APICallbackQueue
                         success:^(DSAPISite *site) {
                             _site = site;
                             [self done];
                         } failure:^(NSHTTPURLResponse *response, NSError *error) {
                             EXPFail(self, __LINE__, __FILE__, [error description]);
                         }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_site).will.beKindOf([DSAPISite class]);
    expect(_site).willNot.beNil();
}

- (void)testShowBilling
{
    __block DSAPIBilling *_billing = nil;
    
    [DSAPISite showCurrentSiteBillingWithQueue:self.APICallbackQueue success:^(DSAPIBilling *billing) {
        _billing = billing;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_billing).will.beKindOf([DSAPIBilling class]);
    expect(_billing).willNot.beNil();
}

@end
