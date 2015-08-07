//
//  DSAPIMobileDevice.m
//  DeskAPIClient
//
//  Created by Desk.com on 4/4/14.
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

#import "DSAPIMobileDevice.h"
#import "DSAPIMobileDeviceSetting.h"
#import "DSAPIUser.h"

#define kClassName @"mobile_device"

@interface DSAPIMobileDevice()

@property (nonatomic, readonly) DSAPILink *linkToSettings;

@end

@implementation DSAPIMobileDevice

+ (NSString *)className
{
    return kClassName;
}

- (DSAPILink *)linkToSettings
{
    return [self.linkToSelf linkFromRelationWithClass:[DSAPIMobileDeviceSetting class]];
}

+ (NSURLSessionDataTask *)createMobileDevice:(NSDictionary *)mobileDeviceDict
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIMobileDevice *))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super createResource:mobileDeviceDict
                          link:[DSAPIUser linkForLoggedInUsersMobileDevices]
                           queue:queue
                         success:^(DSAPIResource *resource) {
                             if (success) {
                                 success((DSAPIMobileDevice *)resource);
                             }
                         } failure:failure];
}

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIMobileDevice *))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPIMobileDevice *)resource);
                                 }
                             }
                             failure:failure];
}

- (NSURLSessionDataTask *)listSettingsWithParameters:(NSDictionary *)parameters
                                               queue:(NSOperationQueue *)queue
                                             success:(DSAPIPageSuccessBlock)success
                                         notModified:(DSAPIPageSuccessBlock)notModified
                                             failure:(DSAPIFailureBlock)failure
{
    return [DSAPIResource listResourcesAt:self.linkToSettings
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:(DSAPIPageSuccessBlock)notModified
                                  failure:failure];
}

@end
