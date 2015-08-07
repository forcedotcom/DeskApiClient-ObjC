//
//  DSAPIResource.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/20/13.
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

#import "DSAPIClient.h"
#import <objc/runtime.h>
#import "DSAPIETagCache.h"
#import <DeskCommon/DSCHttpStatusCodes.h>

#define kETagHeader @"ETag"
#define kIfNoneMatchHeader @"If-None-Match"

#define kSearchEndpoint @"search"

#define kEncoderKeyDictionary @"DSAPIResourceDictionary"
#define kEncoderKeyBaseURL @"DSAPIResourceBaseURL"

@interface DSAPIResource ()

@property (nonatomic, strong) NSMutableDictionary *embedded;
@property (nonatomic, strong) NSURL *baseURL;

@end

@implementation DSAPIResource {
    NSMutableDictionary *_linksArrays;
    NSMutableDictionary *_dictionary;
}

+ (DSAPIResource *)resourceWithHref:(NSString *)href className:(NSString *)className
{
    return [[self alloc] initWithDictionary:@{kLinksKey :
                                                  @{kSelfKey :
                                                        @{kHrefKey : href,
                                                          kClassKey : className}}}];
}

+ (DSAPIResource *)resourceWithId:(NSString *)resourceId className:(NSString *)className
{
    NSString *classNamePlural = [[[DSAPIClient sharedManager] classForClassName:className] classNamePlural];
    NSString *href = [[NSString stringWithFormat:kAPIPrefix, classNamePlural] stringByAppendingPathComponent:resourceId];
    return [self resourceWithHref:href className:className];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSURL *baseURL;
    if (!(baseURL = [DSAPIClient sharedManager].baseURL)) {
        baseURL = [NSURL URLWithString:@""];
    }
    return [self initWithDictionary:dictionary baseURL:baseURL];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
                 baseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _linksArrays = [NSMutableDictionary new];
        _embedded = [NSMutableDictionary new];
        _dictionary = [dictionary mutableCopy];
        _baseURL = baseURL;
        
        // If we can't parse the dictionary, just return nil
        if (![self parseResource]) {
            return nil;
        }
        
        // Set the class of the object to the class returned by the web service for self
        object_setClass(self, [[DSAPIClient sharedManager] classForClassName:_dictionary[kLinksKey][kSelfKey][kClassKey]]);
    }
    return self;
}

- (NSString *)description
{
    return [_dictionary description];
}

- (DSAPILink *)classLink
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)parseResource
{
    if (![NSJSONSerialization isValidJSONObject:_dictionary]) {
        return NO;
    }
    if (!_baseURL) {
        return NO;
    }
    if (![self parseLinks]) {
        return NO;
    }
    if (![self parseEmbedded]) {
        return NO;
    }
    if (![self parseNew]) {
        return NO;
    }
    if (![self parseChanged]) {
        return NO;
    }
    return YES;
}

- (BOOL)parseLinks
{
    id linkDictionaries = _dictionary[kLinksKey];
    if (!linkDictionaries) {
        return YES;
    }
    if (![linkDictionaries isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    for (id relation in [linkDictionaries allKeys]) {
        id linkOrLinks = linkDictionaries[relation];
        NSArray *links = [self extractLinkOrLinks:linkOrLinks];
        if (!links) {
            _linksArrays[relation] = [NSNull null];
        } else {
            _linksArrays[relation] = links;
        }
    }
    return YES;
}

- (NSArray *)extractLinkOrLinks:(id)linkOrLinks
{
    if ([linkOrLinks isKindOfClass:[NSDictionary class]]) {
        return [self extractArrayOfLinks:@[ linkOrLinks ]];
    } else if ([linkOrLinks isKindOfClass:[NSArray class]]) {
        return [self extractArrayOfLinks:linkOrLinks];
    }
    return nil;
}

- (NSArray *)extractArrayOfLinks:(NSArray *)linkArray
{
    NSMutableArray *links = [NSMutableArray new];
    for (id dictionary in linkArray) {
        DSAPILink *link = [[DSAPILink alloc] initWithDictionary:dictionary baseURL:self.baseURL];
        if (!link) {
            return nil;
        }
        [links addObject:link];
    }
    return links;
}

- (BOOL)parseEmbedded
{
    return [self parseEmbeddedAtRelation:kEmbeddedKey];
}

- (BOOL)parseNew
{
    return [self parseEmbeddedAtRelation:kNewEntriesKey];
}

- (BOOL)parseChanged
{
    return [self parseEmbeddedAtRelation:kChangedEntriesKey];
}

- (BOOL)parseEmbeddedAtRelation:(id)relation
{
    id embedded = _dictionary[relation];
    if (!embedded) {
        return YES;
    }
    if ([embedded isKindOfClass:[NSDictionary class]]) {
        return [self parseEmbeddedDictionaries:embedded];
    } else if ([embedded isKindOfClass:[NSArray class]]) {
        return [self parseEmbeddedArrayOfDictionaries:embedded atRelation:relation];
    }
    return NO;
}

- (BOOL)parseEmbeddedDictionaries:(NSDictionary *)embeddedDictionaries
{
    for (id relation in [embeddedDictionaries allKeys]) {
        id resourceOrResources = embeddedDictionaries[relation];
        [self embedResourceOrResources:resourceOrResources atRelation:relation];
    }
    return YES;
}

- (BOOL)parseEmbeddedArrayOfDictionaries:(NSArray *)embeddedArrayOfDictionaries atRelation:(id)relation
{
    [self embedResourceOrResources:embeddedArrayOfDictionaries atRelation:relation];
    return YES;
}

- (void)embedResourceOrResources:(id)resourceOrResources atRelation:(id)relation
{
    NSArray *resources = [self extractResourceOrResources:resourceOrResources];
    if (!resources) {
        _embedded[relation] = [NSNull null];
    } else {
        _embedded[relation] = resources;
    }
}

- (NSArray *)extractResourceOrResources:(id)resourceOrResources
{
    if ([resourceOrResources isKindOfClass:[NSDictionary class]]) {
        return [self extractArrayOfResources:@[ resourceOrResources ]];
    } else if ([resourceOrResources isKindOfClass:[NSArray class]]) {
        return [self extractArrayOfResources:resourceOrResources];
    }
    return nil;
}

- (NSArray *)extractArrayOfResources:(NSArray *)resourceArray
{
    NSMutableArray *resources = [NSMutableArray new];
    for (id dictionary in resourceArray) {
        DSAPIResource *resource = [[DSAPIResource alloc] initWithDictionary:dictionary];
        if (!resource) {
            return nil;
        }
        [resources addObject:resource];
    }
    return resources;
}

- (DSAPILink *)linkForRelation:(NSString *)relation
{
    NSArray *links = [self linksForRelation:relation];
    return [links count] > 0 ? links[0] : nil;
}

- (DSAPILink *)linkForRelation:(NSString *)relation className:(NSString *)className
{
    NSArray *links = [self linksForRelation:relation];
    for (DSAPILink *link in links) {
        if ([className isEqualToString:link.className]) {
            return link;
        }
    }
    return nil;
}

- (NSArray *)linksForRelation:(NSString *)relation
{
    return _linksArrays[relation] != [NSNull null] ? _linksArrays[relation] : nil;
}

- (DSAPIResource *)resourceForRelation:(NSString *)relation
{
    NSArray *resources = [self resourcesForRelation:relation];
    return resources[0];
}

- (NSArray *)resourcesForRelation:(NSString *)relation
{
    return _embedded[relation] != [NSNull null] ? _embedded[relation] : nil;
}

- (NSDictionary *)links
{
    return _linksArrays;
}

- (NSDictionary *)dictionary
{
    return _dictionary;
}

- (DSAPILink *)linkToSelf
{
    return [self linkForRelation:kSelfKey];
}

+ (DSAPILink *)classLink
{
    return [[DSAPILink alloc] initWithDictionary:@{kHrefKey : [NSString stringWithFormat:kAPIPrefix, self.classNamePlural], kClassKey : self.className}];
}

+ (NSString *)className
{
    NSString *errorMessage = [NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    NSAssert(NO, errorMessage);
    return nil;
}

+ (NSString *)classNamePlural
{
    return [NSString stringWithFormat:@"%@s", self.className];
}

- (id)objectForKeyedSubscript:(id)key
{
    if ([kEmbeddedKey isEqualToString:key]) {
        return nil;
    }
    return _dictionary[key] != [NSNull null] ? _dictionary[key] : nil;
}

- (id)valueForKey:(NSString *)key
{
    id value = [self objectForKeyedSubscript:key];
    if (value) {
        return value;
    }
    return [super valueForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if ([kLinksKey isEqualToString:(NSString *)key] || [kEmbeddedKey isEqualToString:(NSString *)key]) {
        return;
    }
    if (obj == nil) {
        [_dictionary removeObjectForKey:key];
    } else {
        [_dictionary setObject:obj forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [self setObject:value forKeyedSubscript:key];
}

#pragma mark - Generic CRUD Methods

+ (NSURLSessionDataTask *)listResourcesAt:(DSAPILink *)link
                               parameters:(NSDictionary *)parameters
                                    queue:(NSOperationQueue *)queue
                                  success:(DSAPIPageSuccessBlock)success
                                  failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesAt:link
                      parameters:parameters
                           queue:(NSOperationQueue *)queue
                         success:success
                     notModified:nil
                         failure:failure];
}

+ (NSURLSessionDataTask *)listResourcesAt:(DSAPILink *)link
                               parameters:(NSDictionary *)parameters
                                    queue:(NSOperationQueue *)queue
                                  success:(DSAPIPageSuccessBlock)success
                              notModified:(DSAPIPageSuccessBlock)notModified
                                  failure:(DSAPIFailureBlock)failure
{
    DSAPIClient *client = [DSAPIClient sharedManager];
    NSString *urlString = [[NSURL URLWithString:link.href relativeToURL:client.baseURL] absoluteString];
    NSError *error = nil;
    NSMutableURLRequest *request = [client.requestSerializer requestWithMethod:@"GET"
                                                                     URLString:urlString
                                                                    parameters:parameters
                                                                         error:&error];
    if (error && failure) {
        failure(nil, error);
    } else if (!error) {
        // This is the cache policy we need in order to make etags work
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        
        if (notModified) {
            NSString *etag = [[DSAPIETagCache sharedManager] eTagForURL:request.URL];
            if (etag) {
                [request setValue:etag forHTTPHeaderField:kIfNoneMatchHeader];
            }
        }
        NSURLSessionDataTask *task =
        [client dataTaskWithRequest:request
                              queue:queue
                            success:^(NSHTTPURLResponse *response, id responseObject) {
                                DSAPIResource *resource = [responseObject DSAPIResourceWithSelf];
                                NSString *etag = [[response allHeaderFields] objectForKey:kETagHeader];
                                if (etag) {
                                    [[DSAPIETagCache sharedManager] setETag:etag forURL:request.URL nextPageURL:[resource linkForRelation:kNextKey].URL];
                                }
                                if (success) {
                                    success((DSAPIPage *)resource);
                                }
                            }
                            failure:^(NSHTTPURLResponse *response, NSError *error) {
                                if (notModified && [response statusCode] == DSC_HTTP_STATUS_NOT_MODIFIED) {
                                    DSAPIPage *page = [DSAPIPage pageFromPageHref:[[DSAPIETagCache sharedManager] pageURLForURL:request.URL].relativeString withNextPageHref:[[DSAPIETagCache sharedManager] nextPageURLForURL:request.URL].relativeString];
                                    page.notModified = YES;
                                    if (notModified) {
                                        notModified(page);
                                    }
                                } else {
                                    [client postRateLimitingNotificationIfNecessary:response];
                                    if (failure) {
                                        failure(response, error);
                                    }
                                }
                            }];
        
        [task resume];
        return task;
    }
    return nil;
}

+ (NSURLSessionDataTask *)searchResourcesAt:(DSAPILink *)link
                                 parameters:(NSDictionary *)parameters
                                      queue:(NSOperationQueue *)queue
                                    success:(DSAPIPageSuccessBlock)success
                                    failure:(DSAPIFailureBlock)failure
{
    return [self searchResourcesAt:link
                        parameters:parameters
                             queue:queue
                           success:success
                       notModified:nil
                           failure:failure];
}

+ (NSURLSessionDataTask *)searchResourcesAt:(DSAPILink *)link
                                 parameters:(NSDictionary *)parameters
                                      queue:queue
                                    success:(DSAPIPageSuccessBlock)success
                                notModified:(DSAPIPageSuccessBlock)notModified
                                    failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesAt:[self searchEndpointForClassLink:link]
                      parameters:parameters
                           queue:queue
                         success:success
                     notModified:notModified
                         failure:failure];
}

+ (DSAPILink *)searchEndpointForClassLink:(DSAPILink *)classLink
{
    NSString *searchURL = [NSString stringWithFormat:@"%@/%@", classLink.href, kSearchEndpoint];
    return [[DSAPILink alloc] initWithDictionary:@{kHrefKey : searchURL,
                                                   kClassKey : classLink.className}];
}

+ (NSURLSessionDataTask *)createResource:(NSDictionary *)resourceDict
                                  link:(DSAPILink *)link
                                   queue:queue
                                 success:(DSAPIResourceSuccessBlock)success
                                 failure:(DSAPIFailureBlock)failure
{
    DSAPIClient *client = [DSAPIClient sharedManager];
    return [client POST:link.href
             parameters:resourceDict
                  queue:queue
                success:^(NSHTTPURLResponse *response, id responseObject) {
                    if (success) {
                        success([responseObject DSAPIResourceWithSelf]);
                    }
                }
                failure:^(NSHTTPURLResponse *response, NSError *error) {
                    [client postRateLimitingNotificationIfNecessary:response];
                    if (failure) {
                        failure(response, error);
                    }
                }];
}

+ (NSURLSessionDataTask *)showResourceAtLink:(DSAPILink *)linkToResource
                                  parameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(DSAPIResourceSuccessBlock)success
                                     failure:(DSAPIFailureBlock)failure
{
    DSAPIClient *client = [DSAPIClient sharedManager];
    return [client GET:linkToResource.href
            parameters:parameters
                 queue:queue
               success:^(NSHTTPURLResponse *response, id responseObject) {
                   if (success) {
                       success([responseObject DSAPIResourceWithSelf]);
                   }
               }
               failure:^(NSHTTPURLResponse *response, NSError *error) {
                   [client postRateLimitingNotificationIfNecessary:response];
                   if (failure) {
                       failure(response, error);
                   }
               }];
}

- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(DSAPIResourceSuccessBlock)success
                                     failure:(DSAPIFailureBlock)failure
{
    return [[self class] showResourceAtLink:self.linkToSelf
                                 parameters:parameters
                                      queue:queue
                                    success:success
                                    failure:failure];
}

- (NSURLSessionDataTask *)updateWithDictionary:(NSDictionary *)dictionary
                                         queue:(NSOperationQueue *)queue
                                       success:(DSAPIResourceSuccessBlock)success
                                       failure:(DSAPIFailureBlock)failure
{
    DSAPIClient *client = [DSAPIClient sharedManager];
    return [client PATCH:self.linkToSelf.href
              parameters:dictionary
                   queue:queue
                 success:^(NSHTTPURLResponse *response, id responseObject) {
                     if (success) {
                         success([responseObject DSAPIResourceWithSelf]);
                     }
                 }
                 failure:^(NSHTTPURLResponse *response, NSError *error) {
                     [client postRateLimitingNotificationIfNecessary:response];
                     if (failure) {
                         failure(response, error);
                     }
                 }];
}

- (NSURLSessionDataTask *)listResourcesForRelation:(NSString *)relation
                                        parameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                           failure:(DSAPIFailureBlock)failure
{
    return [self listResourcesForRelation:relation
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:nil
                                  failure:failure];
}

- (NSURLSessionDataTask *)listResourcesForRelation:(NSString *)relation
                                        parameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                       notModified:(DSAPIPageSuccessBlock)notModified
                                           failure:(DSAPIFailureBlock)failure
{
    DSAPILink *linkToRelation = [self linkForRelation:relation];
    return [DSAPIResource listResourcesAt:linkToRelation
                               parameters:parameters
                                    queue:queue
                                  success:success
                              notModified:notModified
                                  failure:failure];
}

- (NSURLSessionDataTask *)deleteWithParameters:(NSDictionary *)parameters
                                         queue:(NSOperationQueue *)queue
                                       success:(void (^)(void))success
                                       failure:(DSAPIFailureBlock)failure
{
    DSAPIClient *client = [DSAPIClient sharedManager];
    return [client DELETE:self.linkToSelf.href
               parameters:parameters
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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *dictionary = [aDecoder decodeObjectForKey:kEncoderKeyDictionary];
    NSURL *baseURL = [aDecoder decodeObjectForKey:kEncoderKeyBaseURL];
    return [self initWithDictionary:dictionary baseURL:baseURL];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dictionary forKey:kEncoderKeyDictionary];
    [aCoder encodeObject:self.baseURL forKey:kEncoderKeyBaseURL];
}

- (NSString *)idFromSelfLink
{
    return [[[self linkToSelf] URL] lastPathComponent];
}

@end
