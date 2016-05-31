//
//  DescargaTemp.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 30/10/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "DescargaTemp.h"


@implementation DescargaTemp
@synthesize releaseGroup = _releaseGroup;

-(void)setReleaseGroup:(NSString*)r{
    _releaseGroup=r;
}

-(NSString*)releaseGroup{
    if(_releaseGroup!=nil){
        return _releaseGroup;
    }
    NSRange rangoDeGuion=[self.nombre rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"] options:NSBackwardsSearch];
    if(rangoDeGuion.location==NSNotFound){
        return nil;
    }
    NSRange rangoReleaseGroup= {.location = rangoDeGuion.location+1, .length = self.nombre.length-rangoDeGuion.location-1};
    NSString *releaseGroup=[self.nombre substringWithRange:rangoReleaseGroup];
    NSRange rangoCorchete=[releaseGroup rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"["]];
    if (rangoCorchete.location!=NSNotFound) {
        rangoReleaseGroup.location=0;
        rangoReleaseGroup.length=rangoCorchete.location;
        releaseGroup=[releaseGroup substringWithRange:rangoReleaseGroup];
        releaseGroup=[releaseGroup stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceCharacterSet]];
    }
    _releaseGroup=releaseGroup;
    return releaseGroup;
}
@end
