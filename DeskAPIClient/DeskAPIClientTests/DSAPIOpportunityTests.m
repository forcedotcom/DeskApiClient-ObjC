//
//  DSAPIOpportunityTests.m
//  DeskAPIClient
//
//  Created by Eldor Khalyknazarov on 5/16/16.
//  Copyright © 2016 Desk.com. All rights reserved.
//

#import "DSAPITestCase.h"
#import "NSDate+DSC.h"

@interface DSAPIOpportunityTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPIOpportunityTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
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
    
    [DSAPIOpportunity listOpportunitiesWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPIOpportunity listOpportunitiesWithParameters:nextLink.parameters client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
            previousLink = nextPage.links[@"previous"][0];
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
    expect([previousLink.parameters[@"page"] integerValue]).will.equal(1);
    expect([previousLink.parameters[@"per_page"] integerValue]).will.equal(1);
}


- (void)testShowOpportunity
{
    __block DSAPIOpportunity *_opportunity = nil;
    
    [DSAPIOpportunity listOpportunitiesWithParameters:@{@"per_page": @1} client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIOpportunity *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunity *opportunity) {
            _opportunity = opportunity;
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
    expect(_opportunity).willNot.beNil();
    expect(_opportunity).will.beKindOf([DSAPIOpportunity class]);
}


- (void)testCreateOpportunity
{
    __block DSAPIOpportunity *responseResource = nil;
    
    NSDictionary *params = [self sampleOpportunityDictionary];
    [DSAPIOpportunity createOpportunity:params client:self.client queue:self.APICallbackQueue success:^(DSAPIOpportunity *opportunity) {
        responseResource = opportunity;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(responseResource[@"name"]).will.equal(params[@"name"]);
}


- (void)testUpdateOpportunity
{
    __block DSAPIOpportunity *_updatedOpportunity = nil;
    
    NSString *opportunityName = [[NSDate date] description];
    [DSAPIOpportunity createOpportunity:[self sampleOpportunityDictionary] client:self.client queue:self.APICallbackQueue success:^(DSAPIOpportunity *opportunity) {
        [opportunity updateWithDictionary:@{@"name":opportunityName} queue:self.APICallbackQueue success:^(DSAPIOpportunity *updatedOpportunity) {
            _updatedOpportunity = updatedOpportunity;
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
    expect(_updatedOpportunity[@"name"]).will.equal(opportunityName);
    expect(_updatedOpportunity).will.beKindOf([DSAPIOpportunity class]);
}

- (void)testSearchOpportunitiesByName
{
    __block DSAPIOpportunity *opportunity = nil;
    __block NSString *opportunityName = nil;
    
    [DSAPIOpportunity listOpportunitiesWithParameters:nil client:self.client queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSUInteger randomIndex = arc4random() % page.entries.count;
        DSAPIOpportunity *randomOpportunity = (DSAPIOpportunity *)page.entries[randomIndex];
        opportunityName = randomOpportunity[@"name"];
        [DSAPIOpportunity searchOpportunitiesWithParameters:@{@"q": opportunityName}
                                             client:self.client
                                              queue:self.APICallbackQueue
                                            success:^(DSAPIPage *page) {
                                                opportunity = [page.entries firstObject];
                                                [self done];
                                            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                EXPFail(self, __LINE__, __FILE__, [error description]);
                                            }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(opportunity).willNot.beNil();
    expect(opportunity).will.beKindOf([DSAPIOpportunity class]);
    expect(opportunity[@"name"]).will.contain(opportunityName);
}

#pragma mark - Private Methods
- (NSDictionary *)sampleOpportunityDictionary {
    NSString *opportunityName = [[NSDate date] description];
    return @{@"name": opportunityName, @"description": @"Sample description", @"amount": @"3,002.00", @"close_date": [[NSDate distantFuture] stringWithISO8601Format]};
}

@end
