//
//  SubtitulosEsListaSeries.m
//  PruebaParserNyya
//
//  Created by Alexandre Blanco Gómez on 26/2/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "SubtitulosEsListaSeries.h"
#import "SubtitulosEsSerie.h"
#import "ObjectiveGumbo.h"

@implementation SubtitulosEsListaSeries

-(instancetype)init{
    self=[super init];
    if(self){
        NSString *direccion=[[NSString alloc]initWithFormat:@"http://www.subtitulos.es/series"];
        NSURL *url=[NSURL URLWithString:direccion];
        OGNode * data = [ObjectiveGumbo parseNodeWithUrl:url encoding:NSASCIIStringEncoding];
        if(data==nil){
            return nil;
        }
        NSArray* line0s=[data elementsWithClass:@"line0"];
        NSMutableSet *listaMut =[[NSMutableSet alloc]init];
        for(OGElement *line0 in line0s){
            NSArray* as=[line0 elementsWithTag:GUMBO_TAG_A];
            if(as.count>0){
                OGElement *a=[as objectAtIndex:0];
                NSString* id=[a.attributes valueForKey:@"href"];
                if(id!=nil){
                    NSRange rango=[id rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]  options:NSBackwardsSearch];
                    id=[id substringFromIndex:rango.location+1];
                    SubtitulosEsSerie *serie=[[SubtitulosEsSerie alloc]init];
                    serie.nombre=line0.text;
                    serie.id=id.intValue;
                    [listaMut  addObject:serie];
                    //NSLog(@"%@->%@",line0.text,id);
                }
            }
        }
        self.series=[NSSet setWithSet:listaMut];
        
    }
    return self;
}

-(NSArray*)getListaSeriesParaNombre:(NSString *)nombre{
    //Primero buscamos resultados con el nombre tal cual
    NSMutableArray *predarray = [NSMutableArray array];
    NSArray *tokens = [nombre componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    for(NSString *token in tokens){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nombre CONTAINS %@",token];
        [predarray addObject:predicate];
    }
    
    NSPredicate *final = [NSCompoundPredicate orPredicateWithSubpredicates:predarray];
    
    NSSet *resultados=[self.series filteredSetUsingPredicate:final];
    //NSLog(@"Count resultados: %lu",(unsigned long)resultados.count);
    
    for(SubtitulosEsSerie *serie in resultados){
        int hits=0;
        for(NSString* token in tokens){
            if([serie.nombre rangeOfString:token options:NSCaseInsensitiveSearch].location!=NSNotFound){
                hits++;
            }
        }
        serie.hits=hits;
    }
    
    //Ahora con el nombre trimeado
    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
    NSString *nombreTrimeado = [[nombre componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
    
    [predarray removeAllObjects];
    tokens=[nombreTrimeado componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    for(NSString *token in tokens){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nombre CONTAINS %@",token];
        [predarray addObject:predicate];
    }
    
    final = [NSCompoundPredicate orPredicateWithSubpredicates:predarray];
    NSSet *resultadosTrimeado =[self.series filteredSetUsingPredicate:final];
    
    for(SubtitulosEsSerie *serie in resultadosTrimeado){
        int hits=0;
        for(NSString* token in tokens){
            if([serie.nombre rangeOfString:token options:NSCaseInsensitiveSearch].location!=NSNotFound){
                hits++;
            }
        }
        serie.hits=hits;
    }
    
    //Juntamos los dos resultados
    NSMutableArray *listaResultados=[[NSMutableArray alloc]initWithArray:[resultados allObjects]];
    
    for(SubtitulosEsSerie *serie in resultadosTrimeado){
        Boolean encontrado=NO;
        for(SubtitulosEsSerie *serieEnArray in listaResultados){
            if(serieEnArray.id==serie.id){
                encontrado=YES;
                serieEnArray.hits=serieEnArray.hits+serie.hits;
                break;
            }
        }
        if(!encontrado){
            [listaResultados addObject:serie];
        }
    }
    
    //Ordenamos la lista
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hits"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *listaResultadosOrdenada = [listaResultados sortedArrayUsingDescriptors:sortDescriptors];
    
    return listaResultadosOrdenada;
}

-(SubtitulosEsSerie*)getSerieParaNombre:(NSString *)nombre{
    NSPredicate *predExacto=[NSPredicate predicateWithFormat:@"nombre = %@",nombre];
    NSSet *resultados=[self.series filteredSetUsingPredicate:predExacto];
    if(resultados.count>0){
        return [[resultados allObjects] objectAtIndex:0];
    }
    NSCharacterSet *trim = [NSCharacterSet characterSetWithCharactersInString:@"(;);'"];
    NSString *nombreTrimeado = [[nombre componentsSeparatedByCharactersInSet: trim] componentsJoinedByString: @""];
    
    predExacto=[NSPredicate predicateWithFormat:@"nombre = %@",nombreTrimeado];
    resultados=[self.series filteredSetUsingPredicate:predExacto];
    if(resultados.count>0){
        return [[resultados allObjects]objectAtIndex:0];
    }
    
    NSArray* series=[self getListaSeriesParaNombre:nombre];
    if(series.count>0){
        return [series objectAtIndex:0];
    }
    return nil;
}
@end
