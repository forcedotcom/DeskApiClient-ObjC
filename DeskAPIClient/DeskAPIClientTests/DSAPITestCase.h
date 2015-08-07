//
//  DSAPITestCase.h
//  DeskAPIClient
//
//  Created by Jamie Forrest on 1/12/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DeskCommon/DSCHttpStatusCodes.h>

@interface DSAPITestCase : XCTestCase

@property (nonatomic) NSOperationQueue *APICallbackQueue;

- (void)done;
- (BOOL)isDone;

@end
