//
//  DSAPIOpportunityActivity.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/17/16.
//  Copyright (c) 2016, Salesforce.com, Inc.
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

#import "DSAPIOpportunityActivity.h"
#import "DSAPIClient.h"

#define kClassName @"opportunity_activity"
#define kClassNamePlural @"opportunity_activities"

@implementation DSAPIOpportunityActivity

+ (NSString *)className
{
    return kClassName;
}

+ (NSString *)classNamePlural
{
    return kClassNamePlural;
}

#pragma mark - Class Methods

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIOpportunityActivity *opportunityActivity))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPIOpportunityActivity *)resource);
                                 }
                             }
                             failure:failure];
}

- (NSURLSessionDataTask *)createAttachment:(NSDictionary *)attachmentDictionary
                                     queue:(NSOperationQueue *)queue
                                   success:(void (^)(DSAPIAttachment *newAttachment))success
                                   failure:(DSAPIFailureBlock)failure
{
    DSAPILink *linkToActivities = [self linkForRelation:[DSAPIAttachment classNamePlural]];
    if (!linkToActivities) {
        NSDictionary *linkDictionary = @{kHrefKey:[NSString stringWithFormat:@"%@/%@", self.linkToSelf.href, [DSAPIAttachment classNamePlural]], kClassKey:[DSAPIAttachment className]};
        linkToActivities = [[DSAPILink alloc] initWithDictionary:linkDictionary
                                                         baseURL:self.client.baseURL];
    }
    return [DSAPIResource createResource:attachmentDictionary
                                    link:linkToActivities
                                  client:self.client
                                   queue:queue
                                 success:^(DSAPIResource *newAttachment) {
                                     if (success) {
                                         success((DSAPIAttachment *)newAttachment);
                                     }
                                 }
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

@end

