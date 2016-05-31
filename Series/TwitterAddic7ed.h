//
//  SCSimpleSLRequestDemo.h
//  PruebaTwitter
//
//  Created by Alexandre Blanco Gómez on 12/08/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterAddic7ed : NSObject
@property BOOL hayCuenta;
@property dispatch_semaphore_t semaforoPaso;
@property NSArray *tweets;
- (void)fetchTimeline;
@end
