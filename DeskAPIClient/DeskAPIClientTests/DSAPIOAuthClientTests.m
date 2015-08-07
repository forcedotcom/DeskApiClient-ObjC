//
//  DSAPIOAuthClientTests.m
//  DeskAPIClientTests
//
//  Created by Desk.com on 9/17/13.
//  Copyright (c) 2015 Salesforce, Inc All rights reserved.
//

#import "DSAPITestCase.h"
#import "DSAPIURLRequestSerialization.h"

@interface DSAPIOAuthClientTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPIOAuthClientTests

- (void)setUp
{
    [super setUp];
    _client = [DSAPITestUtils APIClientOAuthUnauthorized];

}
- (void)testInitializationOfOAuthClient
{
    expect(_client).toNot.beNil();
    expect(_client).to.beKindOf([DSAPIClient class]);
}

- (void)testInitializationOfOAuthTokenFromParameters
{
    NSDate *today = [NSDate date];
    DSAPIOAuth1Token *token = [[DSAPIOAuth1Token alloc] initWithKey:@"key" secret:@"secret" session:@"session" expiration:today renewable:NO];
    
    expect(token.key).to.equal(@"key");
    expect(token.secret).to.equal(@"secret");
    expect(token.session).to.equal(@"session");
    expect(token.expired).toNot.beTruthy();
    expect(token.renewable).toNot.beTruthy();
}

- (void)testInitializationOfOAuthTokenFromQueryString
{
    NSString *queryString = @"oauth_token=key&oauth_token_secret=secret&oauth_session_handle=session&oauth_duration=10000&oauth_token_renewable=true";
    DSAPIOAuth1Token *token = [[DSAPIOAuth1Token alloc] initWithQueryString:queryString];
    
    expect(token.key).to.equal(@"key");
    expect(token.secret).to.equal(@"secret");
    expect(token.session).to.equal(@"session");
    expect(token.expired).toNot.beTruthy();
    expect(token.renewable).to.beTruthy();
}

- (void)testCanAcquireRequestToken
{
    __block DSAPIOAuth1Token *blockRequestToken = nil;
    [_client acquireOAuthRequestTokenWithQueue:self.APICallbackQueue success:^(DSAPIOAuth1Token *requestToken) {
        blockRequestToken = requestToken;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(blockRequestToken).willNot.beNil();
}

- (void)testAuthorizeReturnsAuthorizeURL
{
    __block DSAPIOAuth1Token *blockRequestToken = nil;
    __block NSURLRequest *blockAuthorizeRequest = nil;
    [_client authorizeUsingOAuthWithQueue:self.APICallbackQueue success:^(DSAPIOAuth1Token *requestToken, NSURLRequest *authorizeRequest) {
        blockRequestToken = requestToken;
        blockAuthorizeRequest = authorizeRequest;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(blockRequestToken).willNot.beNil();
    expect(blockAuthorizeRequest).willNot.beNil();
}

@end
