//
//  DSAPIOpportunityTimelineTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/19/16.
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
#import "DSAPITestsOpportunityHelpers.h"

@interface DSAPIOpportunityTimelineTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;
@property (strong, nonatomic) DSAPIOpportunity *opportunity;
@property (strong, nonatomic) DSAPITestsOpportunityHelpers *helpers;

@end

@implementation DSAPIOpportunityTimelineTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
    
    _helpers = [DSAPITestsOpportunityHelpers new];
    _helpers.apiClient = _client;
    _helpers.testCase = self;
    _helpers.timeout = 10.0f;
    
    // -- Create Opportunity --
    self.opportunity = [self.helpers createOpportunity];
}


- (void)tearDown
{
    [super tearDown];
    
    // -- Delete Opportunity --
    // [self.helpers deleteOpportunity:self.opportunity]; // TODO: uncomment when user has permission to delete opportunity
}


- (void)testShowTimeline
{
    // -- List Timeline --
    XCTestExpectation *listTimelineExpectation = [self expectationWithDescription:@"List Timeline"];
    __block NSArray *_timelineArray = nil;
    __block DSAPIOpportunityTimeline *_timeline = nil;
    
    [self.opportunity listTimelineWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _timelineArray = page.entries;
        [listTimelineExpectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [listTimelineExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
    // -- End of List Timeline --
    
    // -- Show Timeline --
    [(DSAPIOpportunityTimeline *)_timelineArray.firstObject showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunityTimeline *timeline) {
        _timeline = timeline;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    // -- End of Show Timeline --
    
    // -- Assertion
    expect([self isDone]).will.beTruthy();
    expect(_timeline).willNot.beNil();
    expect(_timeline).will.beKindOf([DSAPIOpportunityTimeline class]);
}

@end
