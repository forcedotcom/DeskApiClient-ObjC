//
//  DSAPIArticleTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/4/14.
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
#import <DeskCommon/NSDate+DSC.h>

@interface DSAPIArticleTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPIArticleTests

- (void)setUp
{
    [super setUp];

    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListArticles
{
    __block NSArray *_resources = nil;

    [DSAPIArticle listArticlesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _resources = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_resources.count).will.beGreaterThan(0);
    expect(_resources[0]).will.beKindOf([DSAPIArticle class]);
}

- (void)testCreateArticle
{
    __block DSAPIArticle *responseResource = nil;
    __block NSString *subject = [[NSDate date] description];

    [DSAPITopic createTopic:@{@"name":[DSAPITestUtils epochTimeAsString]} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        NSDictionary *params = [self newArticleParamsForTopic:topic andSubject:subject];

        [DSAPIArticle createArticle:params queue:self.APICallbackQueue success:^(DSAPIArticle *article) {
            responseResource = article;
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
    expect(responseResource[@"subject"]).will.equal(subject);
}

- (void)testSearchArticlesBySubject
{
    __block DSAPIArticle *_article = nil;

    __block NSString *searchKey = @"text";
    __block NSString *articleKey = @"subject";
    __block NSString *expectedValue = @"supercalifragilisticexpialidocious";

    __block BOOL created = NO;
    __block BOOL searched = NO;

    [DSAPITopic createTopic:@{@"name":[DSAPITestUtils epochTimeAsString]} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        NSDictionary *params = [self newArticleParamsForTopic:topic andSubject:expectedValue];

        [DSAPIArticle createArticle:params queue:self.APICallbackQueue success:^(DSAPIArticle *article) {
            _article = article;
            created = YES;
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect(created).will.beTruthy();
    expect(_article[articleKey]).will.equal(expectedValue);

    [DSAPIArticle searchArticlesWithParameters:@{searchKey: expectedValue} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _article = [page.entries firstObject];
        searched = YES;
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect(searched).will.beTruthy();
    expect(_article).will.beKindOf([DSAPIArticle class]);
    expect(_article[articleKey]).will.equal(expectedValue);
}

- (void)testSearchArticlesByTopicIds
{
    __block DSAPIArticle *_article = nil;

    __block NSString *searchKey = @"text";
    __block NSString *articleKey = @"subject";
    __block NSString *expectedValue = @"supercalifragilisticexpialidocious";
    __block DSAPITopic *_topic = nil;

    __block BOOL created = NO;
    __block BOOL searched = NO;

    CGFloat delay = 3.0f;

    [DSAPITopic createTopic:@{@"name":[DSAPITestUtils epochTimeAsString]} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        _topic = topic;
        NSDictionary *params = [self newArticleParamsForTopic:topic andSubject:expectedValue];

        [DSAPIArticle createArticle:params queue:self.APICallbackQueue success:^(DSAPIArticle *article) {
            _article = article;
            created = YES;
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect(created).will.beTruthy();
    expect(_article[articleKey]).will.equal(expectedValue);

    // NOTE:  We have to sleep to be able to search by topic ids
    // (Assumption is that we're waiting on ES idexing)
    [NSThread sleepForTimeInterval:delay];

    NSString *topicIds = [_topic idFromSelfLink];
    NSDictionary *parameters = @{searchKey: expectedValue, @"topic_ids": topicIds};

    [DSAPIArticle searchArticlesWithParameters:parameters queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _article = [page.entries firstObject];
        searched = YES;
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect(searched).will.beTruthy();
    expect(_article).will.beKindOf([DSAPIArticle class]);
    expect(_article[articleKey]).will.equal(expectedValue);
}


- (void)testShowArticle
{
    __block DSAPIArticle *_article = nil;

    [DSAPIArticle listArticlesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIArticle *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIArticle *article) {
            _article = article;
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
    expect(_article).willNot.beNil();
    expect(_article).will.beKindOf([DSAPIArticle class]);
}

- (void)testUpdateArticle
{
    __block DSAPIArticle *_updatedArticle = nil;
    __block NSString *subjectKey = @"subject";

    NSString *subject = [[NSDate date] description];
    NSString *expectedSubject = [DSAPITestUtils epochTimeAsString];

    [DSAPITopic createTopic:@{@"name":[DSAPITestUtils epochTimeAsString]} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        NSDictionary *params = [self newArticleParamsForTopic:topic andSubject:subject];

        [DSAPIArticle createArticle:params queue:self.APICallbackQueue success:^(DSAPIArticle *article) {
            [article updateWithDictionary:@{subjectKey:expectedSubject} queue:self.APICallbackQueue success:^(DSAPIArticle *updatedArticle) {
                _updatedArticle = updatedArticle;
                [self done];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_updatedArticle[subjectKey]).will.equal(expectedSubject);
    expect(_updatedArticle).will.beKindOf([DSAPIArticle class]);
}

- (void)testDeleteArticle
{
    NSString *subject = [[NSDate date] description];

    [DSAPITopic createTopic:@{@"name":[DSAPITestUtils epochTimeAsString]} queue:self.APICallbackQueue success:^(DSAPITopic *topic) {
        NSDictionary *params = [self newArticleParamsForTopic:topic andSubject:subject];

        [DSAPIArticle createArticle:params queue:self.APICallbackQueue success:^(DSAPIArticle *article) {
            [article deleteWithParameters:nil queue:self.APICallbackQueue success:^(void) {
                [self done];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
            }];
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

#pragma mark - Article Test Helpers

- (NSDictionary *)newArticleParamsForTopic:(DSAPITopic *)topic andSubject:(NSString *)subject
{
    NSString *topicHref = topic.linkToSelf.href;
    NSDictionary *links = @{@"topic": @{@"href":topicHref, @"class":@"topic"}};
    NSString *now = [[NSDate date] stringWithISO8601Format];

    return @{@"subject": subject,
             @"body": @"body",
             @"publish_at": now,
             @"_links": links};
}

@end
