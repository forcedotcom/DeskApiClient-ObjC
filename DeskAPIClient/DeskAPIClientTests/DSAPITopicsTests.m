//
//  DSAPITopicsTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/2/14.
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

@interface DSAPITopicsTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPITopicsTests

- (void)setUp
{
    [super setUp];

    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListTopics
{
    __block NSArray *_resources = nil;

    [DSAPITopic listTopicsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _resources = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_resources.count).will.beGreaterThan(0);
    expect(_resources[0]).will.beKindOf([DSAPITopic class]);
}

- (void)testCreateTopic
{
    __block DSAPITopic *responseResource = nil;

    NSString *name = [[NSDate date] description];
    [DSAPITopic createTopic:@{@"name":name} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        responseResource = topic;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(responseResource[@"name"]).will.equal(name);
}

- (void)testShowTopic
{
    __block DSAPITopic *_topic = nil;

    [DSAPITopic listTopicsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITopic *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
            _topic = topic;
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
    expect(_topic).willNot.beNil();
    expect(_topic).will.beKindOf([DSAPITopic class]);
}

- (void)testUpdateTopic
{
    __block DSAPITopic *_updatedTopic = nil;

    NSString *originalName = [DSAPITestUtils epochTimeAsString];
    NSString *expectedName = [[NSDate date] description];

    [DSAPITopic createTopic:@{@"name":originalName} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        [topic updateWithDictionary:@{@"name":expectedName} queue:self.APICallbackQueue success:^(DSAPITopic *updatedTopic) {
            _updatedTopic = updatedTopic;
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
    expect(_updatedTopic[@"name"]).will.equal(expectedName);
    expect(_updatedTopic).will.beKindOf([DSAPITopic class]);
}

- (void)testDeleteTopic
{
    NSString *name = @"foo";

    [DSAPITopic createTopic:@{@"name":name} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        [topic deleteWithParameters:nil queue:self.APICallbackQueue success:^(void) {
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
}

- (void)testListArticles
{
    __block NSArray *_articles = nil;
    [DSAPITopic listTopicsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITopic *)page.entries[0] listArticlesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *articlesPage) {
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
    expect(_articles[0][@"body"]).willNot.beNil();
    expect(_articles[0]).will.beKindOf([DSAPIArticle class]);
}

@end
