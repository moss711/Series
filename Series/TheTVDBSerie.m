//
//  TheTVDBSerie.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "TheTVDBSerie.h"

@implementation TheTVDBSerie

-(NSString*)getStringPaisAno{
    return [[NSString alloc]initWithFormat:@"%@, %@",self.network,self.ano];
}
@end
