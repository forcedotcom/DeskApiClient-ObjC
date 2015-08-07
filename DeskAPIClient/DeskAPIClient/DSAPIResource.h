//
//  DSAPIResource.h
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

#import <Foundation/Foundation.h>
#import "DSAPITypes.h"
#import "DSAPILink.h"

#define kAPIPrefix @"/api/v2/%@"
#define kSelfKey @"self"
#define kNextKey @"next"
#define kPreviousKey @"previous"
#define kFirstKey @"first"
#define kLastKey @"last"
#define kLinksKey @"_links"
#define kEmbeddedKey @"_embedded"
#define kNewEntriesKey @"new"
#define kChangedEntriesKey @"changed"
#define kRemovedEntriesKey @"removed"
#define kPositionsKey @"positions"
#define kTimeKey @"time"
#define kPageKey @"page"
#define kPerPageKey @"per_page"

@class DSAPILink;
@class DSAPIPage;

@interface DSAPIResource : NSObject <NSCoding>

@property (nonatomic, readonly) NSDictionary *links;
@property (nonatomic, readonly) NSDictionary *dictionary;
@property (nonatomic, readonly) DSAPILink *linkToSelf;

/* A note on KVC Support for `DSAPIResource`s
 *
 * Any of the properties above can be accessed using KVC, e.g. `[resource valueForKey:@"linkToSelf"]`
 * Additionally, you can access the resource's underlying API fields using KVC as follows:
 * `[caseResource valueForKey:@"subject"]`, or even `[caseResource valueForKey:@"_links"]`.
 *
 * A special note on accessing the `links` property above, vs. the `_links` key: the former (`links`)
 * will return a dictionary in which each link relation points to an array of links. This is in order
 * to match the HAL spec (http://stateless.co/hal_specification.html) while retaining type information.
 * The HAL spec states that link relations may point to single or multiple links. If a link relation
 * points to a single link, you will get an array with one object for the given link relation in `links`.
 
 * The latter (`_links`) will return the representation sent by the API, in which link relations that
 * point to a single link will return a dictionary representing that link, rather than an array. In the
 * API, arrays are only used for link relations that point to more than one link.
 *
 * You can also use subscripting to access the underlying API fields, as in:
 * `resource[@"subject"]`
 */

+ (DSAPILink *)classLink;
+ (NSString *)className;
+ (NSString *)classNamePlural;

#pragma mark - Accessors

/**
 Allocates and initializes a `DSAPIResource` from the href and className that describe the resource's "self" link.
 
 @return The `DSAPIResource`
 */
+ (DSAPIResource *)resourceWithHref:(NSString *)href className:(NSString *)className;

/**
 Allocates and initializes a `DSAPIResource` from the resource's id and className that describe the resource's "self" link.
 Assumes that the className should be pluralized when creating the self link.
 
 @return The `DSAPIResource`
 */
+ (DSAPIResource *)resourceWithId:(NSString *)resourceId className:(NSString *)className;

/**
 Initializes a `DSAPIResource` given a dictionary.
 
 @param dataDictionary The dictionary that describes the resource
 
 @return The `DSAPIResource`, cast to the proper class as defined by the dictionary's self.class field.
 */
- (id)initWithDictionary:(NSDictionary *)dataDictionary;

/**
 Initializes a `DSAPIResource` given a dictionary and baseURL.
 
 @param dataDictionary The dictionary that describes the resource
 @param baseURL The baseURL for the web service that provides the resource
 
 @return The `DSAPIResource`, cast to the proper class as defined by the dictionary's self.class field.
 */
- (id)initWithDictionary:(NSDictionary *)dataDictionary
                 baseURL:(NSURL *)baseURL;

/**
 Returns a `DSAPILink` for a given relation.
 
 @param relation A string stating the relation (e.g., @"self", @"message", @"replies")
 
 @return The `DSAPILink` for the relation.
 */
- (DSAPILink *)linkForRelation:(NSString *)relation;

/**
 Returns a `DSAPILink` for a given relation, of a particular class. This is used in cases where more than one class may be listed for a given relation.
 
 @param relation A string stating the relation (e.g., @"self", @"message", @"replies")
 @param className A string stating the class name (e.g., @"case", @"tweet", @"customer")
 
 @return The `DSAPILink` for the relation and class name.
 */
- (DSAPILink *)linkForRelation:(NSString *)relation className:(NSString *)className;

/**
 Returns an array of `DSAPILink` for a given relation. This is used in cases where more than one link appears at a given relation.
 
 @param relation A string stating the relation (e.g., @"self", @"message", @"replies")
 
 @return The array of `DSAPILink` for the relation.
 */
- (NSArray *)linksForRelation:(NSString *)relation;

/**
 Returns a `DSAPIResource` for an embedded relation.
 
 @param relation A string stating the embedded relation (e.g., @"customer", @"case", @"message")
 
 @return The `DSAPIResource` for the embedded relation.
 */
- (DSAPIResource *)resourceForRelation:(NSString *)relation;

/**
 Returns an array of `DSAPIResource` for an embedded relation. This is used in cases where more than one embedded resource appears at a given relation.
 
 @param relation A string stating the embedded relation (e.g., @"replies", @"cases")
 
 @return The array of `DSAPIResource` for the embedded relation.
 */
- (NSArray *)resourcesForRelation:(NSString *)relation;

/**
 Sets an object to a given keyed subscript. Allows you to do things like myCase[@"subject"] = @"Hello, World."
 
 @param obj The object to set.
 @param key The key at which to set it.
 */
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

/**
 Gets the object at a given keyed subscript. Allows you to access fields like myCase[@"subject"]
 
 @param obj The object to set.
 @param key The key at which to set it.
 */
- (id)objectForKeyedSubscript:(id)key;

#pragma mark - Generic CRUD Methods
/**
 Lists resources by calling a GET request to the link provided.
 
 @param link The link for the collection of `DSAPIResource`
 @param parameters The querystring parameters to be sent with the GET request
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page (`DSAPIPage`) of resources returned by the GET request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
+ (NSURLSessionDataTask *)listResourcesAt:(DSAPILink *)link
                               parameters:(NSDictionary *)parameters
                                    queue:(NSOperationQueue *)queue
                                  success:(DSAPIPageSuccessBlock)success
                                  failure:(DSAPIFailureBlock)failure;
/**
 Lists resources by calling a GET request to the link provided. Supports ETag caching
 
 @param link The link for the collection of `DSAPIResource`
 @param parameters The querystring parameters to be sent with the GET request
 @param queue The queue on which to execute the success, failure and notModified blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page (`DSAPIPage`) of resources returned by the GET request.
 @param notModified A block object to be executed if the web service returns a response of not modified (HTTP status code 304). This is called when the response at this endpoint hasn't changed since the last request (via ETags). This block has no return value and takes one argument: a page (`DSAPIPage`) whose notModified property is set to YES.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
+ (NSURLSessionDataTask *)listResourcesAt:(DSAPILink *)link
                               parameters:(NSDictionary *)parameters
                                    queue:(NSOperationQueue *)queue
                                  success:(DSAPIPageSuccessBlock)success
                              notModified:(DSAPIPageSuccessBlock)notModified
                                  failure:(DSAPIFailureBlock)failure;

/**
 Searches resources by calling a GET to the link provided appended with the string "/search".
 
 @param classLink The class link for the `DSAPIResource` (e.g., [DSAPICase classLink])
 @param parameters The querystring parameters to be sent with the GET request (including 'embed' to embed a resource in the response, and 'page' and 'per_page' for pagination).
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page (`DSAPIPage`) of resources returned by the GET request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
+ (NSURLSessionDataTask *)searchResourcesAt:(DSAPILink *)classLink
                                 parameters:(NSDictionary *)parameters
                                      queue:(NSOperationQueue *)queue
                                    success:(DSAPIPageSuccessBlock)success
                                    failure:(DSAPIFailureBlock)failure;

/**
 Searches resources by calling a GET to the link provided appended with the string "/search". Supports ETag caching
 
 @param classLink The class link for the `DSAPIResource` (e.g., [DSAPICase classLink])
 @param parameters The querystring parameters to be sent with the GET request (including 'embed' to embed a resource in the response, and 'page' and 'per_page' for pagination).
 @param queue The queue on which to execute the success, failure and notModified blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page (`DSAPIPage`) of resources returned by the GET request.
 @param notModified A block object to be executed if the web service returns a response of not modified (HTTP status code 304). This is called when the response at this endpoint hasn't changed since the last request (via ETags). This block has no return value and takes one argument: a page (`DSAPIPage`) whose notModified property is set to YES.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
+ (NSURLSessionDataTask *)searchResourcesAt:(DSAPILink *)classLink
                                 parameters:(NSDictionary *)parameters
                                      queue:(NSOperationQueue *)queue
                                    success:(DSAPIPageSuccessBlock)success
                                notModified:(DSAPIPageSuccessBlock)notModified
                                    failure:(DSAPIFailureBlock)failure;

/**
 Returns a `DSAPILink` to the search endpoint for a given class link
 
 @param classLink The link for the `DSAPIResource` (e.g., [DSAPICase classLink])
 */
+ (DSAPILink *)searchEndpointForClassLink:(DSAPILink *)classLink;

/**
 Creates a resource by calling a POST request to the link provided.
 
 @param resource A `DSAPIResource` instance that wraps a dictionary defining the new resource.
 @param link The link for the `DSAPIResource`
 @param parameters The querystring parameters to be sent with the GET request
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the resource (`DSAPIResource`) created and returned by the POST request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
+ (NSURLSessionDataTask *)createResource:(NSDictionary *)resourceDict
                                  link:(DSAPILink *)link
                                   queue:(NSOperationQueue *)queue
                                 success:(DSAPIResourceSuccessBlock)success
                                 failure:(DSAPIFailureBlock)failure;

/**
 Shows a resource by calling a GET request to the link parameter.
 
 @param linkToResource The link to the resource to show
 @param parameters The querystring parameters to be sent with the GET request
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the resource (`DSAPIResource`) returned by the GET request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
+ (NSURLSessionDataTask *)showResourceAtLink:(DSAPILink *)linkToResource
                                  parameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(DSAPIResourceSuccessBlock)success
                                     failure:(DSAPIFailureBlock)failure;

/**
 Shows a resource by calling a GET request to the resource's "self" link.
 
 @param parameters The querystring parameters to be sent with the GET request
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the resource (`DSAPIResource`) returned by the GET request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
- (NSURLSessionDataTask *)showWithParameters:(NSDictionary *)parameters
                                       queue:(NSOperationQueue *)queue
                                     success:(DSAPIResourceSuccessBlock)success
                                     failure:(DSAPIFailureBlock)failure;

/**
 Updates a resource by calling a PATCH request to the resource's "self" link.
 
 @param dictionary A dictionary defining the updates to the resource.
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the resource (`DSAPIResource`) updated by the PATCH request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
- (NSURLSessionDataTask *)updateWithDictionary:(NSDictionary *)dictionary
                                         queue:(NSOperationQueue *)queue
                                       success:(DSAPIResourceSuccessBlock)success
                                       failure:(DSAPIFailureBlock)failure;

/**
 Lists a child resource by calling a GET request to the resource's link for the given child.
 
 @param relation A string defining the related resource.
 @param parameters The querystring parameters to be sent with the GET request (including 'embed' to embed a resource in the response, and 'page' and 'per_page' for pagination).
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page (`DSAPIPage`) of resources returned by the GET request
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
- (NSURLSessionDataTask *)listResourcesForRelation:(NSString *)relation
                                        parameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                           failure:(DSAPIFailureBlock)failure;

/**
 Lists a child resource by calling a GET request to the resource's link for the given child. Supports ETag caching.
 
 @param relation A string defining the related resource.
 @param parameters The querystring parameters to be sent with the GET request (including 'embed' to embed a resource in the response, and 'page' and 'per_page' for pagination).
 @param queue The queue on which to execute the success, failure and notModified blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes one argument: the page (`DSAPIPage`) of resources returned by the GET request
 @param notModified A block object to be executed if the web service returns a response of not modified (HTTP status code 304). This is called when the response at this endpoint hasn't changed since the last request (via ETags). This block has no return value and takes one argument: a page (`DSAPIPage`) whose notModified property is set to YES.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
- (NSURLSessionDataTask *)listResourcesForRelation:(NSString *)relation
                                        parameters:(NSDictionary *)parameters
                                             queue:(NSOperationQueue *)queue
                                           success:(DSAPIPageSuccessBlock)success
                                       notModified:(DSAPIPageSuccessBlock)notModified
                                           failure:(DSAPIFailureBlock)failure;

/**
 Deletes a resource by calling DELETE to the resource's "self" link.
 
 @param parameters The querystring parameters to be sent with the DELETE request
 @param queue The queue on which to execute the success and failure blocks.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes no arguments.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes two arguments: the `NSHTTPURLResponse` from the server, and an `NSError` describing the network or parsing error that occurred.
 @return A resumed NSURLSessionDataTask. If an error occurred this return value is nil and the failure block is executed.
 */
- (NSURLSessionDataTask *)deleteWithParameters:(NSDictionary *)parameters
                                         queue:(NSOperationQueue *)queue
                                       success:(void (^)(void))success
                                       failure:(DSAPIFailureBlock)failure;

- (NSString *)idFromSelfLink;

@end
