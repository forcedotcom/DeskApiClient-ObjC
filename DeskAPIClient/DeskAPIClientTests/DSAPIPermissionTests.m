//
//  DSAPIPermissionTests.m
//  DeskAPIClient
//
//  Created by Jamie Forrest on 4/15/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSAPITestCase.h"
#import "DSAPIETagCache.h"

@interface DSAPIPermissionTests : DSAPITestCase

@end

@implementation DSAPIPermissionTests

- (void)testListPermissions
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should GET permissions"];
    
    [[DSAPIETagCache sharedManager] clearCache];
    [DSAPIPermission listPermissionsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *permissionsPage) {
        expect(permissionsPage.entries.count).to.beGreaterThanOrEqualTo(35);
        DSAPIPermission *permission = permissionsPage.entries.firstObject;
        expect(permission).to.beKindOf([DSAPIPermission class]);
        expect(permission[@"name"]).to.equal(@"read_case");
        [expectation fulfill];
    } notModified:^(DSAPIPage *page) {
        EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout handler:nil];
}

- (void)testShowPermission
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should GET a permission"];
    
    [[DSAPIETagCache sharedManager] clearCache];
    [DSAPIPermission listPermissionsWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPage *permissionsPage) {
        DSAPIPermission *permission = permissionsPage.entries.firstObject;
        [permission showWithParameters:nil queue:self.APICallbackQueue success:^(DSAPIPermission *permissionResponse) {
            expect(permissionResponse).to.beKindOf([DSAPIPermission class]);
            expect(permissionResponse[@"name"]).to.equal(@"read_case");
            [expectation fulfill];
        } failure:^(NSHTTPURLResponse *response, NSError *error) {
            EXPFail(self, __LINE__, __FILE__, [error description]);
            [expectation fulfill];
        }];
    } notModified:^(DSAPIPage *page) {
        EXPFail(self, __LINE__, __FILE__, @"Received an unexpected 304 response");
        [expectation fulfill];
    } failure:^(NSHTTPURLResponse *response, NSError *error) {
        EXPFail(self, __LINE__, __FILE__, [error description]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:DSAPIDefaultTimeout handler:nil];
}

@end
