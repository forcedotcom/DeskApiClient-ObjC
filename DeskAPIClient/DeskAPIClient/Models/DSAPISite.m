//
//  DSAPISite.m
//  DeskAPIClient
//
//  Created by Desk.com on 11/10/14.
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

#import "DSAPISite.h"
#import "DSAPIClient.h"

#define kClassName @"site"
#define kCurrentSiteURL @"/api/v2/site"

@implementation DSAPISite

+ (NSString *)className
{
    return kClassName;
}

+ (NSURLSessionDataTask *)showCurrentSiteWithQueue:(NSOperationQueue *)queue
                         success:(void (^)(DSAPISite *apiSite))success
                         failure:(DSAPIFailureBlock)failure
{
    return [self showCurrentSiteWithParameters:nil
                                  queue:queue
                                success:success
                                failure:failure];
}

+ (NSURLSessionDataTask *)showCurrentSiteWithParameters:(NSDictionary *)parameters
                                queue:(NSOperationQueue *)queue
                              success:(void (^)(DSAPISite *site))success
                              failure:(DSAPIFailureBlock)failure
{
    DSAPISite *site = (DSAPISite *)[DSAPIResource resourceWithHref:kCurrentSiteURL
                                                         className:[self className]];
    return [site showWithParameters:parameters
                       queue:queue
                     success:success
                     failure:failure];
}

+ (NSURLSessionDataTask *)showCurrentSiteBillingWithQueue:(NSOperationQueue *)queue
                                success:(void (^)(DSAPIBilling *billing))success
                                failure:(DSAPIFailureBlock)failure
{
    return [self showCurrentSiteBillingWithParameters:nil
                                         queue:queue
                                       success:success
                                       failure:failure];
}

+ (NSURLSessionDataTask *)showCurrentSiteBillingWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIBilling *))success
                                     failure:(DSAPIFailureBlock)failure
{
    DSAPISite *site = (DSAPISite *)[DSAPIResource resourceWithHref:kCurrentSiteURL
                                                         className:[self className]];
    return [site showBillingWithParameters:parameters
                              queue:queue
                            success:success
                            failure:failure];
}

- (NSURLSessionDataTask *)showWithQueue:(NSOperationQueue *)queue
              success:(void (^)(DSAPISite *site))success
              failure:(DSAPIFailureBlock)failure
{
    return [self showWithParameters:nil
                       queue:queue
                     success:success
                     failure:failure];
}

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                     queue:(NSOperationQueue *)queue
                   success:(void (^)(DSAPISite *site))success
                   failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                        queue:queue
                      success:^(DSAPIResource *resource) {
                          if (success) {
                              success((DSAPISite *)resource);
                          }
                      }
                      failure:failure];
}

- (NSURLSessionDataTask *)showBillingWithParameters:(NSDictionary *)parameters
                            queue:(NSOperationQueue *)queue
                          success:(void (^)(DSAPIBilling *))success
                          failure:(DSAPIFailureBlock)failure
{
    NSString *billingHref = [NSString stringWithFormat:@"%@/%@", self.linkToSelf, [DSAPIBilling className]];
    DSAPIBilling *billing = (DSAPIBilling *)[DSAPIResource resourceWithHref:billingHref
                                                                  className:[DSAPIBilling className]];
    
    return [billing showWithParameters:parameters
                          queue:queue
                        success:^(DSAPIResource *resource) {
                            if (success) {
                                success((DSAPIBilling *)resource);
                            }
                        }
                        failure:failure];
}

@end

