//
//  DSAPIBrandTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 12/5/14.
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

#import <UIKit/UIKit.h>
#import "DSAPITestCase.h"

@interface DSAPIBrandTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIBrandTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:3.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}
- (void)testListBrands
{
    __block NSArray *_resources = nil;

    [DSAPIBrand listBrandsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _resources = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_resources.count).will.beGreaterThan(0);
    expect(_resources[0]).will.beKindOf([DSAPIBrand class]);
}

- (void)testShowBrand
{
    __block DSAPIBrand *_brand = nil;

    [DSAPIBrand listBrandsWithParameters:@{kPerPageKey : @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIBrand *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIBrand *brand) {
            _brand = brand;
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
    expect(_brand).willNot.beNil();
    expect(_brand).will.beKindOf([DSAPIBrand class]);
}

- (void)testListTopics
{
    __block NSArray *_topics = nil;
    [DSAPIBrand listBrandsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIBrand *)page.entries[0] listTopicsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *topicsPage) {
            _topics = topicsPage.entries;
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
    expect(_topics.count).will.beGreaterThan(0);
    expect(_topics[0][@"name"]).willNot.beNil();
    expect(_topics[0]).will.beKindOf([DSAPITopic class]);
}

- (void)testListArticles
{
    __block NSArray *_articles = nil;
    [DSAPIBrand listBrandsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIBrand *)page.entries[0] listArticlesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *articlesPage) {
            _articles = articlesPage.entries;
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
    expect(_articles.count).will.beGreaterThan(0);
    expect(_articles[0][@"subject"]).willNot.beNil();
    expect(_articles[0]).will.beKindOf([DSAPIArticle class]);
}

@end
