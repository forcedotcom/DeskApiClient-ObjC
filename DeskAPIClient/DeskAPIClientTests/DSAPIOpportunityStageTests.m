//
//  DSAPIOpportunityStageTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/17/16.
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

@interface DSAPIOpportunityStageTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIOpportunityStageTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListOpportunityStages
{
    __block NSArray *_stages = nil;
    
    [DSAPIOpportunityStage listOpportunityStagesWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _stages = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_stages.count).will.beGreaterThan(0);
    expect(_stages[0]).will.beKindOf([DSAPIOpportunityStage class]);
}

- (void)testShowOpportunityStage
{
    __block DSAPIOpportunityStage *_stage = nil;
    
    [DSAPIOpportunityStage listOpportunityStagesWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIOpportunityStage *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunityStage *stage) {
            _stage = stage;
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
    expect(_stage).willNot.beNil();
    expect(_stage).will.beKindOf([DSAPIOpportunityStage class]);
    expect(_stage[@"id"]).willNot.beNil();
    expect(_stage[@"name"]).willNot.beNil();
    expect(_stage[@"probability"]).willNot.beNil();
    expect(_stage[@"opportunity_stage_type"]).willNot.beNil();
}

@end
