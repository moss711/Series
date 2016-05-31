//
//  EpisodioTemp.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 22/07/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "EpisodioTemp.h"

@implementation EpisodioTemp


-(int)getEpisodio{
    NSArray *items = [self.numEpisodio componentsSeparatedByString:@"x"];
    NSString *apoyo=[items objectAtIndex:1];
    return [apoyo intValue];
}

-(int)getTemporada{
    NSArray *items = [self.numEpisodio componentsSeparatedByString:@"x"];
    NSString *apoyo=[items objectAtIndex:0];
    return [apoyo intValue];
}

- (NSComparisonResult)compare:(EpisodioTemp *)otherEp {
    NSNumber* temporada=[NSNumber numberWithInt:self.getTemporada];
    NSNumber* episodio=[NSNumber numberWithInt:self.getEpisodio];
    NSNumber* otraTemporada=[NSNumber numberWithInt:otherEp.getTemporada];
    NSNumber* otroEpisodio=[NSNumber numberWithInt:otherEp.getEpisodio];
    NSComparisonResult result= [temporada compare:otraTemporada];
    if(result==NSOrderedSame){
        return [episodio compare:otroEpisodio];
    }else{
        return result;
    }
}

- (NSComparisonResult)compareInv:(EpisodioTemp *)otherEp {
    return -1*[self compare:otherEp];
}
@end
