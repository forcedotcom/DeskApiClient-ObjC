//
//  DSAPILabelTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 11/6/13.
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
#import "DSAPIETagCache.h"

@interface DSAPILabelTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPILabelTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testListLabelsReturnsAtLeastOneLabel
{
    __block NSArray *_labels = nil;
    [DSAPILabel listLabelsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _labels = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_labels.count).will.beGreaterThan(0);
    expect(_labels[0]).will.beKindOf([DSAPILabel class]);
}


- (void)testListLabelsCanSetPerPage
{
    __block NSArray *_labels = nil;
    [DSAPILabel listLabelsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _labels = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_labels.count).will.equal(1);
    expect(_labels.count).will.beGreaterThan(0);
}


- (void)testShowLabel
{
    __block DSAPIResource *_label = nil;
    [DSAPILabel listLabelsWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPILabel *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPILabel *label) {
            _label = label;
            [self done];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_label).willNot.beNil();
    expect(_label).will.beKindOf([DSAPILabel class]);
    expect(_label[@"color"]).willNot.beNil();
}


- (void)testCreateLabel
{
    __block DSAPIResource *responseResource = nil;
    NSMutableDictionary *newLabel = [[DSAPITestUtils dictionaryFromJSONFile:@"newLabel"] mutableCopy];
    newLabel[@"name"] = [DSAPITestUtils uuid];
    
    [DSAPILabel createLabel:newLabel queue:self.APICallbackQueue success:^(DSAPIResource *newLabel) {
        responseResource = newLabel;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(responseResource[@"color"]).will.equal(@"orange");
}


- (void)testUpdateLabel
{
    DSAPILabel *labelToUpdate = (DSAPILabel *)[[[DSAPILink alloc] initWithDictionary:@{kHrefKey:@"/api/v2/labels/50", kClassKey:@"label"}] resourceWithSelf];
    __block DSAPIResource *_updatedLabel = nil;
    
    NSDictionary *updateLabelDict = [DSAPITestUtils dictionaryFromJSONFile:@"updateLabel"];
    [labelToUpdate updateWithDictionary:updateLabelDict queue:self.APICallbackQueue success:^(DSAPILabel *updatedLabel) {
        _updatedLabel = updatedLabel;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_updatedLabel[@"color"]).will.equal(@"default");
    expect(_updatedLabel).will.beKindOf([DSAPILabel class]);
}

- (void)testSearchLabels
{
    __block DSAPILabel *label = nil;
    
    [DSAPILabel searchLabelsWithParameters:@{@"name": @"escalated"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        label = page.entries.firstObject;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(label).willNot.beNil();
    expect(label).will.beKindOf([DSAPILabel class]);
    expect([label[@"name"] lowercaseString]).will.contain(@"escalated");
}

- (void)testSearchLabelsWithEtags
{
    __block BOOL hitCache = NO;
    
    [DSAPILabel searchLabelsWithParameters:@{@"name": @"1"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [DSAPILabel searchLabelsWithParameters:@{@"name": @"1"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
            [self done];
        } notModified:^(DSAPIPage *page) {
            hitCache = YES;
            [self done];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(hitCache).to.beTruthy();
}

@end
