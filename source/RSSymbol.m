//
//  RSSymbol.m
//  restore-symbol
//
//  Created by EugeneYang on 16/8/19.
//
//

#import "RSSymbol.h"

@implementation RSSymbol


+ (NSArray<RSSymbol *> *)symbolsWithJson:(NSData *)json{
    NSError * e = nil;
    
    NSArray *symbols = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:&e];
    
    if (!symbols) {
        fprintf(stderr,"Parse json error!\n");
        fprintf(stderr,"%s\n", e.description.UTF8String);
        return nil;
    }
    
    NSMutableArray * rt = [NSMutableArray array];
    for (NSDictionary *dict in symbols) {
        NSString *addressString = dict[RS_JSON_KEY_ADDRESS];
        unsigned long long address;
        NSScanner* scanner = [NSScanner scannerWithString:addressString];
        [scanner scanHexLongLong:&address];
        RSSymbol * symbol = [self symbolWithName:dict[RS_JSON_KEY_SYMBOL_NAME] address:address];
        [rt addObject:symbol];
    }
    
    return rt;
}


+ (RSSymbol *)symbolWithName:(NSString *)name address:(uint64)addr{
    RSSymbol * s = [RSSymbol new];
    s.name = name;
    s.address = addr;
    return s;
}

+ (NSData *)jsonDataOfSymbols:(NSArray<RSSymbol *> *)symbols vmaddr:(NSUInteger)vmaddr {
    NSArray *sortSymbols = [symbols sortedArrayUsingComparator:^NSComparisonResult(RSSymbol *obj1, RSSymbol *obj2) {
        return (obj1.address < obj2.address ? NSOrderedAscending : NSOrderedDescending);
    }];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (RSSymbol *symbol in sortSymbols) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[RS_JSON_KEY_SYMBOL_NAME] = symbol.name;
        dict[RS_JSON_KEY_ADDRESS] = [NSString stringWithFormat:@"0x%llx", symbol.address];
        dict[RS_JSON_KEY_OFFSET] = @(symbol.address - vmaddr);
        [array addObject:dict];
    }
    
    NSError *e = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&e];
    return data;
}

@end
