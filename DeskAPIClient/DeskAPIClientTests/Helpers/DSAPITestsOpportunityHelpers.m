//
//  DSAPITestsOpportunityHelpers.m
//  DeskAPIClient
//
//  Created by Desk.com on 5/19/16.
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

#import "DSAPITestsOpportunityHelpers.h"
#import "DSAPITestCase.h"
#import "NSDate+DSC.h"

@implementation DSAPITestsOpportunityHelpers

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeout = 10.0f;
    }
    return self;
}

- (DSAPIOpportunity *)createOpportunity
{
    XCTestExpectation *expectation = [self.testCase expectationWithDescription:@"Create Opportunity"];
    
    __block DSAPIOpportunity *_opportunity = nil;
    NSDictionary *opportunityDictionary = @{@"name": @"Attachment Test", @"description": @"Sample description", @"amount": @"3,002.00", @"close_date": [[NSDate distantFuture] stringWithISO8601Format]};
    
    [DSAPIOpportunity createOpportunity:opportunityDictionary client:self.apiClient queue:self.testCase.APICallbackQueue success:^(DSAPIOpportunity *opportunity) {
        _opportunity = opportunity;
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self.testCase waitForExpectationsWithTimeout:self.timeout handler:nil];
    
    return _opportunity;
}


- (void)deleteOpportunity:(DSAPIOpportunity *)opportunity
{
    XCTestExpectation *expectation = [self.testCase expectationWithDescription:@"Delete Opportunity"];
    
    [opportunity deleteWithParameters:nil queue:self.testCase.APICallbackQueue success:^{
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self.testCase waitForExpectationsWithTimeout:self.timeout handler:nil];
}


- (DSAPIOpportunity *)refreshOpportunity:(DSAPIOpportunity *)opportunity
{
    XCTestExpectation *expectation = [self.testCase expectationWithDescription:@"Show Opportunity"];
    
    __block DSAPIOpportunity *_opportunity = nil;
    
    [opportunity showWithParameters:nil queue:self.testCase.APICallbackQueue success:^(DSAPIOpportunity *opportunity) {
        _opportunity = opportunity;
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self.testCase waitForExpectationsWithTimeout:self.timeout handler:nil];
    
    return _opportunity;
}


- (DSAPIOpportunityActivity *)createActivityWithOpportunity:(DSAPIOpportunity *)opportunity
{
    XCTestExpectation *expectation = [self.testCase expectationWithDescription:@"Create Activity"];
    
    __block DSAPIOpportunityActivity *_activity = nil;
    NSDictionary *activityDictionary = @{@"type": @"note", @"message": @"This is an important note"};
    
    [opportunity createActivity:activityDictionary queue:self.testCase.APICallbackQueue success:^(DSAPIOpportunityActivity *activity) {
        _activity = activity;
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self.testCase waitForExpectationsWithTimeout:self.timeout handler:nil];
    
    return _activity;
}


- (DSAPIAttachment *)createAttachmentWithActivity:(DSAPIOpportunityActivity *)activity
{
    NSDictionary *dictionary = @{@"file_name": @"1x1.png", @"content_type": @"image/png", @"content": @"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEX/TQBcNTh/AAAACklEQVR4nGNiAAAABgADNjd8qAAAAABJRU5ErkJggg=="};
    return [self createAttachmentWithActivity:activity dictionary:dictionary];
}


- (DSAPIAttachment *)createAttachmentWithActivity:(DSAPIOpportunityActivity *)activity dictionary: (NSDictionary *)dictionary
{
    XCTestExpectation *expectation = [self.testCase expectationWithDescription:@"Create Attachment"];
    __block DSAPIAttachment *_attachment = nil;
    
    [activity createAttachment:dictionary queue:self.testCase.APICallbackQueue success:^(DSAPIAttachment *attachment) {
        _attachment = attachment;
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self.testCase waitForExpectationsWithTimeout:self.timeout handler:nil];
    
    return _attachment;
}

@end
