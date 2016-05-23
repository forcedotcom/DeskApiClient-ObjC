//
//  DSAPIOpportunity.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/16/16.
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

#import "DSAPIOpportunity.h"
#import "DSAPIClient.h"
#import "DSAPIOpportunityActivity.h"

#define kClassName @"opportunity"
#define kClassNamePlural @"opportunities"
#define kActivitiesKey @"activities"
#define kHistoryKey @"history"

@implementation DSAPIOpportunity

+ (NSString *)className
{
    return kClassName;
}

+ (NSString *)classNamePlural
{
    return kClassNamePlural;
}

#pragma mark - Class Methods

+ (NSURLSessionDataTask *)listOpportunitiesWithParameters:(NSDictionary *)parameters
                                                   client:(DSAPIClient *)client
                                                    queue:(NSOperationQueue *)queue
                                                  success:(DSAPIPageSuccessBlock)success
                                                  failure:(DSAPIFailureBlock)failure
{
    return [super listResourcesAt:[DSAPIOpportunity classLinkWithBaseURL:client.baseURL]
                       parameters:parameters
                           client:client
                            queue:queue
                          success:success
                          failure:failure];
}

+ (NSURLSessionDataTask *)searchOpportunitiesWithParameters:(NSDictionary *)parameters
                                                     client:(DSAPIClient *)client
                                                      queue:(NSOperationQueue *)queue
                                                    success:(DSAPIPageSuccessBlock)success
                                                    failure:(DSAPIFailureBlock)failure
{
    return [super searchResourcesAt:[DSAPIOpportunity classLinkWithBaseURL:client.baseURL]
                         parameters:parameters
                             client:client
                              queue:queue
                            success:success
                            failure:failure];
}

+ (NSURLSessionDataTask *)createOpportunity:(NSDictionary *)opportunityDictionary
                                     client:(DSAPIClient *)client
                                      queue:(NSOperationQueue *)queue
                                    success:(void (^)(DSAPIOpportunity *))success
                                    failure:(DSAPIFailureBlock)failure
{
    return [super createResource:opportunityDictionary
                            link:[DSAPIOpportunity classLinkWithBaseURL:client.baseURL]
                          client:client
                           queue:queue
                         success:^(DSAPIResource *resource) {
                             if (success) {
                                 success((DSAPIOpportunity *)resource);
                             }
                         }
                         failure:failure];
}

#pragma mark - Instance Methods

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIOpportunity *))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPIOpportunity *)resource);
                                 }
                             }
                             failure:failure];
}

- (NSURLSessionDataTask *)updateWithDictionary:(NSDictionary *)dictionary
                                         queue:(NSOperationQueue *)queue
                                       success:(void (^)(DSAPIOpportunity *updatedOpportunity))success
                                       failure:(DSAPIFailureBlock)failure
{
    return [super updateWithDictionary:dictionary
                                 queue:queue
                               success:^(DSAPIResource *resource) {
                                   if (success) {
                                       success((DSAPIOpportunity *)resource);
                                   }
                               }
                               failure:failure];
}

- (NSURLSessionDataTask *)createActivity:(NSDictionary *)activityDictionary
                                   queue:(NSOperationQueue *)queue
                                 success:(void (^)(DSAPIOpportunityActivity *newActivity))success
                                 failure:(DSAPIFailureBlock)failure
{
    DSAPILink *linkToActivities = [self linkForRelation:kActivitiesKey];
    if (!linkToActivities) {
        NSDictionary *linkDictionary = @{kHrefKey:[NSString stringWithFormat:@"%@/%@", self.linkToSelf.href, kActivitiesKey], kClassKey:[DSAPIOpportunityActivity classNamePlural]};
        linkToActivities = [[DSAPILink alloc] initWithDictionary:linkDictionary
                                                         baseURL:self.client.baseURL];
    }
    return [DSAPIResource createResource:activityDictionary
                                    link:linkToActivities
                                  client:self.client
                                   queue:queue
                                 success:^(DSAPIResource *newActivity) {
                                     if (success) {
                                         success((DSAPIOpportunityActivity *)newActivity);
                                     }
                                 }
                                 failure:failure];
}

- (NSURLSessionDataTask *)listActivitiesWithParameters:(NSDictionary *)parameters
                                                 queue:(NSOperationQueue *)queue
                                               success:(DSAPIPageSuccessBlock)success
                                               failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:kActivitiesKey
                               parameters:parameters
                                    queue:queue
                                  success:success
                                  failure:failure];
}

- (NSURLSessionDataTask *)listAttachmentsWithParameters:(NSDictionary *)parameters
                                                  queue:(NSOperationQueue *)queue
                                                success:(DSAPIPageSuccessBlock)success
                                                failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:[DSAPIAttachment classNamePlural]
                               parameters:parameters
                                    queue:queue
                                  success:success
                                  failure:failure];
}

- (NSURLSessionDataTask *)listTimelineWithParameters:(NSDictionary *)parameters
                                               queue:(NSOperationQueue *)queue
                                             success:(DSAPIPageSuccessBlock)success
                                             failure:(DSAPIFailureBlock)failure
{
    
    DSAPILink *linkToHistory = [[DSAPILink alloc] initWithDictionary:@{kHrefKey:[NSString stringWithFormat:@"%@/%@", self.linkToSelf.href, kHistoryKey], kClassKey:[DSAPIHistory className]} baseURL:self.client.baseURL];
    return [DSAPIResource listResourcesAt:linkToHistory
                               parameters:nil
                                   client:self.client
                                    queue:queue
                                  success:success
                                  failure:failure];
}

@end
