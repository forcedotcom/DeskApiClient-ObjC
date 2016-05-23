//
//  DSAPIOpportunityActivityTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/18/16.
//  Copyright (c) 2016, Salesforce.com, Inc.
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
#import "DSAPITestsOpportunityHelpers.h"

@interface DSAPIOpportunityActivityTests : DSAPITestCase

@property (strong, nonatomic) DSAPIClient *client;
@property (strong, nonatomic) DSAPIOpportunity *opportunity;
@property (strong, nonatomic) DSAPIOpportunityActivity *activity;
@property (strong, nonatomic) DSAPITestsOpportunityHelpers *helpers;

@end

@implementation DSAPIOpportunityActivityTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.f];
    _client = [DSAPITestUtils APIClientBasicAuth];
    
    _helpers = [DSAPITestsOpportunityHelpers new];
    _helpers.apiClient = _client;
    _helpers.testCase = self;
    _helpers.timeout = 10.0f;
    
    // -- Create Opportunity --
    self.opportunity = [self.helpers createOpportunity];
    
    // -- Create Activity --
    self.activity = [self.helpers createActivityWithOpportunity:self.opportunity];
}


- (void)testShowActivity
{
    __block DSAPIOpportunityActivity *returnedActivity = nil;
    
    [self.activity showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunityActivity *activity) {
        returnedActivity = activity;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(returnedActivity).willNot.beNil();
    expect(returnedActivity).will.beKindOf([DSAPIOpportunityActivity class]);
    expect([returnedActivity[@"_links"][@"self"] isEqualToString:self.activity[@"_links"][@"self"]]);
}


- (void)testShowAttachment
{
    DSAPIAttachment *attachment = [self.helpers createAttachmentWithActivity:self.activity];
    
    __block DSAPIAttachment *retunedAttachment = nil;
    
    [attachment showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIAttachment *attachment) {
        retunedAttachment = attachment;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(retunedAttachment).willNot.beNil();
    expect([attachment[@"file_name"] isEqualToString:retunedAttachment[@"file_name"]]);
    expect([attachment[@"content_type"] isEqualToString:retunedAttachment[@"content_type"]]);
    expect(retunedAttachment).will.beKindOf([DSAPIAttachment class]);
}


- (void)testListAttachments
{
    [self.helpers createAttachmentWithActivity:self.activity];
    [self.helpers createAttachmentWithActivity:self.activity];
    
    __block NSArray *attachments = nil;
    
    [self.activity showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIOpportunityActivity *opportunityActivity) {
        [opportunityActivity listAttachmentsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            attachments = page.entries;
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
    expect(attachments).willNot.beNil();
    expect(attachments.count == 2);
    expect(attachments[0]).will.beKindOf([DSAPIAttachment class]);
    expect(attachments[1]).will.beKindOf([DSAPIAttachment class]);
}


- (void)testCreateAttachment
{
    // -- Create Attachment --
    NSDictionary *attachmentDictionary = @{@"file_name": @"1x1.png", @"content_type": @"image/png", @"content": @"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEX/TQBcNTh/AAAACklEQVR4nGNiAAAABgADNjd8qAAAAABJRU5ErkJggg=="};
    
    DSAPIAttachment *attachment = [self.helpers createAttachmentWithActivity:self.activity dictionary:attachmentDictionary];
    
    // -- Assertion --
    expect(attachment).willNot.beNil();
    expect([attachment[@"file_name"] isEqualToString:attachmentDictionary[@"file_name"]]);
    expect([attachment[@"content_type"] isEqualToString:attachmentDictionary[@"content_type"]]);
    expect(attachment).will.beKindOf([DSAPIAttachment class]);
}


- (void)testDeleteAttachment
{
    DSAPIAttachment *attachment = [self.helpers createAttachmentWithActivity:self.activity];

    [attachment deleteWithParameters:nil queue:self.APICallbackQueue success:^{
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
}

@end
