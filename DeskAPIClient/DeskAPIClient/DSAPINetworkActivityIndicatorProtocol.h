//
//  DSAPINetworkActivityIndicatorProtocol.h
//  DeskAPIClient
//
//  Created by Noel Artiles on 12/1/16.
//  Copyright © 2016 Desk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DSAPINetworkActivityIndicatorProtocol <NSObject>

- (void)networkActivityDidStart;
- (void)networkActivityDidEnd;

@end
