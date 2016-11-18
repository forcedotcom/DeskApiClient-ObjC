//
//  DSAPINetworkIndicatorController.m
//  DeskAPIClient
//
//  Created by Desk.com on 8/11/15.
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

#import "DSAPINetworkIndicatorController.h"

@interface DSAPINetworkIndicatorController ()

@property (nonatomic) NSUInteger activityCount;
@property (nonatomic) NSTimer *timer;

@end

@implementation DSAPINetworkIndicatorController

#pragma mark - Lifecycle

+ (DSAPINetworkIndicatorController *)sharedController {
    static DSAPINetworkIndicatorController *_sharedController = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _activityCount = 0;
    }
    return self;
}

#pragma mark - Public

- (void)networkActivityDidStart
{
#if TARGET_OS_IPHONE
    NSAssert([NSThread isMainThread], @"Altering network activity indicator state can only be done on the main thread.");
    self.activityCount++;
    [self updateIndicatorVisibility];
#endif
}

- (void)networkActivityDidEnd
{
#if TARGET_OS_IPHONE
    NSAssert([NSThread isMainThread], @"Altering network activity indicator state can only be done on the main thread.");
    NSAssert(self.activityCount > 0, @"networkActivityDidEnd before matching networkActivityDidStart");
    self.activityCount--;
    [self updateIndicatorVisibility];
 #endif
}

#pragma mark - Private

- (void)updateIndicatorVisibility
{
#if TARGET_OS_IPHONE
    if (self.activityCount > 0) {
        [self showIndicator];
    } else {
        /*
         To prevent the indicator from flickering on and off, we delay the
         hiding of the indicator by around one second. This provides the chance
         to come in and invalidate the timer before it fires.
         */
        [self createTimerToHideIndicator];
    }
#endif
}

- (void)createTimerToHideIndicator
{
#if TARGET_OS_IPHONE
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:NO];
    self.timer.tolerance = 0.5;
#endif
}

- (void)timerFireMethod:(NSTimer *)timer
{
#if TARGET_OS_IPHONE
    [self hideIndicator];
#endif
}

- (void)showIndicator
{
#if TARGET_OS_IPHONE
    [self.timer invalidate];
    self.timer = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif
}

- (void)hideIndicator
{
#if TARGET_OS_IPHONE
    [self.timer invalidate];
    self.timer = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
}


@end
