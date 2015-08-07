//
//  DSAPICaseTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 9/24/13.
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

@interface DSAPICaseTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPICaseTests


- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:10.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}


#pragma mark - Case Tests

- (void)testListCasesReturnsAtLeastOneCase
{
    __block NSArray *_cases = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _cases = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_cases.count).will.beGreaterThan(0);
    expect(_cases[0]).will.beKindOf([DSAPICase class]);
    expect(_cases[0]).will.beKindOf([DSAPICase class]);
}


- (void)testListCasesEmbedsCustomer
{
    __block DSAPIResource *customer = nil;
    [DSAPICase listCasesWithParameters:@{@"embed": @"customer"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        customer = [page.entries[0] resourceForRelation:@"customer"];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(customer).willNot.beNil();
    expect(customer).will.beKindOf([DSAPICustomer class]);
}


- (void)testListCasesEmbedsMessage
{
    __block DSAPIResource *message = nil;
    [DSAPICase listCasesWithParameters:@{@"embed": @"message"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        message = [page.entries[0] resourceForRelation:@"message"];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(message).willNot.beNil();
    expect(message).will.beKindOf([DSAPIInteraction class]);
}


- (void)testListCasesCanSetPerPage
{
    __block NSArray *_cases = nil;
    [DSAPICase listCasesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        _cases = page.entries;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(_cases.count).will.equal(1);
}


- (void)testListCasesCanRetrieveNextPage
{
    __block DSAPILink *nextNextLink = nil;
    [DSAPICase listCasesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPILink *nextLink = page.links[@"next"][0];
        [DSAPICase listCasesWithParameters:nextLink.parameters queue:self.APICallbackQueue success:^(DSAPIPage *nextPage) {
            nextNextLink = nextPage.links[@"next"][0];
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
    expect([nextNextLink.parameters[@"page"] integerValue]).will.equal(3);
    expect([nextNextLink.parameters[@"per_page"] integerValue]).will.equal(1);
}


- (void)testShowCase
{
    __block DSAPIResource *aCase = nil;
    [DSAPICase listCasesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICase *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICase *theCase) {
            aCase = theCase;
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
    expect(aCase).willNot.beNil();
    expect(aCase).will.beKindOf([DSAPICase class]);
}

- (void)testShowCaseById
{
    __block DSAPIResource *aCase = nil;
    [DSAPICase showById:@6 parameters:nil queue:self.APICallbackQueue success:^(DSAPICase *theCase) {
        aCase = theCase;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(aCase).willNot.beNil();
    expect(aCase).will.beKindOf([DSAPICase class]);
    expect([aCase[@"subject"] length]).will.beGreaterThan(0);
}


- (void)testSearchCasesBySubject
{
    __block DSAPIResource *randomCase = nil;
    __block NSString *subject = nil;
    [DSAPICase searchCasesWithParameters:@{@"subject": @"getting"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSUInteger randomIndex = arc4random() % page.entries.count;
        randomCase = page.entries[randomIndex];
        subject = [randomCase objectForKeyedSubscript:@"subject"];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(randomCase).willNot.beNil();
    expect(randomCase).will.beKindOf([DSAPICase class]);
    expect([subject lowercaseString]).will.contain(@"getting");
}


- (void)testSearchCasesByCustomerName
{
    __block NSString *randomCaseCustomerName = nil;
    __block DSAPICustomer *customer = nil;
    [DSAPICase searchCasesWithParameters:@{@"name": @"amzad", @"embed": @"customer"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSUInteger randomIndex = arc4random() % page.entries.count;
        customer = (DSAPICustomer *)[page.entries[randomIndex] resourceForRelation:@"customer"];
        randomCaseCustomerName = [customer objectForKeyedSubscript:@"first_name"];
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(customer).willNot.beNil();
    expect(customer).will.beKindOf([DSAPICustomer class]);
    expect([randomCaseCustomerName lowercaseString]).will.equal(@"amzad");
}

- (void)testSearchCasesWithEtags
{
// This test is currently broken to due Weak Etags. Should work again when this is fixed:
// https://desk.atlassian.net/browse/AA-30112
//    __block BOOL hitCache = NO;
//    
//    [DSAPICase searchCasesWithParameters:@{@"subject": @"getting"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
//        [DSAPICase searchCasesWithParameters:@{@"subject": @"getting"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
//            EXPFail(self, __LINE__, __FILE__, @"did not receive 304 response");
//            [self done];
//        } notModified:^(DSAPIPage *page) {
//            hitCache = YES;
//            [self done];
//        } failure:^(NSHTTPURLResponse *response, NSError *error) {
//            EXPFail(self, __LINE__, __FILE__, [error description]);
//        }];
//    } failure:^(NSHTTPURLResponse *response, NSError *error) {
//        EXPFail(self, __LINE__, __FILE__, [error description]);
//    }];
//    
//    expect([self isDone]).will.beTruthy();
//    expect(hitCache).to.beTruthy();
}


- (void)testCreateCase
{
    __block DSAPIResource *responseResource = nil;
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPIResource *newCase) {
        responseResource = newCase;
        [self done];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];

    expect([self isDone]).will.beTruthy();
    expect(responseResource[@"subject"]).will.equal(@"Creating a case via the API");
}


- (void)testUpdateCase
{
    __block DSAPIResource *anUpdatedCase = nil;
    [DSAPICase searchCasesWithParameters:@{@"subject": @"Creating a case via the API"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSDictionary *updateCaseDict = [DSAPITestUtils dictionaryFromJSONFile:@"updateCase"];
        [(DSAPICase *)page.entries[0] updateWithDictionary:updateCaseDict queue:self.APICallbackQueue success:^(DSAPICase *updatedCase) {
            anUpdatedCase = updatedCase;
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
    expect(anUpdatedCase[@"subject"]).will.equal(@"Updated");
    expect(anUpdatedCase).will.beKindOf([DSAPICase class]);
}


#pragma mark - Message, Reply, and Draft Tests

- (void)testShowMessage
{
    __block DSAPIResource *_message = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICase *)page.entries[0] showMessageWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIInteraction *message) {
            _message = message;
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
    expect(_message[@"direction"]).willNot.beNil();
    expect(_message[@"status"]).willNot.beNil();
    expect(_message).will.beKindOf([DSAPIInteraction class]);
}


- (void)testListReplies
{
    __block NSArray *_replies = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [page.entries[0] listRepliesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *repliesPage) {
            _replies = repliesPage.entries;
            [self done];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
     } failure:^(NSHTTPURLResponse *response, NSError *error) {
         EXPFail(self, __LINE__, __FILE__, [error description]);
     }];

    expect([self isDone]).will.beTruthy();
    expect(_replies.count).will.beGreaterThan(0);
    expect(_replies[0][@"direction"]).willNot.beNil();
    expect(_replies[0][@"status"]).willNot.beNil();
}


- (void)testCreateReply
{
    __block DSAPIResource *responseResource = nil;
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase createReply:[DSAPITestUtils dictionaryFromJSONFile:@"newReply"] queue:self.APICallbackQueue success:^(DSAPIInteraction *newReply) {
            responseResource = newReply;
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
    expect(responseResource[@"subject"]).will.equal(@"Re: Creating a case via the API");
    expect(responseResource).will.beKindOf([DSAPIInteraction class]);
}


- (void)testCreateDraft
{
    __block DSAPIResource *responseResource = nil;
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase createDraft:[DSAPITestUtils dictionaryFromJSONFile:@"newReply"] queue:self.APICallbackQueue success:^(DSAPIInteraction *newDraft) {
            responseResource = newDraft;
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
    expect(responseResource[@"status"]).will.equal(@"draft");
    expect(responseResource).will.beKindOf([DSAPIInteraction class]);
}


- (void)testShowDraft
{
    __block DSAPIResource *_draft = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICase *)page.entries[0] showDraftWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIInteraction *draft) {
            _draft = draft;
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
    expect(_draft[@"status"]).will.equal(@"draft");
    expect(_draft).will.beKindOf([DSAPIInteraction class]);
}


- (void)testUpdateDraft
{
    __block DSAPIResource *_updatedDraft = nil;
    
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase createDraft:[DSAPITestUtils dictionaryFromJSONFile:@"newReply"] queue:self.APICallbackQueue success:^(DSAPIInteraction *newDraft) {
            [newDraft updateWithDictionary:@{@"body":@"new body"} queue:self.APICallbackQueue success:^(DSAPIInteraction *resource) {
                _updatedDraft = resource;
                [self done];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
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
    expect(_updatedDraft[@"body"]).will.equal(@"new body");
    expect(_updatedDraft).will.beKindOf([DSAPIInteraction class]);
}


#pragma mark - Note Tests

- (void)testListNotes
{
    __block NSArray *_notes = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [page.entries[0] listNotesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *notesPage) {
            _notes = notesPage.entries;
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
    expect(_notes.count).will.beGreaterThan(0);
    expect(_notes[0][@"body"]).willNot.beNil();
    expect(_notes[0]).will.beKindOf([DSAPINote class]);
}


- (void)testCreateNote
{
    __block DSAPINote *responseNote = nil;
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase createNote:[DSAPITestUtils dictionaryFromJSONFile:@"newNote"] queue:self.APICallbackQueue success:^(DSAPINote *newNote) {
            responseNote = newNote;
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
    expect(responseNote[@"body"]).will.equal(@"Please assist me with this case");
}


#pragma mark - Attachment Tests

- (void)testListAttachments
{
    __block DSAPIAttachment *_attachment = nil;
    
    [DSAPICase searchCasesWithParameters:@{@"attachments":@"png"} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        DSAPICase *caseWithAttachments = page.entries.firstObject;

        [caseWithAttachments showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPICase *theCase) {
            [theCase listAttachmentsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
                [(DSAPIAttachment *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIAttachment *attachment) {
                    _attachment = attachment;
                    [self done];
                } failure:^(NSHTTPURLResponse *response, NSError *error) {
                    EXPFail(self, __LINE__, __FILE__, [error description]);
                }];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
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
    expect(_attachment).willNot.beNil();
    expect(_attachment).will.beKindOf([DSAPIAttachment class]);
    expect(_attachment[@"url"]).willNot.beNil();
}

- (void)testCreateAttachment
{
    __block DSAPIAttachment *responseAttachment = nil;
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase createAttachment:[DSAPITestUtils dictionaryFromJSONFile:@"newAttachment"] queue:self.APICallbackQueue success:^(DSAPIAttachment *newAttachment) {
            responseAttachment = newAttachment;
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
    expect(responseAttachment).willNot.beNil();
    expect(responseAttachment).will.beKindOf([DSAPIAttachment class]);
    expect(responseAttachment[@"url"]).willNot.beNil();
    expect(responseAttachment[@"file_name"]).will.equal(@"favicon.png");
}

- (void)testCreateAttachmentOnInteraction
{
    __block DSAPIAttachment *attachment = nil;
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase showMessageWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIInteraction *message) {
            [message createAttachment:[DSAPITestUtils dictionaryFromJSONFile:@"newAttachment"] queue:self.APICallbackQueue success:^(DSAPIAttachment *newAttachment) {
                    attachment = newAttachment;
                    [self done];
                } failure:^(NSHTTPURLResponse *response, NSError *error) {
                    EXPFail(self, __LINE__, __FILE__, [error description]);
                }];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
            }];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(attachment).willNot.beNil();
    expect(attachment).will.beKindOf([DSAPIAttachment class]);
    expect(attachment[@"url"]).willNot.beNil();
    expect(attachment[@"file_name"]).will.equal(@"favicon.png");
}

- (void)testDeleteAttachment
{
    [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase createAttachment:[DSAPITestUtils dictionaryFromJSONFile:@"newAttachment"] queue:self.APICallbackQueue success:^(DSAPIAttachment *newAttachment) {
            [newAttachment deleteWithParameters:nil queue:self.APICallbackQueue success:^(void) {
                [self done];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
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
}

- (void)testDeleteAttachmentOnInteraction
{
        [DSAPICase createCase:[DSAPITestUtils dictionaryFromJSONFile:@"newCase"] queue:self.APICallbackQueue success:^(DSAPICase *newCase) {
        [newCase showMessageWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIInteraction *message) {
            [message createAttachment:[DSAPITestUtils dictionaryFromJSONFile:@"newAttachment"] queue:self.APICallbackQueue success:^(DSAPIAttachment *newAttachment) {
                [newAttachment deleteWithParameters:nil queue:self.APICallbackQueue success:^{
                    [self done];
                } failure:^(NSHTTPURLResponse *response, NSError *error) {
                    EXPFail(self, __LINE__, __FILE__, [error description]);
                }];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
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
}

- (void)testHistory
{
    __block NSArray *_history = nil;
    [DSAPICase listCasesWithParameters:@{@"per_page": @1} queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPICase *)page.entries[0] historyWithQueue:self.APICallbackQueue success:^(DSAPIPage *historyPage) {
            _history = historyPage.entries;
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
    expect(_history).willNot.beNil();
    expect(_history.count).will.beGreaterThan(0);
    expect(_history[0][@"type"]).willNot.beNil();
    expect([_history[0] linkForRelation:@"invoker"]).willNot.beNil();
}


- (void)testPreviewMacros
{
    DSAPICase *aCase = (DSAPICase *)[DSAPITestUtils resourceFromJSONFile:@"case6"];
    [DSAPIMacro listMacrosWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        NSArray *macros = @[[page.entries firstObject]];
        [aCase previewMacros:macros queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            DSAPICase *theCase = (DSAPICase *)[page resourceForRelation:@"case"];
            DSAPIInteraction *reply = (DSAPIInteraction *)[page resourceForRelation:@"reply"];
            expect(theCase).to.beKindOf([DSAPICase class]);
            expect(reply).to.beKindOf([DSAPIInteraction class]);
            [self done];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
     } failure:^(NSHTTPURLResponse *response, NSError *error) {
         EXPFail(self, __LINE__, __FILE__, [error description]);
     }];
    
    expect([self isDone]).will.beTruthy();
}

- (void)testListCaseFeed
{
    __block NSArray *_replies = nil;
    [DSAPICase listCasesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [page.entries[0] listFeedWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *repliesPage) {
            _replies = repliesPage.entries;
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
    expect(_replies.count).will.beGreaterThan(0);
    expect(_replies[0][@"direction"]).willNot.beNil();
    expect(_replies[0][@"status"]).willNot.beNil();
}

@end
