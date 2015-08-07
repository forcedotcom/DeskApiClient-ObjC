//
//  DSAPITestUtils.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/23/13.
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

#import "DSAPITestUtils.h"

CGFloat const DSAPIDefaultTimeout = 1.f;

@implementation DSAPITestUtils

+ (NSDictionary *)dictionaryFromJSONFile:(NSString *)filename
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    NSData *requestBody = [NSData dataWithContentsOfFile:filePath];
    return [NSJSONSerialization JSONObjectWithData:requestBody options:0 error:nil];
}

+ (DSAPIResource *)resourceFromJSONFile:(NSString *)filename
{
    NSDictionary *resourceDict = [self dictionaryFromJSONFile:filename];
    return [resourceDict DSAPIResourceWithSelf];
}

+ (NSDictionary *)authSettings
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"DeskAPIAuth-Info" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

+ (DSAPIClient *)APIClientTokenAuth
{
    DSAPIClient *client = [DSAPIClient new];
    [client setHostname:[DSAPITestUtils authSettings][@"Hostname"]
               APIToken:[DSAPITestUtils authSettings][@"APIToken"]];
    return client;
}

+ (DSAPIClient *)APIClientBasicAuth
{
    DSAPIClient *client = [DSAPIClient new];
    [client setHostname:[DSAPITestUtils authSettings][@"Hostname"]
               username:(NSString *)[DSAPITestUtils authSettings][@"BasicAuthUsername"]
               password:(NSString *)[DSAPITestUtils authSettings][@"BasicAuthPassword"]];
    return client;
}

+ (DSAPIClient *)APIClientOAuthUnauthorized
{
    DSAPIClient *client = [DSAPIClient new];
    [client setHostname:[DSAPITestUtils authSettings][@"Hostname"]
            consumerKey:[DSAPITestUtils authSettings][@"ConsumerKey"]
         consumerSecret:[DSAPITestUtils authSettings][@"ConsumerSecret"]
            callbackURL:[NSURL URLWithString:[DSAPITestUtils authSettings][@"CallbackURL"]]];
    return client;
}

+ (DSAPIClient *)APIClient
{
    
    DSAPIClient *client = [self APIClientOAuthUnauthorized];
    
    DSAPIOAuth1Token *token = [[DSAPIOAuth1Token alloc] initWithKey:[DSAPITestUtils authSettings][@"AccessToken"]
                                                             secret:[DSAPITestUtils authSettings][@"AccessTokenSecret"]
                                                            session:nil
                                                         expiration:nil
                                                          renewable:NO];
    client.accessToken = token;
    
    return client;
}

+ (void)setupSharedAPIClient
{
    [[DSAPIClient sharedManager] setHostname:[DSAPITestUtils authSettings][@"Hostname"]
                                    username:(NSString *)[DSAPITestUtils authSettings][@"BasicAuthUsername"]
                                    password:(NSString *)[DSAPITestUtils authSettings][@"BasicAuthPassword"]];
}

+ (NSTimeInterval)timeSinceEpoch
{
    return [NSDate timeIntervalSinceReferenceDate];
}

+ (NSString *)epochTimeAsString
{
    return [[NSString alloc] initWithFormat:@"%0.0f", [self timeSinceEpoch]];
}

+ (NSString *)uuid
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    return (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
}
@end
