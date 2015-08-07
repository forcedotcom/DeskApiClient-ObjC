//
//  DSAPIInteractionTests.m
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

@interface DSAPIInteractionTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIInteractionTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testInteractionClass
{
    __block DSAPIInteraction *_interaction = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [page.entries[0] listRepliesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *repliesPage) {
            _interaction = repliesPage.entries[0];
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
    expect(_interaction).willNot.beNil();
    expect(_interaction).will.beKindOf([DSAPIInteraction class]);
}

- (void)testShowInteraction
{
    __block DSAPIInteraction *_interaction = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [page.entries[0] listRepliesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *repliesPage) {
            [(DSAPIInteraction *)repliesPage.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIInteraction *interaction) {
                _interaction = interaction;
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
    expect(_interaction).willNot.beNil();
    expect(_interaction).will.beKindOf([DSAPIInteraction class]);
    expect(_interaction[@"direction"]).willNot.beNil();
    expect(_interaction[@"status"]).willNot.beNil();
}

- (void)testShowProperInteractionSubclass
{
    __block DSAPITweet *tweet = nil;
    DSAPICase *twitterCase = (DSAPICase *)[[[DSAPILink alloc] initWithDictionary:@{kHrefKey:@"/api/v2/cases/11", kClassKey:@"case"}] resourceWithSelf];
    
    [twitterCase showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICase *theCase) {
        [theCase listRepliesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            tweet = page.entries[0];
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
    expect(tweet).willNot.beNil();
    expect(tweet).will.beKindOf([DSAPITweet class]);
}


@end
