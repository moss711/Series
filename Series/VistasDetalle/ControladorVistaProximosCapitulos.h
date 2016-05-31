//
//  ControladorVistaProximosCapitulos.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 27/7/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "ControladorVistaSecundaria.h"

@interface ControladorVistaProximosCapitulos : ControladorVistaSecundaria <NSTableViewDataSource,NSTableViewDelegate>
@property NSArray *episodios;
-(instancetype)initWithSeries:(NSArray*)Series;
@end
