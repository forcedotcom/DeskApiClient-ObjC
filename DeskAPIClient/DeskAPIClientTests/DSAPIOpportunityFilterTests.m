//
//  DSAPIOpportunityFilterTests.m
//  DeskAPIClient
//
//  Created by Eldor Khalyknazarov on 5/16/16.
//  Copyright © 2016 Desk.com. All rights reserved.
//

#import "DSAPITestCase.h"

@interface DSAPIOpportunityFilterTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIOpportunityFilterTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListFiltersReturnsAtLeastOneFilter
{
    __block NSArray *_filters = nil;
    
    [DSAPIOpportunityFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.beGreaterThan(0);
    expect(_filters[0]).will.beKindOf([DSAPIOpportunityFilter class]);
}

- (void)testListFiltersCanSetPerPage
{
    __block NSArray *_filters = nil;
    [DSAPIOpportunityFilter listFiltersWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.equal(1);
    expect(_filters[0]).will.beKindOf([DSAPIOpportunityFilter class]);
}

- (void)testShowFilter
{
    __block DSAPIOpportunityFilter *_filter = nil;
    [DSAPIOpportunityFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIOpportunityFilter *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunityFilter *filter) {
            _filter = filter;
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
    expect(_filter).willNot.beNil();
    expect(_filter).will.beKindOf([DSAPIOpportunityFilter class]);
    expect(_filter[@"name"]).willNot.beNil();
    expect(_filter[@"position"]).willNot.beNil();
}

- (void)testListOpportunities
{
    __block NSArray *_opportunities = nil;
    [DSAPIOpportunityFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIOpportunityFilter *)page.entries[0] listOpportunitiesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            _opportunities = page.entries;
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
    expect(_opportunities.count).will.beGreaterThan(0);
    expect(_opportunities[0][@"id"]).willNot.beNil();
    expect(_opportunities[0]).will.beKindOf([DSAPIOpportunityFilter class]);
}

@end
