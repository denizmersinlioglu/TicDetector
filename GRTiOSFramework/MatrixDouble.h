//
//  MatrixDouble.h
//  GRTiOS
//
//  Created by Deniz Mersinlioğlu on 4/10/19.
//  Copyright © 2019 Nicholas Arner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VectorDouble.h"

@interface MatrixDouble : NSObject

- (instancetype)initWithSize:(UInt8)row: (UInt8)col;

- (void)pushBack:(VectorDouble *)value;
- (void)clear;

#ifdef __cplusplus
- (GRT::MatrixDouble *)cppInstance;
#endif

@end
