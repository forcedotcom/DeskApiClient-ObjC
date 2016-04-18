//
//  DSAPICaseFilter.m
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

#import "DSAPICaseFilter.h"
#import "DSAPICase.h"
#import "DSAPIPage.h"
#import "DSAPIClient.h"

#import <objc/runtime.h>

#define kClassName @"filter"
#define kCaseIdsParam @"cids"
#define kLastPolledTimeParam @"cflpt"
#define kChangesPath @"changes"

@implementation DSAPICaseFilter

+ (NSString *)className
{
    return kClassName;
}


+ (NSURLSessionDataTask *)listFiltersWithParameters:(NSDictionary *)parameters
                                             client:(DSAPIClient *)client
                                              queue:(NSOperationQueue *)queue
                                            success:(DSAPIPageSuccessBlock)success
                                            failure:(DSAPIFailureBlock)failure
{
    return [self listFiltersWithParameters:parameters
                                    client:client
                                     queue:queue
                                   success:success
                               notModified:nil
                                   failure:failure];
}


+ (NSURLSessionDataTask *)listFiltersWithParameters:(NSDictionary *)parameters
                                             client:(DSAPIClient *)client
                                              queue:(NSOperationQueue *)queue
                                            success:(DSAPIPageSuccessBlock)success
                                        notModified:(DSAPIPageSuccessBlock)notModified
                                            failure:(DSAPIFailureBlock)failure
{
    return [super listResourcesAt:[DSAPICaseFilter classLinkWithBaseURL:client.baseURL]
                       parameters:parameters
                           client:client
                            queue:queue
                          success:success
                      notModified:notModified
                          failure:failure];
}


- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPICaseFilter *filter))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPICaseFilter *)resource);
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

- (NSURLSessionDataTask *)listCaseChanges:(NSArray *)caseIds
                           lastPolledTime:(NSTimeInterval)lastPolledTime
                               parameters:(NSDictionary *)parameters
                                    queue:(NSOperationQueue *)queue
                                  success:(DSAPIPageSuccessBlock)success
                                  failure:(DSAPIFailureBlock)failure
{
    NSString *caseChangesHref = [NSString stringWithFormat:@"%@/%@", [self linkForRelation:[DSAPICase classNamePlural]], kChangesPath];
    DSAPILink *linkToCaseChanges = [[DSAPILink alloc] initWithDictionary:@{
                                                                           kClassKey: kClassName,
                                                                           kHrefKey: caseChangesHref
                                                                           }
                                                                 baseURL:self.client.baseURL];
    
    NSMutableDictionary *updatedParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary new];
    updatedParameters[kCaseIdsParam] = [caseIds componentsJoinedByString:@","];
    updatedParameters[kLastPolledTimeParam] = [NSNumber numberWithInteger:lastPolledTime];
    
    return [[self class] listResourcesAt:linkToCaseChanges
                              parameters:updatedParameters
                                  client:self.client
                                   queue:queue
                                 success:^(DSAPIPage *page) {
                                     object_setClass(page, [DSAPIPage class]);
                                     if (success) {
                                         success(page);
                                     }
                                 }
                                 failure:failure];
}

@end
