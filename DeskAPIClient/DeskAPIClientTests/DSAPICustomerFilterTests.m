//
//  DSAPICustomerFilterTests.m
//  DeskAPIClient
//
//  Created by Eldor Khalyknazarov on 4/13/16.
//  Copyright © 2016 Desk.com. All rights reserved.
//

#import "DSAPITestCase.h"

@interface DSAPICustomerFilterTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPICustomerFilterTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListFiltersReturnsAtLeastOneFilter
{
    __block NSArray *_filters = nil;
    
    [DSAPICustomerFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.beGreaterThan(0);
    expect(_filters[0]).will.beKindOf([DSAPICustomerFilter class]);
}

- (void)testListFiltersCanSetPerPage
{
    __block NSArray *_filters = nil;
    [DSAPICustomerFilter listFiltersWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _filters = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_filters.count).will.equal(1);
    expect(_filters[0]).will.beKindOf([DSAPICustomerFilter class]);
}

- (void)testShowFilter
{
    __block DSAPICustomerFilter *_filter = nil;
    [DSAPICustomerFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICustomerFilter *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICustomerFilter *filter) {
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
    expect(_filter).will.beKindOf([DSAPICustomerFilter class]);
    expect(_filter[@"name"]).willNot.beNil();
    expect(_filter[@"position"]).willNot.beNil();
}

- (void)testListCustomers
{
    __block NSArray *_customers = nil;
    [DSAPICustomerFilter listFiltersWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICustomerFilter *)page.entries[0] listCustomersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            _customers = page.entries;
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
    expect(_customers.count).will.beGreaterThan(0);
    expect(_customers[0][@"id"]).willNot.beNil();
    expect(_customers[0]).will.beKindOf([DSAPICustomer class]);
}

@end
