//
//  ControladorVistaProximosCapitulos.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 27/7/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "ControladorVistaProximosCapitulos.h"
#import "Serie.h"
#import "Episodio.h"

@interface ControladorVistaProximosCapitulos ()
@property NSArray *series;

@end

@implementation ControladorVistaProximosCapitulos


-(instancetype)initWithSeries:(NSArray *)series{
    self=[super init];
    self.series=series;
    NSDate *ahora=[NSDate date];
    NSMutableArray *episodiosTemp=[[NSMutableArray alloc]init];
    for(Serie *serie in series){
        NSArray *episodiosSerie=[serie.episodios allObjects];
        for(Episodio* ep in episodiosSerie){
            if([ep.hora compare:ahora]==NSOrderedDescending){
                [episodiosTemp addObject:ep];
            }
        }
    }
    [episodiosTemp sortUsingSelector:@selector(compareProximos:)];
    self.episodios=episodiosTemp;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(NSString*)getStringTitulo{
    if(self.series.count>1){
        return [[NSString alloc]initWithFormat:@"%ld series",self.series.count];
    }else{
        Serie* serie=[self.series objectAtIndex:0];
        return serie.getNombreAMostrar;
    }
}

-(NSString*)getStringSubtitulo{
    return @"Próximos capítulos";
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    return YES;
}

//Voy a probar con bindings
//datamodel
//- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//}
//- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
//}
@end
