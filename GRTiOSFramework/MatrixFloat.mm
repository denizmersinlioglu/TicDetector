//
//  MatrixFloat.mm
//  GRTiOS
//
//  Created by Deniz Mersinlioğlu on 4/10/19.
//  Copyright © 2019 Nicholas Arner. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include "grt.h"
#endif

#import "MatrixFloat.h"

@interface MatrixFloat()
@property GRT::MatrixFloat *instance;
@end

@implementation MatrixFloat

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.instance = new GRT::MatrixFloat;
    }
    return self;
}

- (instancetype)initWithSize:(UInt8) row: (UInt8) col
{
    self = [super init];
    if (self) {
        self.instance = new GRT::MatrixFloat(row,col);
    }
    return self;
}

- (void)dealloc
{
    delete self.instance;
}

- (void)pushBack:(VectorFloat *) value
{
    self.instance->push_back(*[value cppInstance]);
}

- (void)clear
{
    self.instance->clear();
}

- (GRT::MatrixFloat *)cppInstance
{
    return self.instance;
}

@end
