//
//  MCOIMAPFetchFoldersOperation.m
//  mailcore2
//
//  Created by Matt Ronge on 1/31/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOIMAPFetchFoldersOperation.h"

#import "NSError+MCO.h"
#import "MCOOperation+Private.h"

#import "MCOUtils.h"

#import <Foundation/Foundation.h>
#import <mailcore/MCAsync.h>

using namespace mailcore;

typedef void (^completionType)(NSError *error, NSArray *folder);

@implementation MCOIMAPFetchFoldersOperation {
    completionType _completionBlock;
}

#define nativeType mailcore::IMAPFetchFoldersOperation

+ (void) load
{
    MCORegisterClass(self, &typeid(nativeType));
}

+ (NSObject *) mco_objectWithMCObject:(mailcore::Object *)object
{
    nativeType * op = (nativeType *) object;
    return [[[self alloc] initWithMCOperation:op] autorelease];
}

- (void) dealloc
{
    [_completionBlock release];
    [super dealloc];
}

- (void)start:(void (^)(NSError *error, NSArray *folder))completionBlock {
    _completionBlock = [completionBlock copy];
    [self start];
}

- (void)operationCompleted {
    nativeType *op = MCO_NATIVE_INSTANCE;
    if (op->error() == ErrorNone) {
        _completionBlock(nil, MCO_TO_OBJC(op->folders()));
    } else {
        _completionBlock([NSError mco_errorWithErrorCode:op->error()], nil);
    }
}

@end