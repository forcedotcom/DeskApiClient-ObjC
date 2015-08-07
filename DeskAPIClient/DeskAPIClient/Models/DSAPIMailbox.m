//
//  DSAPIMailbox.m
//  DeskAPIClient
//
//  Created by Desk.com on 6/23/14.
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

#import "DSAPIMailbox.h"

#define kClassName @"mailbox"
#define kClassNamePlural @"mailboxes"

NSString *const DSAPIMailboxTypeOutbound = @"outbound";
NSString *const DSAPIMailboxTypeInbound = @"inbound";

@interface DSAPIMailbox()

+ (BOOL)isValidMailboxType:(NSString *)mailboxType;

@end

@implementation DSAPIMailbox

+ (NSString *)className
{
    return kClassName;
}

+ (NSString *)classNamePlural
{
    return kClassNamePlural;
}

#pragma mark - Class Methods

+ (NSURLSessionDataTask *)listMailboxesOfType:(NSString *)mailboxType
                                   parameters:(NSDictionary *)parameters
                                        queue:(NSOperationQueue *)queue
                                      success:(DSAPIPageSuccessBlock)success
                                      failure:(DSAPIFailureBlock)failure
{
    return [self listMailboxesOfType:mailboxType
                          parameters:parameters
                               queue:queue
                             success:success
                         notModified:nil
                             failure:failure];
}

+ (NSURLSessionDataTask *)listMailboxesOfType:(NSString *)mailboxType
                                   parameters:(NSDictionary *)parameters
                                        queue:(NSOperationQueue *)queue
                                      success:(DSAPIPageSuccessBlock)success
                                  notModified:(DSAPIPageSuccessBlock)notModified
                                      failure:(DSAPIFailureBlock)failure
{
    if ([self isValidMailboxType:mailboxType]) {
        NSString *modifiedHref = [NSString stringWithFormat:@"%@/%@", [DSAPIMailbox classLink].href, mailboxType];
        DSAPILink *link = [[DSAPILink alloc] initWithDictionary:@{kHrefKey:modifiedHref,
                                                                  kClassKey:self.className}];
        return [super listResourcesAt:link
                           parameters:parameters
                                queue:queue
                              success:success
                          notModified:notModified
                              failure:failure];
    }
    return nil;
}

+ (NSString *)outboundMailboxClassName
{
    return [NSString stringWithFormat:@"%@_%@", DSAPIMailboxTypeOutbound, [self className]];
}

+ (NSString *)inboundMailboxClassName
{
    return [NSString stringWithFormat:@"%@_%@", DSAPIMailboxTypeInbound, [self className]];
}

+ (BOOL)isValidMailboxType:(NSString *)mailboxType
{
    return [mailboxType isEqualToString:DSAPIMailboxTypeOutbound] | [mailboxType isEqualToString:DSAPIMailboxTypeInbound];
}


#pragma mark - Instance Methods

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(void (^)(DSAPIMailbox *))success
                                     failure:(DSAPIFailureBlock)failure
{
    return [super showWithParameters:parameters
                               queue:queue
                             success:^(DSAPIResource *resource) {
                                 if (success) {
                                     success((DSAPIMailbox *)resource);
                                 }
                             }
                             failure:failure];
}


@end
