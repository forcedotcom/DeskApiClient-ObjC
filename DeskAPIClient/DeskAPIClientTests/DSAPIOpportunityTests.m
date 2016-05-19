//
//  DSAPIOpportunityTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/16/16.
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

@interface DSAPIOpportunityTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;
@property (strong, nonatomic) DSAPIOpportunity *opportunity;
@property (strong, nonatomic) DSAPITestsOpportunityHelpers *helpers;

@end

@implementation DSAPIOpportunityTests

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


- (void)testListOpportunitiesReturnsAtLeastOneOpportunity
{
    __block NSArray *_opportunities = nil;
    
    [DSAPIOpportunity listOpportunitiesWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _opportunities = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    // -- Assertion --
    expect([self isDone]).will.beTruthy();
    expect(_opportunities.count).will.beGreaterThan(0);
    expect(_opportunities[0]).will.beKindOf([DSAPIOpportunity class]);
}


- (void)testListOpportunitiesCanSetPerPage
{
    __block NSArray *_opportunities = nil;
    
    [DSAPIOpportunity listOpportunitiesWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _opportunities = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_opportunities.count).will.equal(1);
}


- (void)testListOpportunitiesCanRetrieveNextPage
{
    __block DSAPILink *previousLink = nil;
    __block DSAPILink *nextLink = nil;
    
    // -- Create Opportunity --
    [self.helpers createOpportunity];
    // -- End of Create Opportunity --
    
    // -- List Opportunities --
    XCTestExpectation *listOpportunitiesExpectation = [self expectationWithDescription:@"List Opportunities"];
    
    [DSAPIOpportunity listOpportunitiesWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        nextLink = page.links[@"next"][0];
        [listOpportunitiesExpectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [listOpportunitiesExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
    // -- End of List Opportunities --
    
    // -- List Opportunities --
    [DSAPIOpportunity listOpportunitiesWithParameters:nextLink.parameters client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
        previousLink = nextPage.links[@"previous"][0];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    // -- End of List Opportunities --
    
    expect([self isDone]).will.beTruthy();
    expect([previousLink.parameters[@"page"] integerValue]).will.equal(1);
    expect([previousLink.parameters[@"per_page"] integerValue]).will.equal(1);
}


- (void)testShowOpportunity
{
    __block DSAPIOpportunity *returnedOpportunity = nil;
    
    [self.opportunity showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunity *newOpportunity) {
        returnedOpportunity = newOpportunity;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(returnedOpportunity).willNot.beNil();
    expect(returnedOpportunity).will.beKindOf([DSAPIOpportunity class]);
}


- (void)testCreateOpportunity
{
    expect(self.opportunity).will.beKindOf([DSAPIOpportunity class]);
}


- (void)testUpdateOpportunity
{
    __block DSAPIOpportunity *_updatedOpportunity = nil;
    
    NSString *opportunityName = [[NSDate date] description];
    [self.opportunity updateWithDictionary:@{@"name":opportunityName} queue:self.APICallbackQueue success:^(DSAPIOpportunity *updatedOpportunity) {
        _updatedOpportunity = updatedOpportunity;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_updatedOpportunity[@"name"]).will.equal(opportunityName);
    expect(_updatedOpportunity).will.beKindOf([DSAPIOpportunity class]);
}


- (void)testSearchOpportunitiesByName
{
    __block DSAPIOpportunity *returnedOpportunity = nil;
    __block NSString *opportunityName = self.opportunity[@"name"];
    
    [DSAPIOpportunity searchOpportunitiesWithParameters:@{@"q": opportunityName} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        returnedOpportunity = [page.entries firstObject];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(returnedOpportunity).willNot.beNil();
    expect(returnedOpportunity).will.beKindOf([DSAPIOpportunity class]);
    expect(returnedOpportunity[@"name"]).will.contain(opportunityName);
}


- (void)testCreateActivity
{
    DSAPIOpportunityActivity *activity = [self.helpers createActivityWithOpportunity:self.opportunity];
    
    expect(activity).willNot.beNil();
    expect(activity).will.beKindOf([DSAPIOpportunityActivity class]);
}


- (void)testListActivities
{
    __block NSArray *_activities = nil;
    
    [self.helpers createActivityWithOpportunity:self.opportunity];
    [self.helpers createActivityWithOpportunity:self.opportunity];
    
    // -- Show Opportunity --
    XCTestExpectation *showOpportunityExpectation = [self expectationWithDescription:@"Show Opportunity"];
    
    [self.opportunity showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunity *opportunity) {
        self.opportunity = opportunity;
        [showOpportunityExpectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [showOpportunityExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
    // -- End of Show Opportunity --
    
    // -- List Actitivies --
    [self.opportunity listActivitiesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _activities = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    // -- End of List Activities --
    
    // -- Assertion --
    expect([self isDone]).will.beTruthy();
    expect(_activities).willNot.beNil();
    expect(_activities.count == 2);
    expect(_activities[0]).will.beKindOf([DSAPIOpportunityActivity class]);
}


- (void)testListAttachments
{
    DSAPIOpportunityActivity *activity = [self.helpers createActivityWithOpportunity:self.opportunity];
    DSAPIAttachment *attachment = [self.helpers createAttachmentWithActivity:activity];
    
    __block NSArray *_attachments = nil;
    
    [[self.helpers refreshOpportunity:self.opportunity] listAttachmentsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _attachments = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_attachments).willNot.beNil();
    expect(_attachments[0]).will.beKindOf([DSAPIAttachment class]);
    expect([_attachments[0][@"file_name"] isEqualToString:attachment[@"file_name"]]);
}


- (void)testListTimeline
{
    __block NSArray *_timeline = nil;
    
    [self.opportunity listTimelineWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _timeline = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_timeline).willNot.beNil();
    expect(_timeline[0]).will.beKindOf([DSAPIOpportunityTimeline class]);
}

@end
