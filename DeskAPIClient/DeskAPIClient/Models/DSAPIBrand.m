//
//  DSAPIBrand.m
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

#define kClassName @"brand"

#import "DSAPIBrand.h"
#import "DSAPITopic.h"
#import "DSAPIArticle.h"

@interface DSAPIBrand ()

@end

@implementation DSAPIBrand

#pragma mark - Class Methods

+ (NSString *)className
{
    return kClassName;
}

+ (NSURLSessionDataTask *)listBrandsWithParameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                           failure:(DSAPIFailureBlock)failure
{
    return [self listBrandsWithParameters:parameters
                                    queue:queue
                                  success:success
                              notModified:nil
                                  failure:failure];
}

+ (NSURLSessionDataTask *)listBrandsWithParameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                       notModified:(DSAPIPageSuccessBlock)notModified
                                           failure:(DSAPIFailureBlock)failure
{
    return [super listResourcesAt:[DSAPIBrand classLink]
                       parameters:parameters
                            queue:queue
                          success:success
                          failure:failure];
}

- (DSAPILink *)linkToTopics
{
    // API doesn't provide a link to a brand's topics
    return [self.linkToSelf linkFromRelationWithClass:[DSAPITopic class]];
}

#pragma mark - Instance Methods

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIBrand *brand))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPIBrand *)resource);
                                 }
                             }
                             failure:failure];
}

- (NSURLSessionDataTask *)listTopicsWithParameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                           failure:(DSAPIFailureBlock)failure
{
    return [self listTopicsWithParameters:parameters
                                    queue:queue
                                  success:success
                              notModified:nil
                                  failure:failure];
}

- (NSURLSessionDataTask *)listTopicsWithParameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                       notModified:(DSAPIPageSuccessBlock)notModified
                                           failure:(DSAPIFailureBlock)failure
{
    return [DSAPIResource listResourcesAt:self.linkToTopics
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}

- (NSURLSessionDataTask *)listArticlesWithParameters:(NSDictionary *)parameters
                                               queue:(NSOperationQueue *)queue
                                             success:(DSAPIPageSuccessBlock)success
                                             failure:(DSAPIFailureBlock)failure
{
    return [self listArticlesWithParameters:parameters
                                      queue:queue
                                    success:success
                                notModified:nil
                                    failure:failure];
}

- (NSURLSessionDataTask *)listArticlesWithParameters:(NSDictionary *)parameters
                                               queue:(NSOperationQueue *)queue
                                             success:(DSAPIPageSuccessBlock)success
                                         notModified:(DSAPIPageSuccessBlock)notModified
                                             failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:[DSAPIArticle classNamePlural]
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}

@end
