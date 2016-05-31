//
//  TVRageSearch.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 28/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVRageSearch : NSObject

@property NSXMLDocument* xmlSearch;

-(instancetype)initWithString:(NSString *)nombre;
-(NSArray*)getBusqueda;


@end
