//
//  EpisodioTemp.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 22/07/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serie.h"

@interface EpisodioTemp : NSObject

@property NSDate * hora;
@property NSString * nombreEpisodio;
@property NSString * numEpisodio;
@property NSNumber * numEpisodioTotal;
@property NSNumber * sid;

-(int)getEpisodio;
-(int)getTemporada;

- (NSComparisonResult)compare:(EpisodioTemp*)otherEp;
- (NSComparisonResult)compareInv:(EpisodioTemp*)otherEp;
@end
