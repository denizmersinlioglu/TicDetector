//
//  MatrixFloat.h
//  GRTiOS
//
//  Created by Deniz Mersinlioğlu on 4/10/19.
//  Copyright © 2019 Nicholas Arner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VectorFloat.h"

@interface MatrixFloat : NSObject

- (instancetype)initWithSize:(UInt8)row: (UInt8)col;

- (void)pushBack:(VectorFloat *)value;
- (void)clear;

#ifdef __cplusplus
- (GRT::MatrixFloat *)cppInstance;
#endif

@end
