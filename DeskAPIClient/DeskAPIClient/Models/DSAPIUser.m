//
//  DSAPIUser.m
//  DeskAPIClient
//
//  Created by Desk.com on 10/3/13.
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

#import "DSAPIUser.h"
#import "DSAPIClient.h"

#define kClassName @"user"
#define kCurrentUserEndpoint @"me"

@implementation DSAPIUser

+ (NSString *)className
{
    return kClassName;
}

+ (DSAPILink *)linkForLoggedInUserWithBaseURL:(NSURL *)baseURL
{
    NSString *href = [NSString stringWithFormat:kAPIPrefix, [NSString stringWithFormat:@"%@/%@", [DSAPIUser classNamePlural], kCurrentUserEndpoint]];
    NSDictionary *linkDictionary = @{kHrefKey:href,
                                     kClassKey:[DSAPIUser className]};
    
    return [[DSAPILink alloc] initWithDictionary:linkDictionary baseURL:baseURL];
}


+ (DSAPILink *)linkForLoggedInUsersMobileDevicesWithBaseURL:(NSURL *)baseURL
{
    return [[DSAPIUser linkForLoggedInUserWithBaseURL:baseURL] linkFromRelationWithClass:[DSAPIMobileDevice class]];
}

+ (NSURLSessionDataTask *)listUsersWithParameters:(NSDictionary *)parameters
                                           client:(DSAPIClient *)client
                                            queue:(NSOperationQueue *)queue
                                          success:(DSAPIPageSuccessBlock)success
                                          failure:(DSAPIFailureBlock)failure
{
    return [self listUsersWithParameters:parameters
                                  client:client
                                   queue:queue
                                 success:success
                             notModified:nil
                                 failure:failure];
}


+ (NSURLSessionDataTask *)listUsersWithParameters:(NSDictionary *)parameters
                                           client:(DSAPIClient *)client
                                            queue:(NSOperationQueue *)queue
                                          success:(DSAPIPageSuccessBlock)success
                                      notModified:(DSAPIPageSuccessBlock)notModified
                                          failure:(DSAPIFailureBlock)failure
{
    return [super listResourcesAt:[DSAPIUser classLinkWithBaseURL:client.baseURL]
                       parameters:parameters
                           client:client
                            queue:queue
                          success:success
                      notModified:notModified
                          failure:failure];
}


+ (NSURLSessionDataTask *)showCurrentUserWithParameters:(NSDictionary *)parameters
                                                 client:(DSAPIClient *)client
                                                  queue:(NSOperationQueue *)queue
                                                success:(void (^)(DSAPIUser *))success
                                                failure:(DSAPIFailureBlock)failure
{
    
    return [client GET:[self linkForLoggedInUserWithBaseURL:client.baseURL].href
            parameters:parameters
                 queue:queue
               success:^(NSHTTPURLResponse *response, id responseObject) {
                   if (success) {
                       success((DSAPIUser *)[responseObject DSAPIResourceWithClient:client]);
                   }
               }
               failure:^(NSHTTPURLResponse *response, NSError *error) {
                   [client postRateLimitingNotificationIfNecessary:response];
                   if (failure) {
                       failure(response, error);
                   }
               }];
}


+ (NSURLSessionDataTask *)logoutCurrentUserWithClient:(DSAPIClient *)client
                                                queue:(NSOperationQueue *)queue
                                              success:(void (^)(void))success
                                              failure:(DSAPIFailureBlock)failure
{
    NSString *logoutLink = [NSString stringWithFormat:@"%@/logout", [self linkForLoggedInUserWithBaseURL:client.baseURL].href];
    return [client POST:logoutLink
             parameters:nil
                  queue:queue
                success:^(NSHTTPURLResponse *response, id responseObject) {
                    if (success) {
                        success();
                    }
                }
                failure:^(NSHTTPURLResponse *response, NSError *error) {
                    [client postRateLimitingNotificationIfNecessary:response];
                    if (failure) {
                        failure(response, error);
                    }
                }];
}


+ (NSURLSessionDataTask *)listMyMobileDevicesWithParameters:(NSDictionary *)parameters
                                                     client:(DSAPIClient *)client
                                                      queue:(NSOperationQueue *)queue
                                                    success:(DSAPIPageSuccessBlock)success
                                                notModified:(DSAPIPageSuccessBlock)notModified
                                                    failure:(DSAPIFailureBlock)failure
{
    return [DSAPIResource listResourcesAt:[self linkForLoggedInUsersMobileDevicesWithBaseURL:client.baseURL]
                               parameters:parameters
                                   client:client
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIUser *filter))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPIUser *)resource);
                                 }
                             }
                             failure:failure];
}

- (NSURLSessionDataTask *)listPreferencesWithParameters:(NSDictionary *)parameters
                                                  queue:(NSOperationQueue *)queue
                                                success:(DSAPIPageSuccessBlock)success
                                                failure:(DSAPIFailureBlock)failure
{
    return [self listPreferencesWithParameters:parameters
                                         queue:queue
                                       success:success
                                   notModified:nil
                                       failure:failure];
}


- (NSURLSessionDataTask *)listPreferencesWithParameters:(NSDictionary *)parameters
                                                  queue:(NSOperationQueue *)queue
                                                success:(DSAPIPageSuccessBlock)success
                                            notModified:(DSAPIPageSuccessBlock)notModified
                                                failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:[DSAPIUserPreference classNamePlural]
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:(DSAPIPageSuccessBlock)notModified
                                  failure:failure];
}


- (NSURLSessionDataTask *)listCaseFiltersWithParameters:(NSDictionary *)parameters
                                                  queue:(NSOperationQueue *)queue
                                                success:(DSAPIPageSuccessBlock)success
                                                failure:(DSAPIFailureBlock)failure
{
    return [self listCaseFiltersWithParameters:parameters
                                     queue:queue
                                   success:success
                               notModified:nil
                                   failure:failure];
}


- (NSURLSessionDataTask *)listCaseFiltersWithParameters:(NSDictionary *)parameters
                                                  queue:(NSOperationQueue *)queue
                                                success:(DSAPIPageSuccessBlock)success
                                            notModified:(DSAPIPageSuccessBlock)notModified
                                                failure:(DSAPIFailureBlock)failure
{
    return [DSAPIResource listResourcesAt:[self.linkToSelf linkFromRelationWithClass:[DSAPICaseFilter class]]
                               parameters:parameters
                                   client:self.client
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}


- (NSURLSessionDataTask *)listGroupsWithParameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                           failure:(DSAPIFailureBlock)failure
{
    return [self listGroupsWithParameters:parameters
                                    queue:queue
                                  success:success
                              notModified:nil
                                  failure:failure];
}


- (NSURLSessionDataTask *)listGroupsWithParameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                       notModified:(DSAPIPageSuccessBlock)notModified
                                           failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:[DSAPIGroup classNamePlural]
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}

- (NSURLSessionDataTask *)listMacrosWithParameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                       notModified:(DSAPIPageSuccessBlock)notModified
                                           failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:[DSAPIMacro classNamePlural]
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}

- (NSURLSessionDataTask *)listCompanyFiltersWithParameters:(NSDictionary *)parameters
                                                     queue:(NSOperationQueue *)queue
                                                   success:(DSAPIPageSuccessBlock)success
                                                   failure:(DSAPIFailureBlock)failure
{
    return [DSAPIResource listResourcesAt:[self.linkToSelf linkFromRelationWithClass:[DSAPICompanyFilter class]]
                               parameters:parameters
                                   client:self.client
                                    queue:queue
                                  success:success
                              notModified:nil
                                  failure:failure];
}

- (NSURLSessionDataTask *)listCustomerFiltersWithParameters:(NSDictionary *)parameters
                                                      queue:(NSOperationQueue *)queue
                                                    success:(DSAPIPageSuccessBlock)success
                                                    failure:(DSAPIFailureBlock)failure
{
    return [DSAPIResource listResourcesAt:[self.linkToSelf linkFromRelationWithClass:[DSAPICustomerFilter class]]
                               parameters:parameters
                                   client:self.client
                                    queue:queue
                                  success:success
                              notModified:nil
                                  failure:failure];

}

@end
