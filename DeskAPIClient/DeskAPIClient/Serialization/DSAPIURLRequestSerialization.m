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

#import "DSAPIURLRequestSerialization.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

NSString * const DSAPIURLRequestSerializationErrorDomain = @"com.desk.error.serialization.request";
NSString * const DSAPINetworkingOperationFailingURLRequestErrorKey = @"com.desk.serialization.request.error.response";

typedef NSString * (^DSAPIQueryStringSerializationBlock)(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error);

static NSString * DSAPIBase64EncodedStringFromString(NSString *string) {
    NSData *data = [NSData dataWithBytes:[string UTF8String] length:[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kDSAPIBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kDSAPIBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kDSAPIBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kDSAPIBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kDSAPIBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

static NSString * const kDSAPICharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString * DSAPIPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kDSAPICharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kDSAPICharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kDSAPICharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString * DSAPIPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kDSAPICharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark -

@interface DSAPIQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation DSAPIQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return DSAPIPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", DSAPIPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), DSAPIPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end

#pragma mark -

extern NSArray * DSAPIQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * DSAPIQueryStringPairsFromKeyAndValue(NSString *key, id value);

static NSString * DSAPIQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (DSAPIQueryStringPair *pair in DSAPIQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * DSAPIQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return DSAPIQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * DSAPIQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:DSAPIQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:DSAPIQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:DSAPIQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[DSAPIQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

#pragma mark -

@interface DSAPIHTTPRequestSerializer ()
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;
@property (readwrite, nonatomic, assign) DSAPIHTTPRequestQueryStringSerializationStyle queryStringSerializationStyle;
@property (readwrite, nonatomic, copy) DSAPIQueryStringSerializationBlock queryStringSerialization;
@end

@implementation DSAPIHTTPRequestSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    self.allowsCellularAccess = YES;
    self.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    self.HTTPShouldHandleCookies = YES;
    self.HTTPShouldUsePipelining = NO;
    self.networkServiceType = NSURLNetworkServiceTypeDefault;
    self.timeoutInterval = 60;
    
    self.mutableHTTPRequestHeaders = [NSMutableDictionary dictionary];
    
    // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    NSMutableArray *acceptLanguagesComponents = [NSMutableArray array];
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        float q = 1.0f - (idx * 0.1f);
        [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
        *stop = q <= 0.5f;
    }];
    [self setValue:[acceptLanguagesComponents componentsJoinedByString:@", "] forHTTPHeaderField:@"Accept-Language"];
    
    NSString *userAgent = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
#pragma clang diagnostic pop
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        [self setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    
    // HTTP Method Definitions; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
    self.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
    
    return self;
}

#pragma mark -

- (NSDictionary *)HTTPRequestHeaders {
    return [NSDictionary dictionaryWithDictionary:self.mutableHTTPRequestHeaders];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [self.mutableHTTPRequestHeaders setValue:value forKey:field];
}

- (void)setAuthorizationHeaderFieldWithBearerToken:(NSString *)token {
    [self setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
}

- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password {
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];
    [self setValue:[NSString stringWithFormat:@"Basic %@", DSAPIBase64EncodedStringFromString(basicAuthCredentials)] forHTTPHeaderField:@"Authorization"];
}

- (void)setAuthorizationHeaderFieldWithToken:(NSString *)token {
    [self setValue:[NSString stringWithFormat:@"Token token=\"%@\"", token] forHTTPHeaderField:@"Authorization"];
}

- (void)clearAuthorizationHeader {
    [self.mutableHTTPRequestHeaders removeObjectForKey:@"Authorization"];
}

#pragma mark -

- (void)setQueryStringSerializationWithStyle:(DSAPIHTTPRequestQueryStringSerializationStyle)style {
    self.queryStringSerializationStyle = style;
    self.queryStringSerialization = nil;
}

- (void)setQueryStringSerializationWithBlock:(NSString *(^)(NSURLRequest *, NSDictionary *, NSError *__autoreleasing *))block {
    self.queryStringSerialization = block;
}

#pragma mark -

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
{
    return [self requestWithMethod:method URLString:URLString parameters:parameters error:nil];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSParameterAssert(url);
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;
    mutableRequest.allowsCellularAccess = self.allowsCellularAccess;
    mutableRequest.cachePolicy = self.cachePolicy;
    mutableRequest.HTTPShouldHandleCookies = self.HTTPShouldHandleCookies;
    mutableRequest.HTTPShouldUsePipelining = self.HTTPShouldUsePipelining;
    mutableRequest.networkServiceType = self.networkServiceType;
    mutableRequest.timeoutInterval = self.timeoutInterval;
    
    mutableRequest = [[self requestBySerializingRequest:mutableRequest parameters:parameters error:error] mutableCopy];
    
    return mutableRequest;
}

#pragma mark - DSAPIURLRequestSerialization

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               parameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(request);
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        NSString *query = nil;
        if (self.queryStringSerialization) {
            query = self.queryStringSerialization(request, parameters, error);
        } else {
            switch (self.queryStringSerializationStyle) {
                case DSAPIHTTPRequestQueryStringDefaultStyle:
                    query = DSAPIQueryStringFromParametersWithEncoding(parameters, self.stringEncoding);
                    break;
            }
        }
        
        if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
        } else {
            if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
                NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
                [mutableRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
            }
            [mutableRequest setHTTPBody:[query dataUsingEncoding:self.stringEncoding]];
        }
    }
    
    return mutableRequest;
}

#pragma mark - NSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.mutableHTTPRequestHeaders = [[decoder decodeObjectOfClass:[NSDictionary class] forKey:NSStringFromSelector(@selector(mutableHTTPRequestHeaders))] mutableCopy];
    self.queryStringSerializationStyle = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(queryStringSerializationStyle))] unsignedIntegerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.mutableHTTPRequestHeaders forKey:NSStringFromSelector(@selector(mutableHTTPRequestHeaders))];
    [coder encodeInteger:self.queryStringSerializationStyle forKey:NSStringFromSelector(@selector(queryStringSerializationStyle))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAPIHTTPRequestSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.mutableHTTPRequestHeaders = [self.mutableHTTPRequestHeaders mutableCopyWithZone:zone];
    serializer.queryStringSerializationStyle = self.queryStringSerializationStyle;
    serializer.queryStringSerialization = self.queryStringSerialization;
    
    return serializer;
}

@end

#pragma mark -

@implementation DSAPIJSONRequestSerializer

+ (instancetype)serializer {
    return [self serializerWithWritingOptions:0];
}

+ (instancetype)serializerWithWritingOptions:(NSJSONWritingOptions)writingOptions
{
    DSAPIJSONRequestSerializer *serializer = [[self alloc] init];
    serializer.writingOptions = writingOptions;
    
    return serializer;
}

#pragma mark - DSAPIURLRequestSerialization

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               parameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(request);
    
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        return [super requestBySerializingRequest:request parameters:parameters error:error];
    }
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [mutableRequest setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        }
        
        [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:self.writingOptions error:error]];
    }
    
    return mutableRequest;
}

#pragma mark - NSecureCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.writingOptions = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(writingOptions))] unsignedIntegerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.writingOptions forKey:NSStringFromSelector(@selector(writingOptions))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAPIJSONRequestSerializer *serializer = [super copyWithZone:zone];
    serializer.writingOptions = self.writingOptions;
    
    return serializer;
}

@end

#pragma mark -

@implementation DSAPIPropertyListRequestSerializer

+ (instancetype)serializer {
    return [self serializerWithFormat:NSPropertyListXMLFormat_v1_0 writeOptions:0];
}

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                        writeOptions:(NSPropertyListWriteOptions)writeOptions
{
    DSAPIPropertyListRequestSerializer *serializer = [[self alloc] init];
    serializer.format = format;
    serializer.writeOptions = writeOptions;
    
    return serializer;
}

#pragma mark - DSAPIURLRequestSerializer

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               parameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(request);
    
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        return [super requestBySerializingRequest:request parameters:parameters error:error];
    }
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [mutableRequest setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        }
        
        [mutableRequest setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:self.format options:self.writeOptions error:error]];
    }
    
    return mutableRequest;
}

#pragma mark - NSecureCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.format = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(format))] unsignedIntegerValue];
    self.writeOptions = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(writeOptions))] unsignedIntegerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.format forKey:NSStringFromSelector(@selector(format))];
    [coder encodeObject:@(self.writeOptions) forKey:NSStringFromSelector(@selector(writeOptions))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DSAPIPropertyListRequestSerializer *serializer = [super copyWithZone:zone];
    serializer.format = self.format;
    serializer.writeOptions = self.writeOptions;
    
    return serializer;
}

@end

#pragma mark - OAuth 1

#import <CommonCrypto/CommonHMAC.h>

static inline NSString * DSAPICreateNonce() {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return (NSString *)CFBridgingRelease(string);
}

static inline NSString * DSAPIParametersToEncodedString(NSDictionary *parameters)
{
    // sort the parameters
    NSArray *sortedKeys = [parameters.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // Encode them and coalesce into pairs
    NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithCapacity:parameters.count];
    
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [parameterPairs addObject:[NSString stringWithFormat:@"%@=\"%@\"", DSAPIPercentEscapedQueryStringKeyFromStringWithEncoding(obj, NSUTF8StringEncoding), DSAPIPercentEscapedQueryStringValueFromStringWithEncoding(parameters[obj], NSUTF8StringEncoding)]];
    }];
    
    return [parameterPairs componentsJoinedByString:@", "];
}

static inline NSString * DSAPIParametersToNormalizedEncodedString(NSDictionary *parameters)
{
    // sort the parameters
    NSArray *sortedKeys = [parameters.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    // Encode them and coalesce into pairs
    NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithCapacity:parameters.count];
    
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [parameterPairs addObject:[NSString stringWithFormat:@"%@=%@", DSAPIPercentEscapedQueryStringKeyFromStringWithEncoding(obj, NSUTF8StringEncoding), DSAPIPercentEscapedQueryStringValueFromStringWithEncoding([parameters[obj] description], NSUTF8StringEncoding)]];
    }];
    
    return [parameterPairs componentsJoinedByString:@"&"];
}

static inline BOOL DSAPIQueryStringValueIsTrue(NSString *value) {
    return value && [[value lowercaseString] hasPrefix:@"t"];
}

NSDictionary *DSAPIParametersFromQueryString(NSString *queryString)
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value) {
                parameters[[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
    }
    
    return parameters;
}

static inline NSString * DSAPIHMACSHA1Signature(NSURLRequest *request, NSDictionary *additionalParameters, NSString *consumerSecret, NSString *tokenSecret) {
    NSString *secret = tokenSecret ? tokenSecret : @"";
    NSString *secretString = [NSString stringWithFormat:@"%@&%@", DSAPIPercentEscapedQueryStringValueFromStringWithEncoding(consumerSecret, NSUTF8StringEncoding), DSAPIPercentEscapedQueryStringValueFromStringWithEncoding(secret, NSUTF8StringEncoding)];
    NSData *secretStringData = [secretString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *allParameters = [DSAPIParametersFromQueryString(request.URL.query) mutableCopy];
    [allParameters addEntriesFromDictionary:additionalParameters];
    
    NSString *parameterString = DSAPIPercentEscapedQueryStringValueFromStringWithEncoding(DSAPIParametersToNormalizedEncodedString(allParameters), NSUTF8StringEncoding);
    
    NSString *requestString = [NSString stringWithFormat:@"%@&%@&%@", [request HTTPMethod], DSAPIPercentEscapedQueryStringValueFromStringWithEncoding([[[request URL] absoluteString] componentsSeparatedByString:@"?"][0], NSUTF8StringEncoding), parameterString];
    
    NSData *requestStringData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, [secretStringData bytes], [secretStringData length]);
    CCHmacUpdate(&cx, [requestStringData bytes], [requestStringData length]);
    CCHmacFinal(&cx, digest);
    
    return [[NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH]base64EncodedStringWithOptions:0];
}

@interface DSAPIOAuthRequestSerializer()

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;

- (NSDictionary *)OAuthParameters;
- (NSURLRequest *)requestWithAuthorizationHeaderForRequest:(NSURLRequest *)request
                                                parameters:(NSDictionary *)parameters
                                                     error:(NSError *__autoreleasing *)error;
@end

@implementation DSAPIOAuthRequestSerializer

- (NSDictionary *)OAuthParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"oauth_version"] = @"1.0";
    parameters[@"oauth_signature_method"] = @"HMAC-SHA1";
    parameters[@"oauth_consumer_key"] = self.consumerKey;
    parameters[@"oauth_timestamp"] = [@(floor([[NSDate date] timeIntervalSince1970])) stringValue];
    parameters[@"oauth_nonce"] = DSAPICreateNonce();
    return parameters;
}

- (void)setAuthorizationHeaderFieldWithConsumerKey:(NSString *)consumerKey
                                    consumerSecret:(NSString *)consumerSecret
{
    NSParameterAssert(consumerKey);
    NSParameterAssert(consumerSecret);
    
    self.consumerKey = consumerKey;
    self.consumerSecret = consumerSecret;
}

- (NSURLRequest *)requestWithAuthorizationHeaderForRequest:(NSURLRequest *)request
                                                parameters:(NSDictionary *)parameters
                                                     error:(NSError *__autoreleasing *)error
{
    // merge OAuth parameters with existing parameters
    NSMutableDictionary *mutableParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    NSMutableDictionary *mutableAuthorizationParameters = [NSMutableDictionary dictionary];
    
    if (self.consumerKey && self.consumerSecret) {
        [mutableAuthorizationParameters addEntriesFromDictionary:[self OAuthParameters]];
        if (self.accessToken) {
            mutableAuthorizationParameters[@"oauth_token"] = self.accessToken.key;
            if (self.accessToken.verifier) {
                mutableAuthorizationParameters[@"oauth_verifier"] = self.accessToken.verifier;
            }
        }
    }
    
    [mutableParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [key hasPrefix:@"oauth_"]) {
            mutableAuthorizationParameters[key] = obj;
        }
    }];
    
    [mutableParameters addEntriesFromDictionary:mutableAuthorizationParameters];
    
    // Sign the authorization header
    
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        // HTTP Method encodes parameters in URI, so we must include them in the OAuth Signature
        mutableAuthorizationParameters[@"oauth_signature"] = DSAPIHMACSHA1Signature(request, mutableParameters, self.consumerSecret, self.accessToken ? self.accessToken.secret : nil);
    } else {
        // HTTP Method does not encode parameters in URI, so we must NOT include them in the OAuth Signature
        mutableAuthorizationParameters[@"oauth_signature"] = DSAPIHMACSHA1Signature(request, mutableAuthorizationParameters, self.consumerSecret, self.accessToken ? self.accessToken.secret : nil);
    }
    
    // Remove auth parameters from request parameters
    [mutableParameters removeObjectsForKeys:mutableAuthorizationParameters.allKeys];
    
    // Sort all parameters in Auth Header
    NSString *headerString = DSAPIParametersToEncodedString(mutableAuthorizationParameters);
    
    NSString *header = [NSString stringWithFormat:@"OAuth %@", headerString];
    [self setValue:header forHTTPHeaderField:@"Authorization"];
    
    return [super requestBySerializingRequest:request parameters:mutableParameters error:error];
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               parameters:(NSDictionary *)parameters
                                        error:(NSError *__autoreleasing *)error
{
    return [self requestWithAuthorizationHeaderForRequest:request parameters:parameters error:error];
}

@end

#pragma mark - OAuth1 Token

@interface DSAPIOAuth1Token()

@property (readwrite, nonatomic, copy) NSString *key;
@property (readwrite, nonatomic, copy) NSString *secret;
@property (readwrite, nonatomic, copy) NSString *session;
@property (readwrite, nonatomic, strong) NSDate *expiration;
@property (readwrite, nonatomic, assign, getter = canBeRenewed) BOOL renewable;
@end

@implementation DSAPIOAuth1Token

- (id)initWithQueryString:(NSString *)queryString {
    if (!queryString || [queryString length] == 0) {
        return nil;
    }
    
    NSDictionary *attributes = DSAPIParametersFromQueryString(queryString);
    
    if ([attributes count] == 0) {
        return nil;
    }
    
    NSString *key = attributes[@"oauth_token"];
    NSString *secret = attributes[@"oauth_token_secret"];
    NSString *session = attributes[@"oauth_session_handle"];
    
    NSDate *expiration = nil;
    if (attributes[@"oauth_token_duration"]) {
        expiration = [NSDate dateWithTimeIntervalSinceNow:[attributes[@"oauth_token_duration"] doubleValue]];
    }
    
    BOOL canBeRenewed = NO;
    if (attributes[@"oauth_token_renewable"]) {
        canBeRenewed = DSAPIQueryStringValueIsTrue(attributes[@"oauth_token_renewable"]);
    }
    
    self = [self initWithKey:key secret:secret session:session expiration:expiration renewable:canBeRenewed];
    if (!self) {
        return nil;
    }
    
    NSMutableDictionary *mutableUserInfo = [attributes mutableCopy];
    [mutableUserInfo removeObjectsForKeys:@[@"oauth_token", @"oauth_token_secret", @"oauth_session_handle", @"oauth_token_duration", @"oauth_token_renewable"]];
    
    if ([mutableUserInfo count] > 0) {
        self.userInfo = [NSDictionary dictionaryWithDictionary:mutableUserInfo];
    }
    
    return self;
}

- (id)initWithKey:(NSString *)key
           secret:(NSString *)secret
          session:(NSString *)session
       expiration:(NSDate *)expiration
        renewable:(BOOL)canBeRenewed
{
    NSParameterAssert(key);
    NSParameterAssert(secret);
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.key = key;
    self.secret = secret;
    self.session = session;
    self.expiration = expiration;
    self.renewable = canBeRenewed;
    
    return self;
}

- (BOOL)isExpired{
    return [self.expiration compare:[NSDate date]] == NSOrderedDescending;
}

@end
