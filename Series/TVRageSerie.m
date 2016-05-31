//
//  TVRageSerie.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "TVRageSerie.h"

@implementation TVRageSerie


-(NSString*)getStringPaisAno{
    return [[NSString alloc]initWithFormat:@"%@, %@",self.pais,self.ano];
}
@end
