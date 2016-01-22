//
//  DSAPILabel.m
//  DeskAPIClient
//
//  Created by Desk.com on 11/6/13.
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

#import "DSAPILabel.h"
#import "DSAPIClient.h"

#define kClassName @"label"

@implementation DSAPILabel

+ (NSString *)className
{
    return kClassName;
}


#pragma mark - Class Methods

+ (NSURLSessionDataTask *)listLabelsWithParameters:(NSDictionary *)parameters
                                            client:(DSAPIClient *)client
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                           failure:(DSAPIFailureBlock)failure
{
    return [self listLabelsWithParameters:parameters
                                   client:client
                                    queue:queue
                                  success:success
                              notModified:nil
                                  failure:failure];
}

+ (NSURLSessionDataTask *)listLabelsWithParameters:(NSDictionary *)parameters
                                            client:(DSAPIClient *)client
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                       notModified:(DSAPIPageSuccessBlock)notModified
                                           failure:(DSAPIFailureBlock)failure
{
    return [super listResourcesAt:[DSAPILabel classLinkWithBaseURL:client.baseURL]
                       parameters:parameters
                           client:client
                            queue:queue
                          success:success
                      notModified:notModified
                          failure:failure];
}

+ (NSURLSessionDataTask *)searchLabelsWithParameters:(NSDictionary *)parameters
                                              client:(DSAPIClient *)client
                                               queue:(NSOperationQueue *)queue
                                             success:(DSAPIPageSuccessBlock)success
                                             failure:(DSAPIFailureBlock)failure
{
    return [super searchResourcesAt:[DSAPILabel classLinkWithBaseURL:client.baseURL]
                         parameters:parameters
                             client:client
                              queue:queue
                            success:success
                            failure:failure];
}

+ (NSURLSessionDataTask *)searchLabelsWithParameters:(NSDictionary *)parameters
                                              client:(DSAPIClient *)client
                                               queue:(NSOperationQueue *)queue
                                             success:(DSAPIPageSuccessBlock)success
                                         notModified:(DSAPIPageSuccessBlock)notModified
                                             failure:(DSAPIFailureBlock)failure
{
    return [super searchResourcesAt:[DSAPILabel classLinkWithBaseURL:client.baseURL]
                         parameters:parameters
                             client:client
                              queue:queue
                            success:success
                        notModified:notModified
                            failure:failure];
}

+ (NSURLSessionDataTask *)createLabel:(NSDictionary *)labelDict
                               client:(DSAPIClient *)client
                                queue:(NSOperationQueue *)queue
                              success:(void (^)(DSAPILabel *))success
                              failure:(DSAPIFailureBlock)failure
{
    return [super createResource:labelDict
                            link:[DSAPILabel classLinkWithBaseURL:client.baseURL]
                          client:client
                           queue:queue
                         success:^(DSAPIResource *resource) {
                             if (success) {
                                 success((DSAPILabel *)resource);
                             }
                         }
                         failure:failure];
}

#pragma mark - Instance Methods

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPILabel *label))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPILabel *)resource);
                                 }
                             }
                             failure:failure];
}


- (NSURLSessionDataTask *)updateWithDictionary:(NSDictionary *)dictionary
                                         queue:(NSOperationQueue *)queue
                                       success:(void (^)(DSAPILabel *label))success
                                       failure:(DSAPIFailureBlock)failure
{
    return [super updateWithDictionary:dictionary
                                 queue:queue
                               success:^(DSAPIResource *resource) {
                                   if (success) {
                                       success((DSAPILabel *)resource);
                                   }
                               }
                               failure:failure];
}

@end
