//
//  DSAPICustomerTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 2/4/14.
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

@interface DSAPICustomerTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPICustomerTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testListCustomersReturnsAtLeastOneCustomer
{
    __block NSArray *_customers = nil;
    
    [DSAPICustomer listCustomersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _customers = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_customers.count).will.beGreaterThan(0);
    expect(_customers[0]).will.beKindOf([DSAPICustomer class]);
}


- (void)testListCustomersCanSetPerPage
{
    __block NSArray *_customers = nil;
    
    [DSAPICustomer listCustomersWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _customers = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_customers.count).will.equal(1);
}


- (void)testListCustomersCanRetrieveNextPage
{
    __block DSAPILink *previousLink = nil;
    
    [DSAPICustomer listCustomersWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPICustomer listCustomersWithParameters:nextLink.parameters queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
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


- (void)testShowCustomer
{
    __block DSAPIResource *_customer = nil;
    [DSAPICustomer listCustomersWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICustomer *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICustomer *customer) {
            _customer = customer;
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
    expect(_customer).willNot.beNil();
    expect(_customer).will.beKindOf([DSAPICustomer class]);
    expect(_customer[@"first_name"]).willNot.beNil();
}


- (void)testCreateCustomer
{
    __block DSAPIResource *responseResource = nil;
    [DSAPICustomer createCustomer:[DSAPITestUtils dictionaryFromJSONFile:@"newCustomer"] queue:self.APICallbackQueue success:^(DSAPIResource *newCase) {
        responseResource = newCase;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(responseResource[@"first_name"]).will.equal(@"API");
    expect(responseResource[@"last_name"]).will.equal(@"Customer");
}


- (void)testSearchCustomersByFirstName
{
    __block DSAPIResource *randomCustomer = nil;
    __block NSString *firstName = nil;
    
    [DSAPICustomer searchCustomersWithParameters:@{@"first_name": @"amzad"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSUInteger randomIndex = arc4random() % page.entries.count;
        randomCustomer = page.entries[randomIndex];
        firstName = randomCustomer[@"first_name"];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(randomCustomer).willNot.beNil();
    expect(randomCustomer).will.beKindOf([DSAPICustomer class]);
    expect(firstName.lowercaseString).will.contain(@"amzad");
}


- (void)testSearchCustomersWithEtags
{
// This test is currently broken to due Weak Etags. Should work again when this is fixed:
// https://desk.atlassian.net/browse/AA-30112
//    __block BOOL hitCache = NO;
//    
//    [DSAPICustomer searchCustomersWithParameters:@{@"first_name": @"api"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
//        [DSAPICustomer searchCustomersWithParameters:@{@"first_name": @"api"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
//            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
//            [self done];
//        } notModified:^(DSAPIPage *page) {
//            hitCache = YES;
//            [self done];
//        } failure:^(NSHTTPURLResponse *response, NSError *error) {
//            EXPFail(self, __LINE__, __FILE__, [error description]);
//        }];
//    } failure:^(NSHTTPURLResponse *response, NSError *error) {
//        EXPFail(self, __LINE__, __FILE__, [error description]);
//    }];
//    
//    expect([self isDone]).will.beTruthy();
//    expect(hitCache).to.beTruthy();
}


- (void)testUpdateCustomer
{
    DSAPICustomer *customerToUpdate = (DSAPICustomer *)[[[DSAPILink alloc] initWithDictionary:@{kHrefKey:@"/api/v2/customers/14", kClassKey:@"customer"}] resourceWithSelf];
    __block DSAPIResource *_updatedCustomer = nil;
    
    NSDictionary *updateCustomerDict = [DSAPITestUtils dictionaryFromJSONFile:@"updateCustomer"];
    [customerToUpdate updateWithDictionary:updateCustomerDict queue:self.APICallbackQueue success:^(DSAPICustomer *updatedCustomer) {
        _updatedCustomer = updatedCustomer;
        NSDictionary *revertCustomerDict = [DSAPITestUtils dictionaryFromJSONFile:@"newCustomer"];
        [updatedCustomer updateWithDictionary:revertCustomerDict queue:self.APICallbackQueue success:^(DSAPICustomer *revertedCustomer) {
            expect(revertedCustomer[@"first_name"]).to.equal(@"API");
            [self done];
        } failure:nil];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_updatedCustomer[@"first_name"]).will.equal(@"APIAPI");
    expect(_updatedCustomer).will.beKindOf([DSAPICustomer class]);
}


- (void)testListCustomers
{
    __block NSArray *_cases = nil;
    [DSAPICustomer listCustomersWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICustomer *)page.entries[0] listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *casesPage) {
            _cases = casesPage.entries;
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
    expect(_cases.count).will.beGreaterThan(0);
    expect(_cases[0][@"subject"]).willNot.beNil();
    expect(_cases[0]).will.beKindOf([DSAPICase class]);
}

@end
