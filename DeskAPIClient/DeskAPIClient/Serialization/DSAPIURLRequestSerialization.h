//
//  DSAPIURLRequestSerialization.h
//  DeskAPIClient
//
//  Created by Desk.com on 1/12/15.
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
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

/**
 The `DSAPIURLRequestSerialization` protocol is adopted by an object that encodes parameters for a specified HTTP requests. Request serializers may encode parameters as query strings, HTTP bodies, setting the appropriate HTTP header fields as necessary.
 
 For example, a JSON request serializer may set the HTTP body of the request to a JSON representation, and set the `Content-Type` HTTP header field value to `application/json`.
 */
@protocol DSAPIURLRequestSerialization <NSObject, NSSecureCoding, NSCopying>

/**
 Returns a request with the specified parameters encoded into a copy of the original request.
 
 @param request The original request.
 @param parameters The parameters to be encoded.
 @param error The error that occurred while attempting to encode the request parameters.
 
 @return A serialized request.
 */
- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               parameters:(id)parameters
                                        error:(NSError * __autoreleasing *)error;

@end

#pragma mark -

/**
 
 */
typedef NS_ENUM(NSUInteger, DSAPIHTTPRequestQueryStringSerializationStyle) {
    DSAPIHTTPRequestQueryStringDefaultStyle = 0,
};

@protocol DSAPIMultipartFormData;

/**
 `DSAPIHTTPRequestSerializer` conforms to the `DSAPIURLRequestSerialization` & `DSAPIURLResponseSerialization` protocols, offering a concrete base implementation of query string / URL form-encoded parameter serialization and default request headers, as well as response status code and content type validation.
 
 Any request or response serializer dealing with HTTP is encouraged to subclass `DSAPIHTTPRequestSerializer` in order to ensure consistent default behavior.
 */
@interface DSAPIHTTPRequestSerializer : NSObject <DSAPIURLRequestSerialization>

/**
 The string encoding used to serialize parameters. `NSUTF8StringEncoding` by default.
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/**
 Whether created requests can use the device’s cellular radio (if present). `YES` by default.
 
 @see NSMutableURLRequest -setAllowsCellularAccess:
 */
@property (nonatomic, assign) BOOL allowsCellularAccess;

/**
 The cache policy of created requests. `NSURLRequestUseProtocolCachePolicy` by default.
 
 @see NSMutableURLRequest -setCachePolicy:
 */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/**
 Whether created requests should use the default cookie handling. `YES` by default.
 
 @see NSMutableURLRequest -setHTTPShouldHandleCookies:
 */
@property (nonatomic, assign) BOOL HTTPShouldHandleCookies;

/**
 Whether created requests can continue transmitting data before receiving a response from an earlier transmission. `NO` by default
 
 @see NSMutableURLRequest -setHTTPShouldUsePipelining:
 */
@property (nonatomic, assign) BOOL HTTPShouldUsePipelining;

/**
 The network service type for created requests. `NSURLNetworkServiceTypeDefault` by default.
 
 @see NSMutableURLRequest -setNetworkServiceType:
 */
@property (nonatomic, assign) NSURLRequestNetworkServiceType networkServiceType;

/**
 The timeout interval, in seconds, for created requests. The default timeout interval is 60 seconds.
 
 @see NSMutableURLRequest -setTimeoutInterval:
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

///---------------------------------------
/// @name Configuring HTTP Request Headers
///---------------------------------------

/**
 Default HTTP header field values to be applied to serialized requests.
 */
@property (readonly, nonatomic, strong) NSDictionary *HTTPRequestHeaders;

/**
 Creates and returns a serializer with default configuration.
 */
+ (instancetype)serializer;

/**
 Sets the value for the HTTP headers set in request objects made by the HTTP client. If `nil`, removes the existing value for that header.
 
 @param field The HTTP header to set a default value for
 @param value The value set as default for the specified header, or `nil`
 */
- (void)setValue:(NSString *)value
forHTTPHeaderField:(NSString *)field;

/** 
 Sets the "Authorization" HTTP header sent in request objects made by the HTTP client to a Bearer token value. This overwrites any existing value for this header.
 @param token The bearer token
 */
- (void)setAuthorizationHeaderFieldWithBearerToken:(NSString *)token;

/**
 Sets the "Authorization" HTTP header sent in request objects made by the HTTP client to a basic authentication value with Base64-encoded username and password. This overwrites any existing value for this header.
 
 @param username The HTTP basic auth username
 @param password The HTTP basic auth password
 */
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username
                                       password:(NSString *)password;

/**
 @deprecated This method has been deprecated. Use -setValue:forHTTPHeaderField: instead.
 */
- (void)setAuthorizationHeaderFieldWithToken:(NSString *)token DEPRECATED_ATTRIBUTE;


/**
 Clears any existing value for the "Authorization" HTTP header.
 */
- (void)clearAuthorizationHeader;

///-------------------------------------------------------
/// @name Configuring Query String Parameter Serialization
///-------------------------------------------------------

/**
 HTTP methods for which serialized requests will encode parameters as a query string. `GET`, `HEAD`, and `DELETE` by default.
 */
@property (nonatomic, strong) NSSet *HTTPMethodsEncodingParametersInURI;

/**
 Set the method of query string serialization according to one of the pre-defined styles.
 
 @param style The serialization style.
 
 @see DSAPIHTTPRequestQueryStringSerializationStyle
 */
- (void)setQueryStringSerializationWithStyle:(DSAPIHTTPRequestQueryStringSerializationStyle)style;

/**
 Set the a custom method of query string serialization according to the specified block.
 
 @param block A block that defines a process of encoding parameters into a query string. This block returns the query string and takes three arguments: the request, the parameters to encode, and the error that occurred when attempting to encode parameters for the given request.
 */
- (void)setQueryStringSerializationWithBlock:(NSString * (^)(NSURLRequest *request, NSDictionary *parameters, NSError * __autoreleasing *error))block;

///-------------------------------
/// @name Creating Request Objects
///-------------------------------

/**
 @deprecated This method has been deprecated. Use -requestWithMethod:URLString:parameters:error: instead.
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters DEPRECATED_ATTRIBUTE;

/**
 Creates an `NSMutableURLRequest` object with the specified HTTP method and URL string.
 
 If the HTTP method is `GET`, `HEAD`, or `DELETE`, the parameters will be used to construct a url-encoded query string that is appended to the request's URL. Otherwise, the parameters will be encoded according to the value of the `parameterEncoding` property, and set as the request body.
 
 @param method The HTTP method for the request, such as `GET`, `POST`, `PUT`, or `DELETE`. This parameter must not be `nil`.
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be either set as a query string for `GET` requests, or the request HTTP body.
 @param error The error that occured while constructing the request.
 
 @return An `NSMutableURLRequest` object.
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError * __autoreleasing *)error;
@end

#pragma mark -

@interface DSAPIJSONRequestSerializer : DSAPIHTTPRequestSerializer

/**
 Options for writing the request JSON data from Foundation objects. For possible values, see the `NSJSONSerialization` documentation section "NSJSONWritingOptions". `0` by default.
 */
@property (nonatomic, assign) NSJSONWritingOptions writingOptions;

/**
 Creates and returns a JSON serializer with specified reading and writing options.
 
 @param writingOptions The specified JSON writing options.
 */
+ (instancetype)serializerWithWritingOptions:(NSJSONWritingOptions)writingOptions;

@end

@interface DSAPIPropertyListRequestSerializer : DSAPIHTTPRequestSerializer

/**
 The property list format. Possible values are described in "NSPropertyListFormat".
 */
@property (nonatomic, assign) NSPropertyListFormat format;

/**
 @warning The `writeOptions` property is currently unused.
 */
@property (nonatomic, assign) NSPropertyListWriteOptions writeOptions;

/**
 Creates and returns a property list serializer with a specified format, read options, and write options.
 
 @param format The property list format.
 @param writeOptions The property list write options.
 
 @warning The `writeOptions` property is currently unused.
 */
+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                        writeOptions:(NSPropertyListWriteOptions)writeOptions;

@end

///----------------
/// @name Constants
///----------------

/**
 ## Error Domains
 
 The following error domain is predefined.
 
 - `NSString * const DSAPIURLRequestSerializationErrorDomain`
 
 ### Constants
 
 `DSAPIURLRequestSerializationErrorDomain`
 DSAPIURLRequestSerializer errors. Error codes for `DSAPIURLRequestSerializationErrorDomain` correspond to codes in `NSURLErrorDomain`.
 */
extern NSString * const DSAPIURLRequestSerializationErrorDomain;

/**
 ## User info dictionary keys
 
 These keys may exist in the user info dictionary, in addition to those defined for NSError.
 
 - `NSString * const DSAPINetworkingOperationFailingURLResponseErrorKey`
 
 ### Constants
 
 `DSAPINetworkingOperationFailingURLRequestErrorKey`
 The corresponding value is an `NSURLRequest` containing the request of the operation associated with an error. This key is only present in the `DSAPIURLRequestSerializationErrorDomain`.
 */
extern NSString * const DSAPINetworkingOperationFailingURLRequestErrorKey;

///-----------------------------------
/// @name OAuth Request Serializer
///-----------------------------------


extern NSDictionary * DSAPIParametersFromQueryString(NSString *queryString);

@class DSAPIOAuth1Token;

@interface DSAPIOAuthRequestSerializer : DSAPIJSONRequestSerializer

@property (nonatomic, strong) DSAPIOAuth1Token *accessToken;

/**
 Set the OAuth Authorization Header, given a consumer key and secret
 
 @param consumerKey The key for the OAuth consumer
 @param consumerSecret The secret for the OAuth consumer
 @param callbackURL The callback URL for the OAuth consumer
 */

- (void)setAuthorizationHeaderFieldWithConsumerKey:(NSString *)consumerKey
                                    consumerSecret:(NSString *)consumerSecret;
@end


///-----------------------------------
/// @name OAuth 1 Token
///-----------------------------------

@interface DSAPIOAuth1Token : NSObject

@property (readonly, nonatomic, copy) NSString *key;
@property (readonly, nonatomic, copy) NSString *secret;
@property (readonly, nonatomic, copy) NSString *session;
@property (nonatomic, copy) NSString *verifier;
@property (readonly, nonatomic, assign, getter = canBeRenewed) BOOL renewable;
@property (readonly, nonatomic, assign, getter = isExpired) BOOL expired;
@property (nonatomic, strong) NSDictionary *userInfo;

- (id)initWithQueryString:(NSString *)queryString;

- (id)initWithKey:(NSString *)key
           secret:(NSString *)secret
          session:(NSString *)session
       expiration:(NSDate *)expiration
        renewable:(BOOL)canBeRenewed;

@end
