//
//  DSAPIMobileDeviceTests.m
//  DeskAPIClient
//
//  Created by Desk.com on 4/5/14.
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

@interface DSAPIMobileDeviceTests : DSAPITestCase

@property (nonatomic, strong) DSAPIClient *client;

@end

@implementation DSAPIMobileDeviceTests

- (void)setUp
{
    [super setUp];
    [Expecta setAsynchronousTestTimeout:5.0];
    _client = [DSAPITestUtils APIClientBasicAuth];
}

- (void)testCreateMobileDevice
{
    __block DSAPIMobileDevice *device = nil;
    [DSAPIMobileDevice createMobileDevice:@{@"type":@"ios",
                                            @"device_token":@"0a209749df4ad0236767474dba6f08d3d02b91bed60258abb33f11af56a92eb6"}
                                    queue:self.APICallbackQueue
                                  success:^(DSAPIMobileDevice *newMobileDevice) {
                                      device = newMobileDevice;
                                      [self done];
                                  } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                      EXPFail(self, __LINE__, __FILE__, [error description]);
                                  }];
    
    expect([self isDone]).will.beTruthy();
    expect(device[@"device_token"]).will.equal(@"0a209749df4ad0236767474dba6f08d3d02b91bed60258abb33f11af56a92eb6");
}

- (void)testDeleteMobileDevice
{
    [DSAPIMobileDevice createMobileDevice:@{@"type":@"ios",
                                            @"device_token":@"1a209749df4ad0236767474dba6f08d3d02b91bed60258abb33f11af56a92eb6"}
                                    queue:self.APICallbackQueue
                                  success:^(DSAPIMobileDevice *newMobileDevice) {
                                      [newMobileDevice deleteWithParameters:nil queue:self.APICallbackQueue success:^(void) {
                                          [self done];
                                      } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                          EXPFail(self, __LINE__, __FILE__, [error description]);
                                      }];
                                  } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                      EXPFail(self, __LINE__, __FILE__, [error description]);
                                  }];
    
    expect([self isDone]).will.beTruthy();
}

- (void)testShowMobileDevice
{
    [[DSAPIETagCache sharedManager] clearCache];
    
    __block DSAPIMobileDevice *device = nil;
    [DSAPIMobileDevice createMobileDevice:@{@"type":@"ios",
                                            @"device_token":@"2a209749df4ad0236767474dba6f08d3d02b91bed60258abb33f11af56a92eb6"}
                                    queue:self.APICallbackQueue
                                  success:^(DSAPIMobileDevice *newMobileDevice) {
                                      [DSAPIUser listMyMobileDevicesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
                                          [(DSAPIMobileDevice *)page.entries[0] showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIMobileDevice *mobileDevice) {
                                              device = mobileDevice;
                                              [self done];
                                          } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                              EXPFail(self, __LINE__, __FILE__, [error description]);
                                          }];
                                      } notModified:^(DSAPIPage *page) {
                                          EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
                                      } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                          EXPFail(self, __LINE__, __FILE__, [error description]);
                                      }];
                                  } failure:^(NSHTTPURLResponse *response, NSError *error) {
                                      EXPFail(self, __LINE__, __FILE__, [error description]);
                                  }];
    
    expect([self isDone]).will.beTruthy();
    expect(device).willNot.beNil();
    expect(device).will.beKindOf([DSAPIMobileDevice class]);
}

- (void)testListSettings
{
    [[DSAPIETagCache sharedManager] clearCache];
    
    __block NSArray *settings = nil;
    [DSAPIUser listMyMobileDevicesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIMobileDevice *)page.entries[0] listSettingsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            settings = page.entries;
            [self done];
        } notModified:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } notModified:^(DSAPIPage *page) {
        EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(settings.count).will.equal(6);
    expect(settings[0][@"name"]).will.equal(@"case_created");
    expect(settings[0][@"id"]).will.equal(100);
    expect(settings[0]).will.beKindOf([DSAPIMobileDeviceSetting class]);
}

- (void)testUpdateSetting
{
    [[DSAPIETagCache sharedManager] clearCache];
    
    __block DSAPIMobileDeviceSetting *_updatedSetting = nil;
    [DSAPIUser listMyMobileDevicesWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
        [(DSAPIMobileDevice *)page.entries[0] listSettingsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *page) {
            [(DSAPIMobileDeviceSetting *)page.entries[0] updateWithDictionary:@{@"value":@YES} queue:self.APICallbackQueue success:^(DSAPIMobileDeviceSetting *updatedSetting) {
                _updatedSetting = updatedSetting;
                [self done];
            } failure:^(NSHTTPURLResponse *response, NSError *error) {
                EXPFail(self, __LINE__, __FILE__, [error description]);
            }];
        } notModified:^(DSAPIPage *page) {
            EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [self done];
        }];
    } notModified:^(DSAPIPage *page) {
        EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [self done];
    }];
    
    expect([self isDone]).will.beTruthy();
    expect(_updatedSetting[@"value"]).will.beTruthy();
    expect(_updatedSetting).will.beKindOf([DSAPIMobileDeviceSetting class]);
}

@end
