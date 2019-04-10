//
//  GestureRecognitionPipeline.m
//  grt
//
//  Created by mjahnen on 25/11/15.
//  Copyright © 2015 jahnen. All rights reserved.
//  Modified by Nick Arner, 2017
//

#ifdef __cplusplus
#include "GRT.h"
#include <math.h>
#include <cmath>
#endif

#import "GestureRecognitionPipeline.h"

class NSLogStream: public std::streambuf {
public:
    NSLogStream(std::ostream& stream) :
    orgStream(stream)
    {
        // Swap the the old buffer in ostream with this buffer.
        orgBuf = orgStream.rdbuf(this);
    }
    
    ~NSLogStream(){
        orgStream.rdbuf(orgBuf); // Restore old buffer
    }
    
protected:
    int_type overflow(int_type c) {
        if(!traits_type::eq_int_type(c, traits_type::eof()))
        {
            char_type const t = traits_type::to_char_type(c);
            this->xsputn(&t, 1);
        }
        return !traits_type::eof();
    }
    
    int sync() {
        return 0;
    }
    
    virtual std::streamsize xsputn(const char *msg, std::streamsize count){
        std::string s(msg,count);
        NSLog(@"GRT cout: %@", @(s.c_str()));
        return count;
    }
    
private:
    std::streambuf *orgBuf;
    std::ostream& orgStream;
};

@interface GestureRecognitionPipeline()
@property GRT::GestureRecognitionPipeline *instance;
@property GRT::LabelledTimeSeriesClassificationData *classificationData;
@property GRT::LabelledTimeSeriesClassificationData *trainingData;
@property GRT::MatrixFloat *sampleData;

@property NSLogStream *nsLogStream;
@end

@implementation GestureRecognitionPipeline


- (instancetype)init {
    self = [super init];
    if (self) {
        self.instance = new GRT::GestureRecognitionPipeline;
        self.classificationData = new GRT::LabelledTimeSeriesClassificationData;
        self.trainingData = new GRT::LabelledTimeSeriesClassificationData;
        [self setClassifier];
        // Redirect cout to NSLog
        self.nsLogStream = new NSLogStream(std::cout);
    }
    return self;
}

- (void)dealloc {
    delete self.instance;
    delete self.nsLogStream;
}

-(BOOL)getTrained{
    return self.instance->getTrained();
}

//// pipeline configuration
- (void)setClassifier {
    GRT::DTW classifier;
    self.instance->setClassifier(classifier);
    
    //  Turn on null rejection, this lets the classifier output the predicted class label of 0 when the likelihood of a gesture is low
    classifier.enableNullRejection( true );
    
    //Set the null rejection coefficient to 3, this controls the thresholds for the automatic null rejection
    //You can increase this value if you find that your real-time gestures are not being recognized
    //If you are getting too many false positives then you should decrease this value
    classifier.setNullRejectionCoeff( 3 );
    
    //Turn on the automatic data triming, this will remove any sections of none movement from the start and end of the training samples
    classifier.enableTrimTrainingData(true,0.1,90);
 
    //Offset the timeseries data by the first sample, this makes your gestures (more) invariant to the location the gesture is performed
    classifier.setOffsetTimeseriesUsingFirstSample(true);
    
    //Allow the DTW algorithm to search the entire cost matrix
    classifier.setContrainWarpingPath( true );
    
    self.instance->addPostProcessingModule(GRT::ClassLabelTimeoutFilter(500, GRT::ClassLabelTimeoutFilter::ALL_CLASS_LABELS));
    self.classificationData->setNumDimensions(3);
}

//// save and load pipeline
- (BOOL)savePipeline:(NSURL *)url {
    BOOL result = self.instance->savePipelineToFile(std::string([url fileSystemRepresentation]));
    return result;
}

- (BOOL)loadPipeline:(NSURL *)url {

    BOOL result = self.instance->load(std::string([url fileSystemRepresentation]));
    
    if (result) {
        std::cout << "GRT config";
        std::cout << self.instance->getModelAsString();
        std::cout << "GRT info: " << self.instance->getInfo();
    }
    
    return result;
}

////   and load classification data
- (BOOL)saveClassificationData:(NSURL *)url {
    
    BOOL result = self.classificationData->save(std::string([url fileSystemRepresentation]));
    
    return result;
}

- (BOOL)loadClassificationData:(NSURL *)url {
    
    BOOL result = self.classificationData->load(std::string([url fileSystemRepresentation]));    
    return result;
}

- (void)addSamplesToClassificationDataForGesture:(NSUInteger)gesture :(MatrixFloat*)vectorData {
    self.classificationData->addSample(gesture, *[vectorData cppInstance]);
}

- (BOOL)trainPipeline {
    *self.trainingData = self.classificationData->split(80);
    BOOL trainSuccess = self.instance->train( *(self.trainingData) );

    std::cout << "STATS " << self.classificationData->getStatsAsString();

    
    GRT::TestResult testResults = self.instance->getTestResults();
    
    std::cout << "Pipeline Test Accuracy: " << self.instance->getTestAccuracy() << std::endl;

    
    GRT::Vector< GRT::UINT > classLabels = self.instance->getClassLabels();

    std::cout << "Precision: ";
    for (GRT::UINT k=0; k<self.instance->getNumClassesInModel(); k++) {
        std::cout << "\t" << self.instance->getTestPrecision(classLabels[k]);
    }std::cout << std::endl;

    return trainSuccess;
}

- (NSUInteger)predictedClassLabel {
    return self.instance->getPredictedClassLabel();
}

- (double)maximumLikelihood {
    return self.instance->getMaximumLikelihood();
}

- (BOOL)predict:(VectorDouble *) inputVector {
    return self.instance->predict(*[inputVector cppInstance]);
}

@end
