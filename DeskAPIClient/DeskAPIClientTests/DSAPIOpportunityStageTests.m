//
//  DSAPIOpportunityStageTests.m
//  DeskAPIClient
//
//  Created by Eldor Khalyknazarov on 5/17/16.
//  Copyright © 2016 Desk.com. All rights reserved.
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
