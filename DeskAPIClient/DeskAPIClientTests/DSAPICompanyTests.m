//
//  DSAPICompanyTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 8/15/14.
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

@interface DSAPICompanyTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPICompanyTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testListCompaniesReturnsAtLeastOneCompany
{
    __block NSArray *_companies = nil;
    
    [DSAPICompany listCompaniesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _companies = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_companies.count).will.beGreaterThan(0);
    expect(_companies[0]).will.beKindOf([DSAPICompany class]);
}


- (void)testListCompaniesCanSetPerPage
{
    __block NSArray *_companies = nil;
    
    [DSAPICompany listCompaniesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _companies = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_companies.count).will.equal(1);
}


- (void)testListCompaniesCanRetrieveNextPage
{
    __block DSAPILink *previousLink = nil;
    
    [DSAPICompany listCompaniesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPICompany listCompaniesWithParameters:nextLink.parameters queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
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


- (void)testShowCompany
{
    __block DSAPICompany *_company = nil;
    
    [DSAPICompany listCompaniesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICompany *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICompany *company) {
            _company = company;
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
    expect(_company).willNot.beNil();
    expect(_company).will.beKindOf([DSAPICompany class]);
}


- (void)testCreateCompany
{
    __block DSAPICompany *responseResource = nil;
    
    NSString *companyName = [[NSDate date] description];
    [DSAPICompany createCompany:@{@"name":companyName} queue:self.APICallbackQueue success:^(DSAPICompany *company) {
        responseResource = company;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(responseResource[@"name"]).will.equal(companyName);
}


- (void)testUpdateCompany
{
    __block DSAPICompany *_updatedCompany = nil;
    
    NSString *companyName = [[NSDate date] description];
    [DSAPICompany createCompany:@{@"name":[[NSDate date] description]} queue:self.APICallbackQueue success:^(DSAPICompany *company) {
        [company updateWithDictionary:@{@"name":companyName} queue:self.APICallbackQueue success:^(DSAPICompany *updatedCompany) {
            _updatedCompany = updatedCompany;
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
    expect(_updatedCompany[@"name"]).will.equal(companyName);
    expect(_updatedCompany).will.beKindOf([DSAPICompany class]);
}


- (void)testSearchCompaniesByName
{
    __block DSAPICompany *company = nil;
    __block NSString *companyName = nil;
    
    [DSAPICompany listCompaniesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSUInteger randomIndex = arc4random() % page.entries.count;
        DSAPICompany *randomCompany = (DSAPICompany *)page.entries[randomIndex];
        companyName = randomCompany[@"name"];
        [DSAPICompany searchCompaniesWithParameters:@{@"q": [NSString stringWithFormat:@"\"%@\"", companyName]}
                                              queue:self.APICallbackQueue
                                            success:^(DSAPIPage *page) {
                                                company = [page.entries firstObject];
                                                [self done];
                                            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                EXPFail(self, __LINE__, __FILE__, [error description]);
                                            }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(company).willNot.beNil();
    expect(company).will.beKindOf([DSAPICompany class]);
    expect(company[@"name"]).will.contain(companyName);
}


- (void)testListCases
{
    __block DSAPIPage *_page = nil;
    [DSAPICompany listCompaniesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICompany *)page.entries[0] listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *casesPage) {
            _page = casesPage;
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
    expect(_page.pageNumber).will.equal(1);
    expect(_page.linkToFirstPage.href).will.contain(@"cases");
    expect(_page.linkToFirstPage.href).will.contain(@"companies");
}


@end
