//
//  SCSimpleSLRequestDemo.m
//  PruebaTwitter
//
//  Created by Alexandre Blanco Gómez on 12/08/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TwitterAddic7ed.h"

@interface TwitterAddic7ed()

@property (nonatomic) ACAccountStore *accountStore;

@property ACAccount *cuentaTwitter;


@end

@implementation TwitterAddic7ed

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        self.semaforoPaso=dispatch_semaphore_create(0);
        self.hayCuenta=NO;
        
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 //NSLog(@"%ld",[twitterAccounts count]);
                 if([twitterAccounts count]>0){
                     self.hayCuenta=YES;
                     self.cuentaTwitter=[twitterAccounts lastObject];
                     //[self fetchTimeline]; no quiero que busque solo al iniciarse
                 }
                 dispatch_semaphore_signal(self.semaforoPaso);//damos paso a la comprobacion de creado
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
                 dispatch_semaphore_signal(self.semaforoPaso);//damos paso a la comprobacion de creado
             }
         }];
    }
    return self;
}


- (void)fetchTimeline{
    NSMutableArray *subs = [[NSMutableArray alloc]init];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                  @"/1.1/statuses/user_timeline.json"];
    NSDictionary *params = @{@"screen_name" : @"addic7ed",
                             @"include_rts" : @"0",
                             @"trim_user" : @"1",
                             @"count" : @"200"};
    SLRequest *request =
    [SLRequest requestForServiceType:SLServiceTypeTwitter
                       requestMethod:SLRequestMethodGET
                                 URL:url
                          parameters:params];
    
    //  Attach an account to the request
    [request setAccount:self.cuentaTwitter];
    
    [request performRequestWithHandler:
     ^(NSData *responseData,
       NSHTTPURLResponse *urlResponse,
       NSError *error) {
         
         if (responseData) {
             if (urlResponse.statusCode >= 200 &&
                 urlResponse.statusCode < 300) {
                 
                 NSError *jsonError;
                 NSDictionary *timelineData =
                 [NSJSONSerialization
                  JSONObjectWithData:responseData
                  options:NSJSONReadingAllowFragments error:&jsonError];
                 if (timelineData) {
                     //NSLog(@"Timeline Response: %@\n", timelineData);
                     
                     for(NSDictionary *apoyo in timelineData){
                         NSString *text =[apoyo valueForKey:@"text"];
                         NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^New Releases - (.+) - (\\d{2}x\\d{2}) - .+$" options:NSRegularExpressionCaseInsensitive error:nil];
                         NSArray *matches = [nameExpression matchesInString:text
                                                                    options:0
                                                                      range:NSMakeRange(0, [text length])];
                         NSString *serie;
                         NSString *ep;
                         NSString *url;
                         if ([matches count]>0){
                             NSTextCheckingResult *match = [matches objectAtIndex:0];
                             NSRange matchRange = [match rangeAtIndex:1];
                             serie = [text substringWithRange:matchRange];
                             matchRange = [match rangeAtIndex:2];
                             ep = [text substringWithRange:matchRange];
                             NSString *idTweet=[apoyo valueForKey:@"id"];
                             NSArray *urls =[apoyo valueForKeyPath:@"entities.urls"];
                             if([urls count]>0){
                                NSDictionary *objURL = [urls objectAtIndex:0];
                                url = [objURL valueForKeyPath:@"expanded_url"];
                                
                                 
                                 NSDictionary *diccionario = @{
                                                             @"serie" : serie,
                                                             @"episodio" : ep,
                                                             @"url" : url,
                                                             @"id" : idTweet,
                                                             };
                                 [subs addObject:diccionario];
                             }
                         }
                     }
                 }
                 else {
                     // Our JSON deserialization went awry
                     NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                     
                 }
             }
             else {
                 // The server did not respond ... were we rate-limited?
                 NSLog(@"The response status code is %ld",
                       (long)urlResponse.statusCode);
                 
             }
         }
         self.tweets=[[NSArray alloc]initWithArray:subs];
         dispatch_semaphore_signal(self.semaforoPaso);//damos paso a la comprobacion de buscado
     }];
}
@end