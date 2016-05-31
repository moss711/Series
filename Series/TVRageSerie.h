//
//  TVRageSerie.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVRageEpisodeList.h"
#import "TVRageEpisodeInfo.h"

@interface TVRageSerie : NSObject

@property int sid;
@property NSString* nombre;
@property NSString* pais;
@property NSString* ano;
@property BOOL esAnime;
@property NSImage* miniatura;
@property NSImage* poster;
@property TVRageEpisodeInfo* tvRageEpisodeInfo;
@property TVRageEpisodeList* tvRageEpisodeList;


-(NSString *)getStringPaisAno;
@end
