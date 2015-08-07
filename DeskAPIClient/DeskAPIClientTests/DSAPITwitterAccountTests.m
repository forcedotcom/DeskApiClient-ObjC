//
//  DSAPITwitterAccountTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/13/14.
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
#import <DeskCommonTest/DeskCommonTest.h>

@interface DSAPITwitterAccountTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPITwitterAccountTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListTwitterAccounts
{
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    __block NSArray *_twitterAccounts = nil;
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _twitterAccounts = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_twitterAccounts.count).will.beGreaterThan(0);
    expect(_twitterAccounts[0]).will.beKindOf([DSAPITwitterAccount class]);
}

- (void)testShowTwitterAccount
{
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts-1"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts/1"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"GET"];
    
    __block DSAPITwitterAccount *_twitterAccount = nil;
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITwitterAccount *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPITwitterAccount *twitterAct) {
            _twitterAccount = twitterAct;
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
    expect(_twitterAccount).willNot.beNil();
    expect(_twitterAccount).will.beKindOf([DSAPITwitterAccount class]);
    expect(_twitterAccount[@"handle"]).willNot.beNil();
}

- (void)testListTweets
{
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts-1-tweets"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"tweets"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"GET"];
    
    __block NSArray *_tweets = nil;
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITwitterAccount *)page.entries[0] listTweetsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *tweetsPage) {
            _tweets = tweetsPage.entries;
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
    expect(_tweets.count).will.beGreaterThan(0);
    expect(_tweets[0][@"body"]).willNot.beNil();
    expect(_tweets[0]).will.beKindOf([DSAPITweet class]);
}

- (void)testShowTweet
{
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts-1-tweets"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"tweets"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"GET"];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts-1-tweets-45"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"tweets/45"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"GET"];
    
    __block DSAPITweet *_tweet = nil;
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITwitterAccount *)page.entries[0] listTweetsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *tweetsPage) {
            [(DSAPITweet *)tweetsPage.entries[0] showWithParameters:nil
                                                              queue:self.APICallbackQueue
                                                            success:^(DSAPITweet *tweet) {
                                                                _tweet = tweet;
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
    expect(_tweet).willNot.beNil();
    expect(_tweet).will.beKindOf([DSAPITweet class]);
    expect(_tweet[@"body"]).willNot.beNil();
}

- (void)testPostAction
{
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts-1-tweets"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"tweets"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"GET"];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"POST-twitter_accounts-1-tweets-45-retweet"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"actions"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"POST"];
    
    __block DSAPITweet *_retweet = nil;
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITwitterAccount *)page.entries[0] listTweetsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *tweetsPage) {
            [(DSAPITweet *)tweetsPage.entries[0] postAction:@{@"action_type":@"retweet"}
                                                      queue:self.APICallbackQueue
                                                    success:^(DSAPITweet *tweet) {
                                                        _retweet = tweet;
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
    expect(_retweet).willNot.beNil();
    expect(_retweet).will.beKindOf([DSAPITweet class]);
    expect(_retweet[@"body"]).willNot.beNil();
}

- (void)testCreateTweet
{
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"POST-twitter_accounts-1-tweets-67"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"tweets"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"POST"];
    
    __block DSAPITweet *_createdTweet = nil;
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITwitterAccount *)page.entries[0] createTweet:@{@"body":@"test from api"}
                                                      queue:self.APICallbackQueue
                                                    success:^(DSAPITweet *tweet) {
                                                        _createdTweet = tweet;
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
    expect(_createdTweet).willNot.beNil();
    expect(_createdTweet).will.beKindOf([DSAPITweet class]);
    expect(_createdTweet[@"body"]).will.equal(@"test from api");
}

- (void)testShowFollow
{
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts-31986-follows-desk"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"follows"];
    
    __block DSAPITwitterFollow *_follow = nil;
    
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITwitterAccount *)page.entries[0] showFollowWithUsername:@"desk"
                                                            parameters:nil
                                                                 queue:self.APICallbackQueue
                                                               success:^(DSAPITwitterFollow *twitterFollow) {
                                                                   _follow = twitterFollow;
                                                                   [self done];
                                                               } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                                   EXPFail(self, __LINE__, __FILE__, [error description]);
                                                               }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_follow).willNot.beNil();
    expect(_follow).will.beKindOf([DSAPITwitterFollow class]);
    expect(_follow[@"handle"]).will.equal(@"desk");
}

- (void)testCreateFollow
{
    [OHHTTPStubs stubResponseFromFixtureName:@"twitter_accounts"
                              withStatusCode:DSC_HTTP_STATUS_OK
                                      andTag:@"twitter_accounts"
                            withTagMatchType:DSCMatchTypeHasSuffix];
    
    [OHHTTPStubs stubResponseFromFixtureName:@"POST-twitter_accounts-31986-follows"
                              withStatusCode:DSC_HTTP_STATUS_CREATED
                                      andTag:@"follows"
                            withTagMatchType:DSCMatchTypeHasSuffix
                                 andHTTPVerb:@"POST"];
    
    [OHHTTPStubs stubResponseFromFixtureName:nil
                              withStatusCode:DSC_HTTP_STATUS_NO_CONTENT
                                 andHTTPVerb:@"DELETE"];
    
    [DSAPITwitterAccount listTwitterAccountsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPITwitterAccount *)page.entries[0] createFollow:@{@"handle":@"foo"}
                                                       queue:self.APICallbackQueue
                                                     success:^(DSAPITwitterFollow *twitterFollow) {
                                                         [twitterFollow deleteWithParameters:nil
                                                                                       queue:self.APICallbackQueue
                                                                                     success:^{
                                                                                         expect(twitterFollow).toNot.beNil();
                                                                                         expect(twitterFollow).to.beKindOf([DSAPITwitterFollow class]);
                                                                                         expect(twitterFollow[@"handle"]).to.equal(@"foo");
                                                                                         expect(twitterFollow).to.beTruthy();
                                                                                         [self done];
                                                                                     } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                                                         EXPFail(self, __LINE__, __FILE__, [error description]);
                                                                                     }];
                                                     }
                                                     failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                         EXPFail(self, __LINE__, __FILE__, [error description]);
                                                     }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
}

@end
