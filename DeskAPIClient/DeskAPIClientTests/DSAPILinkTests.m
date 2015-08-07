//
//  DSAPILinkTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/19/13.
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

#import "DSAPITestCase.h"

@interface DSAPILinkTests : DSAPITestCase

@property (nonatomic, strong) DSAPILink *link;
@property (nonatomic, strong) NSDictionary *linkDict;

@end

@implementation DSAPILinkTests

- (void)setUp
{
    [super setUp];
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"case6" ofType:@"json"];
    NSData *response = [NSData dataWithContentsOfFile:filePath];
    _linkDict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil][kLinksKey][kSelfKey];
    _link = [[DSAPILink alloc] initWithDictionary:_linkDict];
}
- (void)testInitWithBaseURL
{
    DSAPILink *link = [[DSAPILink alloc] initWithDictionary:_linkDict baseURL:[NSURL URLWithString:@"https://www.google.com"]];
    
    expect([link.URL absoluteString]).to.contain(@"https://www.google.com");
}

- (void)testThatThereIsAnHref
{
    expect(_link.href).to.beKindOf([NSString class]);
}

- (void)testThatThereIsAClassName
{
    expect(_link.className).to.beKindOf([NSString class]);
}

- (void)testURL
{
    expect(_link.URL).to.beKindOf([NSURL class]);
    expect([_link.URL absoluteString]).to.contain(@"/api/v2/cases/6");
}

- (void)testParameters
{
    __block DSAPILink *nextLink = nil;
    [DSAPITestUtils APIClientBasicAuth];
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        nextLink = page.links[@"next"][0];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect([nextLink.parameters[@"page"] integerValue]).will.equal(2);
    expect([nextLink.parameters[@"per_page"] integerValue]).will.equal(50);
}

- (void)testDictionary
{
    expect(_link.dictionary).to.beKindOf([NSDictionary class]);
    expect(_link.dictionary[kHrefKey]).toNot.beNil();
}

- (void)testResourceFromLink
{
    DSAPILink *linkToSelf = [[DSAPILink alloc] initWithDictionary:@{kHrefKey:@"/api/v2/cases/41", kClassKey:@"case"}];
    DSAPIResource *resource = [linkToSelf resourceWithSelf];
    
    expect(resource).to.beKindOf([DSAPICase class]);
    expect(resource.linkToSelf.URL).to.equal(linkToSelf.URL);
}

- (void)testLinkWithHrefAndClass
{
    DSAPILink *link = [DSAPILink linkWithHref:@"/api/v2/filters/185" className:@"filter"];
    expect(link.href).to.equal(@"/api/v2/filters/185");
    expect(link.className).to.equal(@"filter");
}

@end
