//
//  DSAPIResourceTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/20/13.
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

@interface DSAPIResourceTests : DSAPITestCase

@property (nonatomic, strong) DSAPIResource *resourceFixture;
@property (nonatomic, strong) DSAPIResource *replies;
@property (nonatomic, strong) DSAPILink *linkToCases;
@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIResourceTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:3.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
    _resourceFixture = [DSAPITestUtils resourceFromJSONFile:@"case6"];
    _replies = [DSAPITestUtils resourceFromJSONFile:@"case41replies"];
    _linkToCases = [[DSAPILink alloc] initWithDictionary:@{kHrefKey : @"/api/v2/cases",
                                                           kClassKey : @"case"}];
}
- (void)testInitializationFromDictionary
{
    expect([_resourceFixture[@"subject"] length]).to.beGreaterThan(0);
}

- (void)testInitializationFromDictionaryAndBaseURL
{
    DSAPIResource *resource = [[DSAPIResource alloc] initWithDictionary:[DSAPITestUtils dictionaryFromJSONFile:@"case6"] baseURL:[NSURL URLWithString:@"https://www.google.com"]];

    expect([resource.linkToSelf.URL absoluteString]).to.contain(@"https://www.google.com");
}

- (void)testThatResourceHasALinkForSelf
{
    DSAPILink *selfLink = _resourceFixture.linkToSelf;
    expect(selfLink).toNot.beNil();
    expect(selfLink.href).to.equal(@"/api/v2/cases/6");
}

- (void)testThatResourceHasALinkForCustomer
{
    DSAPILink *customerLink = [_resourceFixture linkForRelation:@"customer"];
    expect(customerLink).toNot.beNil();
    expect(customerLink.href).to.equal(@"/api/v2/customers/9");
}

- (void)testThatResourceHasAnEmbeddedCustomer
{
    expect([_resourceFixture resourceForRelation:@"customer"]).toNot.beNil();
}

- (void)testThatRepliesHasAResourceForEntries
{
    expect([[_replies resourcesForRelation:@"entries"] count]).to.equal(2);
}

- (void)testThatNullPropertiesReturnNil
{
    expect(_resourceFixture[@"external_id"]).to.beNil();
}

- (void)testThatLinksReturnNil
{
    expect([_resourceFixture linkForRelation:@"assigned_user"]).to.beNil();
}

#pragma mark - Generic CRUD Methods
- (void)testListResourcesReturnsAtLeastOneResource
{
    __block NSArray *_resources = nil;
    [DSAPIResource listResourcesAt:_linkToCases parameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _resources = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_resources.count).will.beGreaterThan(0);
    expect(_resources[0]).will.beKindOf([DSAPIResource class]);
    expect(((DSAPIResource *)_resources[0]).linkToSelf.className).to.equal(@"case");
}

- (void)testListResourcesCanEmbed
{
    __block DSAPIResource *customer = nil;
    
    [DSAPIResource listResourcesAt:_linkToCases parameters:@{@"embed" : @"customer"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        customer = [page.entries[0] resourceForRelation:@"customer"];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(customer).willNot.beNil();
    expect(customer.linkToSelf.className).will.equal(@"customer");
}

- (void)testListResourcesCanSetPerPage
{
    __block NSArray *_resources = nil;
    [DSAPIResource listResourcesAt:_linkToCases parameters:@{@"per_page" : @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _resources = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_resources.count).will.equal(1);
}

- (void)testGetCasesCanRetrieveNextPage
{
    __block DSAPILink *nextNextLink = nil;
    [DSAPIResource listResourcesAt:_linkToCases parameters:@{@"per_page" : @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPIResource listResourcesAt:_linkToCases parameters:nextLink.parameters queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
            nextNextLink = nextPage.links[@"next"][0];
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
    expect([nextNextLink.parameters[@"page"] integerValue]).will.equal(3);
    expect([nextNextLink.parameters[@"per_page"] integerValue]).will.equal(1);
}

- (void)testSearchResources
{
    __block DSAPIResource *randomCase = nil;
    [DSAPIResource searchResourcesAt:_linkToCases parameters:@{@"subject" : @"getting"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSUInteger randomIndex = arc4random() % page.entries.count;
        randomCase = page.entries[randomIndex];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect([[randomCase objectForKeyedSubscript:@"subject"] lowercaseString]).will.contain(@"getting");
}

- (void)testshowResourceReturnsNonNil
{
    __block DSAPIResource *_resource = nil;
    [DSAPIResource listResourcesAt:_linkToCases parameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIResource *resource) {
            _resource = resource;
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
    expect(_resource).willNot.beNil();
}

- (void)testCreateResource
{
    __block DSAPIResource *responseResource = nil;
    [DSAPIResource createResource:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] link:_linkToCases queue:self.APICallbackQueue success:^(DSAPIResource *resource) {
        responseResource = resource;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(responseResource[@"subject"]).will.equal(@"Creating a case via the API");
}

- (void)testSelfLink
{
    expect(_resourceFixture.linkToSelf.href).to.equal(@"/api/v2/cases/6");
    expect(_resourceFixture.linkToSelf.className).to.equal(@"case");
}

- (void)testUpdateResource
{
    __block DSAPIResource *anUpdatedCase = nil;
    [DSAPIResource createResource:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] link:_linkToCases queue:self.APICallbackQueue success:^(DSAPIResource *resource) {
        NSDictionary *updateCaseDict = [DSAPITestUtils dictionaryFromJSONFile:@"updateCase"];
        [resource updateWithDictionary:updateCaseDict queue:self.APICallbackQueue success:^(DSAPIResource *updatedCase) {
            anUpdatedCase = updatedCase;
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
    expect(anUpdatedCase[@"subject"]).will.equal(@"Updated");
}

- (void)testNSCodingCompliance
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_resourceFixture];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"resource_fixture"];
    [defaults synchronize];
    NSData *restoredData = [defaults objectForKey:@"resource_fixture"];
    DSAPIResource *resource = [NSKeyedUnarchiver unarchiveObjectWithData:restoredData];
    expect(resource.dictionary).to.equal(_resourceFixture.dictionary);
}

- (void)testValueForKeyWhenDictionaryHasKey
{
    DSAPIResource *newCase = [[DSAPICase alloc] initWithDictionary:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"]];
    expect([newCase valueForKey:@"subject"]).toNot.beNil();
}

- (void)testValueForKeyWhenAccessingProperty
{
    NSDictionary *dictionary = [DSAPITestUtils dictionaryFromJSONFile:@"case6"];
    DSAPICase *newCase = [[DSAPICase alloc] initWithDictionary:dictionary];
    expect([newCase valueForKey:@"dictionary"]).to.equal(dictionary);
    expect([newCase valueForKey:@"linkToSelf"]).toNot.beNil();
    expect([newCase valueForKey:@"links"]).toNot.beNil();
    expect([newCase valueForKey:@"links"][@"self"]).to.beKindOf([NSArray class]);
    expect([newCase valueForKey:@"_links"]).toNot.beNil();
    expect([newCase valueForKey:@"_links"][@"self"]).to.beKindOf([NSDictionary class]);
}

- (void)testResourceWithHrefAndClass
{
    DSAPIResource *resource = [DSAPIResource resourceWithHref:@"/api/v2/filters/185"
                                                    className:@"filter"];

    expect(resource).to.beKindOf([DSAPIFilter class]);
    expect(resource.linkToSelf.href).to.equal(@"/api/v2/filters/185");
    expect(resource.linkToSelf.className).to.equal(@"filter");
}

- (void)testResourceWithIdAndClass
{
    DSAPIResource *resource = [DSAPIResource resourceWithId:@"185"
                                                  className:@"filter"];

    expect(resource).to.beKindOf([DSAPIFilter class]);
    expect(resource.linkToSelf.href).to.equal(@"/api/v2/filters/185");
    expect(resource.linkToSelf.className).to.equal(@"filter");
}

@end
