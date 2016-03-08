//
//  DeskAPIClient.h
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

#import <Foundation/Foundation.h>
#import "DSAPIURLRequestSerialization.h"
#import "DSAPIURLResponseSerialization.h"
#import "DSAPIModels.h"
#import "NSDictionary+DSAPI.h"

typedef void (^DSAPIDownloadProgressHandler)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^DSAPIDownloadCompletionHandler)(NSData *data, NSHTTPURLResponse *response, NSError *error);

extern NSString * const DSAPIDidErrorWithTooManyRequestsNotification;
extern NSString * const DSAPIResponseKey;

@interface DSAPIClient : NSObject <NSURLSessionDelegate>

///-----------------------------------
/// @name Initialization
///-----------------------------------

@property (nonatomic, strong) DSAPIOAuth1Token *accessToken;
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, strong) DSAPIHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) DSAPIHTTPResponseSerializer *responseSerializer;

/**
 Sets the `DSAPIClient` object with the specified hostname and API token.
 
 @param hostname The hostname for a Desk.com site.
 @param APIToken A token to authenticate the API
 
 */
- (void)setHostname:(NSString *)hostname
           APIToken:(NSString *)apiToken;

/**
 Sets the `DSAPIClient` object with the specified hostname, username, and password.
 
 @param hostname The hostname for a Desk.com site.
 @param username A username for a user of the Desk.com site
 @param password The password for a user of the Desk.com site
 
 */
- (void)setHostname:(NSString *)hostname
           username:(NSString *)username
           password:(NSString *)password;

/**
 Sets the `DSAPIClient` object with the specified hostname, conumer key, secret, and callback URL (for OAuth authentication).
 
 @param hostname The hostname for a Desk.com site.
 @param consumerKey A consumer key for an API app registered with the Desk.com site
 @param consumerKey A consumer secret for an API app registered with the Desk.com site
 @param callbackURL A callback URL for an API app registered with the Desk.com site
 
 */
- (void)setHostname:(NSString *)hostname
        consumerKey:(NSString *)consumerKey
     consumerSecret:(NSString *)consumerSecret
        callbackURL:(NSURL *)callbackURL;


/**
 Returns a `Class` for a given className (as returned by the API)
 
 @param className A Class Name
 
 @return The Class
 */
- (Class)classForClassName:(NSString *)className;


/**
 Fires an `NSNotification` if the response's status code is 429 (Rate Limiting Error)
 
 @param NSURLHTTPResponse A Class Name
 */
- (void)postRateLimitingNotificationIfNecessary:(NSHTTPURLResponse *)response;


///-----------------------------------
/// @name OAuth Authentication
///-----------------------------------


/**
 Acquires a request token from the web service and asks user to authorize. Must initialize the client with the OAuth Initializer before making this request.
 
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the verified request token, and the raw response data returned by the web service.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 */

- (void)authorizeUsingOAuthWithQueue:(NSOperationQueue *)queue
                             success:(void (^)(DSAPIOAuth1Token *requestToken, NSURLRequest *authorizeRequest))success
                             failure:(DSAPIFailureBlock)failure;

/**
 Acquires a request token from the web service. Must initialize the client with the OAuth Initializer before making this request.
 
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the unverified request token, and the raw response data returned by the web service.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 */

- (void)acquireOAuthRequestTokenWithQueue:(NSOperationQueue *)queue
                                  success:(void (^)(DSAPIOAuth1Token *requestToken))success
                                  failure:(DSAPIFailureBlock)failure;

/**
 Acquires an access token from the web service. Must initialize the client with the OAuth Initializer and have a verified requestToken before making this request.
 
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the access token, and the raw response data returned by the web service.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 */

- (void)acquireOAuthAccessTokenWithRequestToken:(DSAPIOAuth1Token *)requestToken
                                          queue:(NSOperationQueue *)queue
                                        success:(void (^)(DSAPIOAuth1Token *accessToken))success
                                        failure:(DSAPIFailureBlock)failure;


///-----------------------------------
/// @name HTTP
///-----------------------------------

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                        queue:(NSOperationQueue *)queue
                                      success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                                      failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                        queue:(NSOperationQueue *)queue
                      success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                      failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                         queue:(NSOperationQueue *)queue
                       success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                       failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
                        queue:(NSOperationQueue *)queue
                      success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                      failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
                          queue:(NSOperationQueue *)queue
                        success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                        failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                           queue:(NSOperationQueue *)queue
                         success:(void (^)(NSHTTPURLResponse *response, id responseObject))success
                         failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

- (void)cancelAllDataTasksWithQueue:(NSOperationQueue *)queue completionHandler:(void (^)(void))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url
                                            queue:(NSOperationQueue *)queue
                                  progressHandler:(DSAPIDownloadProgressHandler)progressHandler
                                completionHandler:(DSAPIDownloadCompletionHandler)completionHandler;

- (void)cancelAllDownloadTasksWithQueue:(NSOperationQueue *)queue completionHandler:(void (^)(void))completionHandler;

/**
 Empty all cookies, cache and credential stores, removes disk files
 
 @param completionHandler The completion handler to call when the clear operation is complete.
 */

- (void)resetSessionWithCompletionHandler:(void (^)(void))completionHandler;

@end
