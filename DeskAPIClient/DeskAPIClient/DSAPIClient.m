//
//  DeskAPIClient.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/17/13.
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

#import "DSAPIClient.h"
#import <DeskCommon/DSCHttpStatusCodes.h>
#import <DeskCommon/NSURLRequest+DSC.h>

typedef enum {
    DSAPIClientAuthTypeBasic,
    DSAPIClientAuthTypeOAuth,
    DSAPIClientAuthTypeOAuth2Token
} DSAPIClientAuthType;

NSString *const DSAPIDidErrorWithTooManyRequestsNotification = @"DSAPIDidErrorWithTooManyRequestsNotification";
NSString *const DSAPIResponseKey = @"response";

static NSString *const DSAPIOAuthCallbackKey = @"oauth_callback";
static NSString *const DSAPIClientLockName = @"com.desk.networking.session.client.lock";
static NSString *const DSAPIQueueKey = @"queue";
static NSString *const DSAPIBlockHandlerKey = @"blockHandler";
static NSString *const DSAPIDataKey = @"data";
static NSString *const DSAPIErrorKey = @"error";

@interface DSAPIClient ()

@property (nonatomic) DSAPIClientAuthType authType;
@property (nonatomic, copy) NSURL *callbackURL;
@property (nonatomic, strong) NSURLSession* session;
@property (atomic, strong) NSMutableDictionary *downloadProgressBlocks;
@property (atomic, strong) NSMutableDictionary *downloadCompletionBlocks;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation DSAPIClient

static NSDictionary *ClassNames;

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static DSAPIClient *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[DSAPIClient alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    ClassNames = @{[DSAPIPage className]: [DSAPIPage class],
                   [DSAPICase className]: [DSAPICase class],
                   [DSAPIChatMessage className]: [DSAPIChatMessage class],
                   [DSAPITweet className]: [DSAPITweet class],
                   [DSAPIEmail className]: [DSAPIEmail class],
                   [DSAPICommunityAnswer className]: [DSAPICommunityAnswer class],
                   [DSAPIFacebookComment className]: [DSAPIFacebookComment class],
                   [DSAPIPhoneCall className]: [DSAPIPhoneCall class],
                   [DSAPICustomer className]: [DSAPICustomer class],
                   [DSAPINote className]: [DSAPINote class],
                   [DSAPIAttachment className]: [DSAPIAttachment class],
                   [DSAPIFilter className]: [DSAPIFilter class],
                   [DSAPIUser className]: [DSAPIUser class],
                   [DSAPIUserPreference className]: [DSAPIUserPreference class],
                   [DSAPILabel className]: [DSAPILabel class],
                   [DSAPIGroup className]: [DSAPIGroup class],
                   [DSAPIMacro className]: [DSAPIMacro class],
                   [DSAPIMacroAction className]: [DSAPIMacroAction class],
                   [DSAPIFacebookUser className]: [DSAPIFacebookUser class],
                   [DSAPITwitterUser className]: [DSAPITwitterUser class],
                   [DSAPICustomField className]: [DSAPICustomField class],
                   [DSAPIMobileDevice className]: [DSAPIMobileDevice class],
                   [DSAPIMobileDeviceSetting className]: [DSAPIMobileDeviceSetting class],
                   [DSAPITwitterAccount className]: [DSAPITwitterAccount class],
                   [DSAPITwitterFollow className]: [DSAPITwitterFollow class],
                   [DSAPIPermission className]: [DSAPIPermission class],
                   [DSAPISiteSetting className]: [DSAPISiteSetting class],
                   [DSAPIMailbox outboundMailboxClassName]: [DSAPIMailbox class],
                   [DSAPIMailbox inboundMailboxClassName]: [DSAPIMailbox class],
                   [DSAPIJob className]: [DSAPIJob class],
                   [DSAPICompany className]: [DSAPICompany class],
                   [DSAPITopic className]: [DSAPITopic class],
                   [DSAPIArticle className]: [DSAPIArticle class],
                   [DSAPISite className]: [DSAPISite class],
                   [DSAPIBilling className]: [DSAPIBilling class],
                   [DSAPIBrand className]: [DSAPIBrand class]};
    _downloadProgressBlocks = [NSMutableDictionary new];
    _downloadCompletionBlocks = [NSMutableDictionary new];
    _lock = [NSLock new];
    _lock.name = DSAPIClientLockName;
}

- (void)setHostname:(NSString *)hostname APIToken:(NSString *)apiToken
{
    [self setBaseURLFromHostname:hostname];
    self.authType = DSAPIClientAuthTypeOAuth2Token;
    [self setupResponseSerializer];
    
    self.requestSerializer = [DSAPIJSONRequestSerializer serializer];
    [self.requestSerializer setAuthorizationHeaderFieldWithBearerToken:apiToken];
    [self setupJsonRequestSerialization];
}

- (void)setHostname:(NSString *)hostname
           username:(NSString *)username
           password:(NSString *)password
{
    [self setBaseURLFromHostname:hostname];
    self.authType = DSAPIClientAuthTypeBasic;
    [self setupResponseSerializer];
    
    self.requestSerializer = [DSAPIJSONRequestSerializer serializer];
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    [self setupJsonRequestSerialization];
}

- (void)setHostname:(NSString *)hostname
        consumerKey:(NSString *)consumerKey
     consumerSecret:(NSString *)consumerSecret
        callbackURL:(NSURL *)callbackURL
{
    [self setBaseURLFromHostname:hostname];
    self.authType = DSAPIClientAuthTypeOAuth;
    [self setupResponseSerializer];
    self.callbackURL = callbackURL;
    
    
    DSAPIOAuthRequestSerializer *requestSerializer = [DSAPIOAuthRequestSerializer serializer];
    [requestSerializer setAuthorizationHeaderFieldWithConsumerKey:consumerKey consumerSecret:consumerSecret];
    self.requestSerializer = requestSerializer;
    
    [self setupJsonRequestSerialization];
}

- (void)setBaseURLFromHostname:(NSString *)hostname
{
    self.baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", hostname]];
}

- (void)setupResponseSerializer
{
    self.responseSerializer = [DSAPIJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
}

- (void)setupJsonRequestSerialization
{
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

- (Class)classForClassName:(NSString *)className
{
    if ([ClassNames objectForKey:className]) {
        return (Class)[ClassNames objectForKey : className];
    } else {
        return [DSAPIResource class];
    }
}

- (void)postRateLimitingNotificationIfNecessary:(NSHTTPURLResponse *)response
{
    if (response.statusCode == DSC_HTTP_STATUS_TOO_MANY_REQUESTS) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DSAPIDidErrorWithTooManyRequestsNotification object:self userInfo:@{DSAPIResponseKey : response}];
    }
}

#pragma mark - OAuth Authentication

- (void)authorizeUsingOAuthWithQueue:(NSOperationQueue *)queue
                             success:(void (^)(DSAPIOAuth1Token *requestToken, NSURLRequest *authorizeRequest))success
                             failure:(DSAPIFailureBlock)failure
{
    NSAssert(self.authType == DSAPIClientAuthTypeOAuth, @"Client not initialized for OAuth.");
    
    [self acquireOAuthRequestTokenWithQueue:queue
                                    success:^(DSAPIOAuth1Token *requestToken) {
                                        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                                        NSString *urlString = [NSString stringWithFormat:@"%@%@?oauth_token=%@", self.baseURL, @"/oauth/authorize", requestToken.key];
                                        NSError *error = nil;
                                        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                                                       URLString:urlString
                                                                                                      parameters:parameters
                                                                                                           error:&error];
                                        if (error && failure) {
                                            if (failure) {
                                                failure(nil, error);
                                            }
                                        } else if (!error && success) {
                                            if (success) {
                                                success(requestToken, request);
                                            }
                                        }
                                    }
                                    failure:^(NSHTTPURLResponse *response, NSError *error) {
                                        if (failure) {
                                            failure(response, error);
                                        }
                                    }];
}

- (void)acquireOAuthRequestTokenWithQueue:(NSOperationQueue *)queue
                                  success:(void (^)(DSAPIOAuth1Token *requestToken))success
                                  failure:(DSAPIFailureBlock)failure
{
    NSAssert(self.authType == DSAPIClientAuthTypeOAuth, @"Client not initialized for OAuth.");
    
    NSDictionary *parameters = @{DSAPIOAuthCallbackKey : [self.callbackURL absoluteString]};
    
    DSAPIClient *manager = [DSAPIClient new];
    manager.baseURL = self.baseURL;
    manager.requestSerializer = self.requestSerializer;
    manager.responseSerializer = [DSAPIHTTPResponseSerializer serializer];
    
    [manager POST:@"/oauth/request_token"
       parameters:parameters
            queue:queue
          success:^(NSHTTPURLResponse *response, id responseObject) {
              DSAPIOAuth1Token *token = [[DSAPIOAuth1Token alloc] initWithQueryString:[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]];
              if (success) {
                  success(token);
              }
          }
          failure:^(NSHTTPURLResponse *response, NSError *error) {
              [self postRateLimitingNotificationIfNecessary:response];
              if (failure) {
                  failure(response, error);
              }
          }];
}

- (void)acquireOAuthAccessTokenWithRequestToken:(DSAPIOAuth1Token *)requestToken
                                          queue:(NSOperationQueue *)queue
                                        success:(void (^)(DSAPIOAuth1Token *))success
                                        failure:(DSAPIFailureBlock)failure
{
    NSAssert(self.authType == DSAPIClientAuthTypeOAuth, @"Client not initialized for OAuth.");
    
    DSAPIClient *manager = [DSAPIClient new];
    manager.baseURL = self.baseURL;
    
    __block DSAPIOAuthRequestSerializer *serializer = (DSAPIOAuthRequestSerializer *)self.requestSerializer;
    serializer.accessToken = requestToken;
    manager.requestSerializer = serializer;
    manager.responseSerializer = [DSAPIHTTPResponseSerializer serializer];
    
    [manager POST:@"/oauth/access_token"
       parameters:nil
            queue:queue
          success:^(NSHTTPURLResponse *response, id responseObject) {
              DSAPIOAuth1Token *accessToken = [[DSAPIOAuth1Token alloc] initWithQueryString:[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]];
              serializer.accessToken = accessToken;
              if (success) {
                  success(accessToken);
              }
          }
          failure:^(NSHTTPURLResponse *response, NSError *error) {
              [self postRateLimitingNotificationIfNecessary:response];
              if (failure) {
                  failure(response, error);
              }
          }];
}

- (void)setAccessToken:(DSAPIOAuth1Token *)accessToken
{
    ((DSAPIOAuthRequestSerializer *)self.requestSerializer).accessToken = accessToken;
}

- (DSAPIOAuth1Token *)accessToken
{
    return ((DSAPIOAuthRequestSerializer *)self.requestSerializer).accessToken;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                        queue:(NSOperationQueue *)queue
                                      success:(void (^)(NSHTTPURLResponse *response, id))success
                                      failure:(void (^)(NSHTTPURLResponse *response, NSError *))failure
{
    return [self.session dataTaskWithRequest:request
                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                               if (error == nil || error.code != NSURLErrorCancelled) {
                                   [queue addOperationWithBlock:^{
                                       if (error) {
                                           if (failure) {
                                               failure((NSHTTPURLResponse *)response, error);
                                           }
                                       } else {
                                           if (success) {
                                               NSError *serializationError = nil;
                                               id responseObject = [self.responseSerializer responseObjectForResponse:response
                                                                                                                 data:data
                                                                                                                error:&serializationError];
                                               if (serializationError && failure) {
                                                   failure((NSHTTPURLResponse *)response, serializationError);
                                               } else {
                                                   success((NSHTTPURLResponse *)response, responseObject);
                                               }
                                           }
                                       }
                                   }];
                               }
                           }];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                        queue:(NSOperationQueue *)queue
                      success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                      failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                   URLString:[[NSURL URLWithString:URLString
                                                                                     relativeToURL:self.baseURL]
                                                                              absoluteString]
                                                                  parameters:parameters
                                                                       error:nil];
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
                                                     queue:queue
                                                   success:success
                                                   failure:failure];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                         queue:(NSOperationQueue *)queue
                       success:(void (^)(NSHTTPURLResponse *, id))success
                       failure:(void (^)(NSHTTPURLResponse *, NSError *))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST"
                                                                   URLString:[[NSURL URLWithString:URLString
                                                                                     relativeToURL:self.baseURL]
                                                                              absoluteString]
                                                                  parameters:parameters
                                                                       error:nil];
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
                                                     queue:queue
                                                   success:success
                                                   failure:failure];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
                        queue:(NSOperationQueue *)queue
                      success:(void (^)(NSHTTPURLResponse *, id))success
                      failure:(void (^)(NSHTTPURLResponse *, NSError *))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT"
                                                                   URLString:[[NSURL URLWithString:URLString
                                                                                     relativeToURL:self.baseURL]
                                                                              absoluteString]
                                                                  parameters:parameters
                                                                       error:nil];
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
                                                     queue:queue
                                                   success:success
                                                   failure:failure];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
                          queue:(NSOperationQueue *)queue
                        success:(void (^)(NSHTTPURLResponse *, id))success
                        failure:(void (^)(NSHTTPURLResponse *, NSError *))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PATCH"
                                                                   URLString:[[NSURL URLWithString:URLString
                                                                                     relativeToURL:self.baseURL]
                                                                              absoluteString]
                                                                  parameters:parameters
                                                                       error:nil];
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
                                                     queue:queue
                                                   success:success
                                                   failure:failure];
    
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                           queue:(NSOperationQueue *)queue
                         success:(void (^)(NSHTTPURLResponse *, id))success
                         failure:(void (^)(NSHTTPURLResponse *, NSError *))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE"
                                                                   URLString:[[NSURL URLWithString:URLString
                                                                                     relativeToURL:self.baseURL]
                                                                              absoluteString]
                                                                  parameters:parameters
                                                                       error:nil];
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest:request
                                                     queue:queue
                                                   success:success
                                                   failure:failure];
    
    [task resume];
    
    return task;
}

- (void)cancelAllDataTasks:(void (^)(void))completionHandler;
{
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        for (NSURLSessionTask *task in dataTasks) {
            [task cancel];
        }
        if (completionHandler) {
            completionHandler();
        }
    }];
}

#pragma mark - Downloads

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url
                                            queue:(NSOperationQueue *)queue
                                  progressHandler:(DSAPIDownloadProgressHandler)progressHandler
                                completionHandler:(DSAPIDownloadCompletionHandler)completionHandler
{
    NSError *error = nil;
    NSURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                            URLString:url.absoluteString
                                                           parameters:nil
                                                                error:&error];
    
    if (error && completionHandler) {
        completionHandler(nil, error);
        return nil;
    } else {
        NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
        
        [self.lock lock];
        if (progressHandler) {
            self.downloadProgressBlocks[@(task.taskIdentifier)] = [self dictionaryWithQueue:queue blockHandler:progressHandler];
        }
        if (completionHandler) {
            self.downloadCompletionBlocks[@(task.taskIdentifier)] = [self dictionaryWithQueue:queue blockHandler:completionHandler];
        }
        [self.lock unlock];
        
        return task;
    }
}

- (NSMutableDictionary *)dictionaryWithQueue:(NSOperationQueue *)queue blockHandler:(id)blockHandler
{
    NSMutableDictionary *dict = [@{
                                   DSAPIQueueKey : queue,
                                   DSAPIBlockHandlerKey : blockHandler
                                   } mutableCopy];
    return dict;
}

- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    [downloadTask cancel];
    [self.lock lock];
    if (self.downloadProgressBlocks[@(downloadTask.taskIdentifier)]) {
        [self.downloadProgressBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
    }
    
    if (self.downloadCompletionBlocks[@(downloadTask.taskIdentifier)]) {
        [self.downloadCompletionBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
    }
    [self.lock unlock];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    if (completionHandler) {
        if (response.statusCode == DSC_HTTP_STATUS_MOVED_TEMPORARILY && [task isKindOfClass:[NSURLSessionDownloadTask class]]) {
            completionHandler([NSURLRequest requestWithAcceptAndContentTypeHeadersStripped:request]);
        } else {
            completionHandler(request);
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedIfSafe error:&error];
    
    
    [self.lock lock];
    if (self.downloadProgressBlocks[@(downloadTask.taskIdentifier)]) {
        [self.downloadProgressBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
    }
    
    NSMutableDictionary *downloadDictionary;
    if ((downloadDictionary = self.downloadCompletionBlocks[@(downloadTask.taskIdentifier)])) {
        if (error) {
            downloadDictionary[DSAPIErrorKey] = error;
        } else if (data) {
            downloadDictionary[DSAPIDataKey] = data;
        }
    }
    [self.lock unlock];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [self.lock lock];
    if (self.downloadProgressBlocks[@(downloadTask.taskIdentifier)]) {
        NSOperationQueue *queue = self.downloadProgressBlocks[@(downloadTask.taskIdentifier)][DSAPIQueueKey];
        DSAPIDownloadProgressHandler downloadProgress = self.downloadProgressBlocks[@(downloadTask.taskIdentifier)][DSAPIBlockHandlerKey];
        [queue addOperationWithBlock:^{
            downloadProgress(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }];
    }
    [self.lock unlock];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)downloadTask didCompleteWithError:(NSError *)error
{
    [self.lock lock];
    
    NSDictionary *downloadDictionary;
    if ((downloadDictionary = self.downloadCompletionBlocks[@(downloadTask.taskIdentifier)])) {
        NSOperationQueue *queue = downloadDictionary[DSAPIQueueKey];
        DSAPIDownloadCompletionHandler downloadCompletion = downloadDictionary[DSAPIBlockHandlerKey];
        
        NSData *data = nil;
        if (!error) {
            data = downloadDictionary[DSAPIDataKey];
            error = downloadDictionary[DSAPIErrorKey];
        }
        [queue addOperationWithBlock:^{
            downloadCompletion(data, error);
        }];

        [self.downloadCompletionBlocks removeObjectForKey:@(downloadTask.taskIdentifier)];
    }
    [self.lock unlock];
    
}

@end
