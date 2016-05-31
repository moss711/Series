//
//  TVRageEpisodeInfo.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serie.h"
#import "EpisodioTemp.h"

@interface TVRageEpisodeInfo : NSObject

@property int sid;
@property NSXMLDocument* xmlEpisodeInfo;

-(instancetype)initWithSid:(int)sid;

-(EpisodioTemp *)getNextEpisode;
-(EpisodioTemp *)getLatestEpisode;
-(BOOL)parsear;
-(NSString *)getPais;
@end
