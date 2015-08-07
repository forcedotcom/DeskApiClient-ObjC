//
//  DSAPITestCase.m
//  DeskAPIClient
//
//  Created by Jamie Forrest on 1/12/15.
//  Copyright (c) 2015 Desk.com. All rights reserved.
//

#import "DSAPITestCase.h"

@interface DSAPITestCase()

@property (nonatomic) BOOL isDone;

- (void)start;

@end

@implementation DSAPITestCase

- (void)setUp {
    [super setUp];
    [DSAPITestUtils setupSharedAPIClient];
    _APICallbackQueue = [NSOperationQueue new];
    _APICallbackQueue.name = @"APICallbackQueue";
    [self start];
}

- (void)start
{
    self.isDone = NO;
}

- (void)done
{
    self.isDone = YES;
}

@end
