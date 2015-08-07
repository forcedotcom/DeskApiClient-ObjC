//
//  DeskAPIClientTests.m
//  DeskAPIClientTests
//
//  Created by Desk.com on 9/17/13.
//  Copyright (c) 2015 Salesforce, Inc All rights reserved.
//

#import "DSAPITestCase.h"

@interface DSAPIClient()

@property (nonatomic, strong) NSMutableDictionary *downloadProgressBlocks;
@property (nonatomic, strong) NSMutableDictionary *downloadCompletionBlocks;

@end

@interface DSAPIClientTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPIClientTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}
- (void)testThatWeCanCommunicateWithTheWebService
{
    __block id blockResponseObject = nil;
    
    [_client GET:@"/api/v2/cases" parameters:nil queue:self.APICallbackQueue success:^(NSHTTPURLResponse *response, id responseObject) {
        //NSLog(@"%@", responseObject);
        blockResponseObject = responseObject;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(blockResponseObject).willNot.beNil();
}

- (void)testInitializationOfClient
{
    expect(_client).toNot.beNil();
    expect(_client).to.beKindOf([DSAPIClient class]);
}

- (void)testCannotUseOAuth
{
    XCTAssertThrows([_client acquireOAuthRequestTokenWithQueue:self.APICallbackQueue success:^(DSAPIOAuth1Token *requestToken) {
        //
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        //
    }], @"Client initialized with basic oauth but accepted oauth method.");
}

- (void)testThatWebServiceSendsResponseObject
{
    __block id blockResponseObject = nil;
    [_client GET:@"/api/v2/cases" parameters:nil queue:self.APICallbackQueue success:^(NSHTTPURLResponse *response, id responseObject) {
        NSLog(@"%@", responseObject);
        blockResponseObject = responseObject;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(blockResponseObject).willNot.beNil();
}

- (void)testFiresRateLimitingResponse
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:DSC_HTTP_STATUS_TOO_MANY_REQUESTS HTTPVersion:nil headerFields:nil];
    
    id mockNotificationCenter = [OCMockObject partialMockForObject:[NSNotificationCenter defaultCenter]];
    [[mockNotificationCenter expect] postNotificationName:DSAPIDidErrorWithTooManyRequestsNotification object:_client userInfo:OCMOCK_ANY];
    
    [_client postRateLimitingNotificationIfNecessary:response];
    [mockNotificationCenter verify];
}

- (void)testDoesntFireRateLimitingResponse
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:nil statusCode:DSC_HTTP_STATUS_NOT_FOUND HTTPVersion:nil headerFields:nil];
    
    id mockNotificationCenter = [OCMockObject partialMockForObject:[NSNotificationCenter defaultCenter]];
    [[mockNotificationCenter reject] postNotificationName:DSAPIDidErrorWithTooManyRequestsNotification object:_client userInfo:OCMOCK_ANY];
    
    [_client postRateLimitingNotificationIfNecessary:response];
    [mockNotificationCenter verify];
}

- (void)testTokenAuthentication
{
    DSAPIClient *client = [DSAPITestUtils APIClientTokenAuth];
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"Should get 200 response"];
    
    [client GET:@"/api/v2/articles" parameters:nil queue:self.APICallbackQueue success:^(NSHTTPURLResponse *response, id responseObject) {
        expect(response.statusCode).to.equal(DSC_HTTP_STATUS_OK);
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
    }];
    
    [self waitForExpectationsWithTimeout:3.f handler:nil];
}

- (void)testDownloadTaskCallsProgressBlock
{
    NSURL *url = [NSURL URLWithString:@"http://google.com/favicon.ico"];
    
    __weak XCTestExpectation *exp = [self expectationWithDescription:@"wait for download progress"];
    NSURLSessionDownloadTask *task = [_client downloadTaskWithURL:url
                                                            queue:self.APICallbackQueue
                                                  progressHandler:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                                                      expect([[_client downloadProgressBlocks] count]).to.equal(1);
                                                      [exp fulfill];
                                                  }
                                                completionHandler:nil];
    
    [task resume];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout handler:nil];
}

- (void)testDownloadTaskCallsCompletionHandler
{
    NSURL *url = [NSURL URLWithString:@"http://google.com/favicon.ico"];
    
    __weak XCTestExpectation *exp = [self expectationWithDescription:@"wait for download"];
    
    NSURLSessionDownloadTask *task = [_client downloadTaskWithURL:url
                                                            queue:self.APICallbackQueue
                                                  progressHandler:nil
                                                completionHandler:^(NSData *data, NSError *error) {
                                                    expect(data).toNot.beNil();
                                                    expect([[_client downloadProgressBlocks] count]).to.equal(0);
                                                    [exp fulfill];
                                                  }];
    
    [task resume];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout handler:nil];
    expect([[_client downloadCompletionBlocks] count]).to.equal(0);
}

- (void)testCancelDownloadTask
{
    NSURL *url = [NSURL URLWithString:@"http://google.com/favicon.ico"];
    
    NSURLSessionDownloadTask *task = [_client downloadTaskWithURL:url
                                                            queue:self.APICallbackQueue
                                                  progressHandler:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                                                      // dummy block
                                                  }
                                                completionHandler:^(NSData *data, NSError *error) {
                                                    // dummy block
                                                }];
    expect([[_client downloadProgressBlocks] count]).to.equal(1);
    expect([[_client downloadCompletionBlocks] count]).to.equal(1);
    [task resume];
    [_client cancelDownloadTask:task];
    expect([[_client downloadProgressBlocks] count]).to.equal(0);
    expect([[_client downloadCompletionBlocks] count]).to.equal(0);
    expect(task.state).will.equal(NSURLSessionTaskStateCompleted);
}

@end
