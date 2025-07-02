//
//  BerTlv.m
//  BerTlv
//
//  Created by Evgeniy Sinev on 04/08/14.
//  Copyright (c) 2014 Evgeniy Sinev. All rights reserved.
//

#import "BerTlv.h"
#import "BerTag.h"
#import "HexUtil.h"
#import "BerTlvErrors.h"

@implementation BerTlv

@synthesize tag, value, list, constructed, primitive;

- (id)init:(BerTag *)aTag array:(NSArray *)aArray {
    self = [super init];
    if(self) {
        tag = aTag;
        list = aArray;
        constructed = aTag.isConstructed;
        primitive = !constructed;
    }
    return self;
}

- (id)init:(BerTag *)aTag value:(NSData *)aValue {
    self = [super init];
    if(self) {
        tag = aTag;
        value = aValue;
        constructed = aTag.isConstructed;
        primitive = !constructed;
    }
    return self;
}

- (BOOL)hasTag:(BerTag *)aTag {
    return [self find:aTag] != nil;
}

- (BerTlv *)find:(BerTag *)aTag {
    if([aTag isEqualToTag:tag]) {
        return self;
    }

    if(primitive) {
        return nil;
    }
    
    for(BerTlv *tlv in list) {
        BerTlv *found = [tlv find:aTag];
        if(found!=nil) {
            return found;
        }
    }

    return nil;
}

- (NSArray *)findAll:(BerTag *)aTag {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if([aTag isEqualToTag:tag]) {
        [array addObject:self];
    }

    if(constructed) {
        for( BerTlv * tlv in list) {
            NSArray *found = [tlv findAll:aTag];
            [array addObjectsFromArray:found];
        }
    }

    return [array copy];
}

- (NSString *)hexValue {
    if (constructed) {
        NSLog(@"Tag %@ is constructed", tag);
        return nil;
    } else {
        return [HexUtil format:value];
    }
}

- (NSString *)textValue {
    return [[NSString alloc] initWithData:self.value encoding:NSASCIIStringEncoding];
}

- (NSString *)dump:(NSString *)aPadding {
    NSMutableString *sb = [[NSMutableString alloc] init];

    if(primitive) {
        [sb appendFormat:@"%@ - [%@] %@\n", aPadding, tag.hex, [self hexValue]];
    } else {
        [sb appendFormat:@"%@ + [%@]\n", aPadding, tag.hex];
        NSMutableString *childPadding = [[NSMutableString alloc] init];
        [childPadding appendString:aPadding];
        [childPadding appendString:aPadding];
        for (BerTlv *tlv in list) {
            [sb appendString:[tlv dump:childPadding]];
        }
    }
    return [sb copy];
}


@end
