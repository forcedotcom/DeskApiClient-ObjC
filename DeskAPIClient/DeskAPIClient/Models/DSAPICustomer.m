//
//  DSAPICustomer.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/25/13.
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

#define kClassName @"customer"
#define kClassNamePlural @"customers"

#define kCustomersEnhancementsEnabled @"enhancements_enabled"
#define kCustomersEnabled @"enabled"

#import "DSAPICustomer.h"
#import "DSAPICase.h"
#import "DSAPIClient.h"

@implementation DSAPICustomer

+ (NSString *)className
{
    return kClassName;
}


#pragma mark - Class Methods

+ (NSURLSessionDataTask *)enhancementsEnabledWithParameters:(NSDictionary *)parameters
                                                     client:(DSAPIClient *)client
                                                      queue:(NSOperationQueue *)queue
                                                    success:(void (^)(BOOL enabled))success
                                                    failure:(DSAPIFailureBlock)failure
{
    NSString *href = [NSString stringWithFormat:@"%@/%@", [DSAPICustomer classLinkWithBaseURL:client.baseURL], kCustomersEnhancementsEnabled];
    
    return [client GET:href
            parameters:parameters
                 queue:queue
               success:^(NSHTTPURLResponse *response, NSDictionary *responseObject) {
                   if (success) {
                       BOOL enabled = [responseObject.allKeys containsObject:@"enabled"] && [responseObject[kCustomersEnabled] boolValue];
                       
                       enabled ? success(YES) : success(NO);
                   }
               }
               failure:^(NSHTTPURLResponse *response, NSError *error) {
                   [client postRateLimitingNotificationIfNecessary:response];
                   if (failure) {
                       failure(response, error);
                   }
               }];
}

+ (NSURLSessionDataTask *)listCustomersWithParameters:(NSDictionary *)parameters
                                               client:(DSAPIClient *)client
                                                queue:(NSOperationQueue *)queue
                                              success:(DSAPIPageSuccessBlock)success
                                              failure:(DSAPIFailureBlock)failure
{
    return [self listCustomersWithParameters:parameters
                                      client:client
                                       queue:queue
                                     success:success
                                 notModified:nil
                                     failure:failure];
}

+ (NSURLSessionDataTask *)listCustomersWithParameters:(NSDictionary *)parameters
                                               client:(DSAPIClient *)client
                                                queue:(NSOperationQueue *)queue
                                              success:(DSAPIPageSuccessBlock)success
                                          notModified:(DSAPIPageSuccessBlock)notModified
                                              failure:(DSAPIFailureBlock)failure
{
    return [super listResourcesAt:[DSAPICustomer classLinkWithBaseURL:client.baseURL]
                       parameters:parameters
                           client:client
                            queue:queue
                          success:success
                          failure:failure];
}

+ (NSURLSessionDataTask *)searchCustomersWithParameters:(NSDictionary *)parameters
                                                 client:(DSAPIClient *)client
                                                  queue:(NSOperationQueue *)queue
                                                success:(DSAPIPageSuccessBlock)success
                                                failure:(DSAPIFailureBlock)failure
{
    return [super searchResourcesAt:[DSAPICustomer classLinkWithBaseURL:client.baseURL]
                         parameters:parameters
                             client:client
                              queue:queue
                            success:success
                            failure:failure];
}

+ (NSURLSessionDataTask *)searchCustomersWithParameters:(NSDictionary *)parameters
                                                 client:(DSAPIClient *)client
                                                  queue:(NSOperationQueue *)queue
                                                success:(DSAPIPageSuccessBlock)success
                                            notModified:(DSAPIPageSuccessBlock)notModified
                                                failure:(DSAPIFailureBlock)failure
{
    return [super searchResourcesAt:[DSAPICustomer classLinkWithBaseURL:client.baseURL]
                         parameters:parameters
                             client:client
                              queue:queue
                            success:success
                        notModified:notModified
                            failure:failure];
}


+ (NSURLSessionDataTask *)createCustomer:(NSDictionary *)customerDictionary
                                  client:(DSAPIClient *)client
                                   queue:(NSOperationQueue *)queue
                                 success:(void (^)(DSAPICustomer *))success
                                 failure:(DSAPIFailureBlock)failure
{
    return [super createResource:customerDictionary
                            link:[DSAPICustomer classLinkWithBaseURL:client.baseURL]
                          client:client
                           queue:queue
                         success:^(DSAPIResource *resource) {
                             if (success) {
                                 success((DSAPICustomer *)resource);
                             }
                         }
                         failure:failure];
}


#pragma mark - Instance Methods

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPICustomer *))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPICustomer *)resource);
                                 }
                             }
                             failure:failure];
}


- (NSURLSessionDataTask *)updateWithDictionary:(NSDictionary *)dictionary
                                         queue:(NSOperationQueue *)queue
                                       success:(void (^)(DSAPICustomer *updatedCustomer))success
                                       failure:(DSAPIFailureBlock)failure
{
    return [super updateWithDictionary:dictionary
                                 queue:queue
                               success:^(DSAPIResource *resource) {
                                   if (success) {
                                       success((DSAPICustomer *)resource);
                                   }
                               }
                               failure:failure];
}


- (NSURLSessionDataTask *)listCasesWithParameters:(NSDictionary *)parameters
                                            queue:(NSOperationQueue *)queue
                                          success:(DSAPIPageSuccessBlock)success
                                          failure:(DSAPIFailureBlock)failure
{
    return [self listCasesWithParameters:parameters
                                   queue:queue
                                 success:success
                             notModified:nil
                                 failure:failure];
}


- (NSURLSessionDataTask *)listCasesWithParameters:(NSDictionary *)parameters
                                            queue:(NSOperationQueue *)queue
                                          success:(DSAPIPageSuccessBlock)success
                                      notModified:(DSAPIPageSuccessBlock)notModified
                                          failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:[DSAPICase classNamePlural]
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}

@end
