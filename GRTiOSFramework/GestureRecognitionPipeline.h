//
//  GestureRecognitionPipeline.h
//  grt
//
//  Created by mjahnen on 25/11/15.
//  Copyright © 2015 jahnen. All rights reserved.
//  Modified by Nick Arner, 2017
//

#import <Foundation/Foundation.h>
#import "VectorDouble.h"
#import "VectorFloat.h"
#import "MatrixDouble.h"
#import "MatrixFloat.h"


@interface GestureRecognitionPipeline : NSObject

@property (readonly, getter = predictedClassLabel) NSUInteger predictedClassLabel;
@property (readonly, getter = maximumLikelihood) double maximumLikelihood;

- (BOOL)savePipeline:(NSURL *)url;
- (BOOL)loadPipeline:(NSURL *)url;
- (BOOL)getTrained;
- (BOOL)saveClassificationData:(NSURL *)url;
- (BOOL)loadClassificationData:(NSURL *)url;
- (BOOL)setClassifier:(NSString *)classifier;
- (BOOL)predict:(VectorDouble *)inputVector;
- (void)addSamplesToClassificationDataForGesture:(NSUInteger)gesture :(MatrixFloat *)vectorData;
- (BOOL)trainPipeline;

@end
