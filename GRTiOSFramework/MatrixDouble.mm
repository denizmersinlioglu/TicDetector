//
//  MatrixDouble.mm
//  GRTiOS
//
//  Created by Deniz Mersinlioğlu on 4/10/19.
//  Copyright © 2019 Nicholas Arner. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include "grt.h"
#endif

#import "MatrixDouble.h"

@interface MatrixDouble()
@property GRT::MatrixDouble *instance;
@end

@implementation MatrixDouble

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.instance = new GRT::MatrixDouble;
    }
    return self;
}

- (instancetype)initWithSize:(UInt8) row: (UInt8) col
{
    self = [super init];
    if (self) {
        self.instance = new GRT::MatrixDouble(row,col);
    }
    return self;
}

- (void)dealloc
{
    delete self.instance;
}

- (void)pushBack:(VectorDouble *) value
{
    self.instance->push_back(*[value cppInstance]);
}

- (void)clear
{
    self.instance->clear();
}

- (GRT::MatrixDouble *)cppInstance
{
    return self.instance;
}

@end
