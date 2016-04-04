//
//  DSAPICompanyFilterTests.m
//  DeskAPIClient
//
//  Created by Eldor Khalyknazarov on 4/4/16.
//  Copyright © 2016 Desk.com. All rights reserved.
//

#import "DSAPITestCase.h"

@interface DSAPICompanyFilterTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPICompanyFilterTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListFiltersReturnsAtLeastOneFilter
{
    __block NSArray *_filters = nil;
    
    [DSAPICompanyFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.beGreaterThan(0);
    expect(_filters[0]).will.beKindOf([DSAPICompanyFilter class]);
}

- (void)testListFiltersCanSetPerPage
{
    __block NSArray *_filters = nil;
    [DSAPICompanyFilter listFiltersWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.equal(1);
    expect(_filters[0]).will.beKindOf([DSAPICompanyFilter class]);
}

- (void)testShowFilter
{
    __block DSAPICompanyFilter *_filter = nil;
    [DSAPICompanyFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICompanyFilter *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICompanyFilter *filter) {
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
    expect(_filter).will.beKindOf([DSAPICompanyFilter class]);
    expect(_filter[@"name"]).willNot.beNil();
    expect(_filter[@"position"]).willNot.beNil();
}

- (void)testListCompanies
{
    __block NSArray *_companies = nil;
    [DSAPICompanyFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICompanyFilter *)page.entries[0] listCompaniesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            _companies = page.entries;
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
    expect(_companies.count).will.beGreaterThan(0);
    expect(_companies[0][@"name"]).willNot.beNil();
    expect(_companies[0]).will.beKindOf([DSAPICompany class]);
}

@end
