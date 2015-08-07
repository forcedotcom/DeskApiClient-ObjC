//
//  DSAPIMailboxTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 6/23/14.
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

@interface DSAPIMailboxTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIMailboxTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testListOutboundMailbox
{
    __block NSArray *_outboundMailboxes = nil;
    [DSAPIMailbox listMailboxesOfType:DSAPIMailboxTypeOutbound
                           parameters:nil
                                queue:self.APICallbackQueue
                              success:^(DSAPIPage *page) {
                                  _outboundMailboxes = page.entries;
                                  [self done];
                              } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                  EXPFail(self, __LINE__, __FILE__, [error description]);
                              }];
    
    expect([self isDone]).will.beTruthy();
    expect(_outboundMailboxes.count).will.beGreaterThan(0);
    expect(_outboundMailboxes[0]).will.beKindOf([DSAPIMailbox class]);
}

- (void)testListInboundMailbox
{
    __block NSArray *_inboundMailboxes = nil;
    [DSAPIMailbox listMailboxesOfType:DSAPIMailboxTypeInbound
                           parameters:nil
                                queue:self.APICallbackQueue
                              success:^(DSAPIPage *page) {
                                  _inboundMailboxes = page.entries;
                                  [self done];
                              } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                  EXPFail(self, __LINE__, __FILE__, [error description]);
                              }];
    
    expect([self isDone]).will.beTruthy();
    expect(_inboundMailboxes.count).will.beGreaterThan(0);
    expect(_inboundMailboxes[0]).will.beKindOf([DSAPIMailbox class]);
}

- (void)testShowOutboundMailbox
{
    __block DSAPIMailbox *_mailbox = nil;
    [DSAPIMailbox listMailboxesOfType:DSAPIMailboxTypeOutbound parameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIMailbox *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIMailbox *mailbox) {
            _mailbox = mailbox;
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
    expect(_mailbox).willNot.beNil();
    expect(_mailbox).will.beKindOf([DSAPIMailbox class]);
    expect(_mailbox[@"from_name"]).willNot.beNil();
    expect(_mailbox[@"from_email"]).willNot.beNil();
}

- (void)testShowInboundMailbox
{
    __block DSAPIMailbox *_mailbox = nil;
    [DSAPIMailbox listMailboxesOfType:DSAPIMailboxTypeInbound parameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIMailbox *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIMailbox *mailbox) {
            _mailbox = mailbox;
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
    expect(_mailbox).willNot.beNil();
    expect(_mailbox).will.beKindOf([DSAPIMailbox class]);
    expect(_mailbox[@"name"]).willNot.beNil();
    expect(_mailbox[@"email"]).willNot.beNil();
}

@end
