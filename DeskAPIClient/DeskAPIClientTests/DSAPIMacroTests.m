//
//  DSAPIMacroTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 1/27/14.
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

@interface DSAPIMacroTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;

@end

@implementation DSAPIMacroTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


- (void)testListMacrosReturnsAtLeastOneMacro
{
    __block NSArray *_macros = nil;
    [DSAPIMacro listMacrosWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _macros = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_macros.count).will.beGreaterThan(0);
    expect(_macros[0]).will.beKindOf([DSAPIMacro class]);
}


- (void)testListMacrosCanSetPerPage
{
    __block NSArray *_macros = nil;
    [DSAPIMacro listMacrosWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _macros = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_macros.count).will.equal(1);
}


- (void)testListMacrosCanRetrieveNextPage
{
    __block DSAPILink *previousLink = nil;
    [DSAPIMacro listMacrosWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPIGroup listGroupsWithParameters:nextLink.parameters queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
            previousLink = nextPage.links[@"previous"][0];
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
    expect([previousLink.parameters[@"page"] integerValue]).will.equal(1);
    expect([previousLink.parameters[@"per_page"] integerValue]).will.equal(1);
}


- (void)testShowMacro
{
    __block DSAPIMacro *_macro = nil;
    [DSAPIMacro listMacrosWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIMacro *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIMacro *macro) {
            _macro = macro;
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
    expect(_macro).willNot.beNil();
    expect(_macro).will.beKindOf([DSAPIMacro class]);
    expect(_macro[@"name"]).willNot.beNil();
}


- (void)testCreateMacro
{
    __block DSAPIMacro *responseMacro = nil;
    NSMutableDictionary *newMacro = [[DSAPITestUtils dictionaryFromJSONFile:@"newMacro"] mutableCopy];
    newMacro[@"name"] = [DSAPITestUtils uuid];
    
    [DSAPIMacro createMacro:newMacro queue:self.APICallbackQueue success:^(DSAPIMacro *newMacro) {
        responseMacro = newMacro;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(responseMacro[@"name"]).will.equal(newMacro[@"name"]);
}


- (void)testUpdateMacro
{
    __block DSAPIResource *_updatedMacro = nil;
    
    NSMutableDictionary *newMacroDictionary = [[DSAPITestUtils dictionaryFromJSONFile:@"newMacro"] mutableCopy];
    newMacroDictionary[@"name"] = [DSAPITestUtils uuid];
    
    [DSAPIMacro createMacro:newMacroDictionary queue:self.APICallbackQueue success:^(DSAPIMacro *newMacro) {
        [newMacro updateWithDictionary:@{@"name":@"Test Update"} queue:self.APICallbackQueue success:^(DSAPIMacro *updatedMacro) {
            _updatedMacro = updatedMacro;
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
    expect(_updatedMacro[@"name"]).will.equal(@"Test Update");
    expect(_updatedMacro).will.beKindOf([DSAPIMacro class]);
}


- (void)testDeleteMacro
{
    NSMutableDictionary *newMacro = [[DSAPITestUtils dictionaryFromJSONFile:@"newMacro"] mutableCopy];
    newMacro[@"name"] = [DSAPITestUtils uuid];
    
    [DSAPIMacro createMacro:newMacro queue:self.APICallbackQueue success:^(DSAPIMacro *newMacro) {
        [newMacro deleteWithParameters:nil queue:self.APICallbackQueue success:^(void) {
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
}


- (void)testListMacroActions
{
    __block DSAPIMacroAction *macroAction = nil;
    
    [DSAPIMacro listMacrosWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIMacro *)page.entries[0] listActionsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            macroAction = page.entries[0];
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
    expect(macroAction).will.beKindOf([DSAPIMacroAction class]);
}


- (void)testShowMacroAction
{
    __block DSAPIMacroAction *_macroAction = nil;
    
    [DSAPIMacro listMacrosWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIMacro *)page.entries[0] listActionsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            [(DSAPIMacroAction *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIMacroAction *macroAction) {
                _macroAction = macroAction;
                [self done];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
                [self done];
            }];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_macroAction).willNot.beNil();
    expect(_macroAction).will.beKindOf([DSAPIMacroAction class]);
    expect(_macroAction[@"value"]).willNot.beNil();
}

@end
