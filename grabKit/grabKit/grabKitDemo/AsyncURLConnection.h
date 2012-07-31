/*
 * AsyncURLConnection, 
 * based on http://stackoverflow.com/questions/5037545/nsurlconnection-and-grand-central-dispatch
 *
 *  2012 Pierre-Olivier Simonard <pierre.olivier.simonard@gmail.com>
 *   
*/

#import <Foundation/Foundation.h>

typedef void (^completeBlock_t)(NSData *data);
typedef void (^errorBlock_t)(NSError *error);
typedef void (^responseBlock_t)(NSURLResponse *response);
typedef void (^progressBlock_t)(NSData *data, NSDate *startDate, NSUInteger totalSize);
typedef void (^uploadBlock_t)(NSInteger writen, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);



@interface AsyncURLConnection : NSURLConnection
{
	NSMutableData *data_;
	
	responseBlock_t responseBlock_;
	progressBlock_t progressBlock_;
    uploadBlock_t uploadBlock_;
	completeBlock_t completeBlock_;
	errorBlock_t errorBlock_;
	
	NSUInteger fileSize_;
	NSDate *startDate_;
	NSURLRequest * request_;
}


+ (id)connectionWithString: (NSString *)URLstr
		  responseBlock: (responseBlock_t)responseBlock 
		  progressBlock: (progressBlock_t)progressBlock
		  completeBlock: (completeBlock_t)completeBlock 
			 errorBlock: (errorBlock_t)errorBlock;

- (id)initWithString:(NSString *)URLStr 
	   responseBlock:(responseBlock_t)responseBlock
	   progressBlock:(progressBlock_t)progressBlock 
	   completeBlock:(completeBlock_t)completeBlock
		  errorBlock:(errorBlock_t)errorBlock;



+ (id)connectionWithURLRequest:(NSURLRequest *)URLRequest 
                 responseBlock:(responseBlock_t)responseBlock 
                 progressBlock:(progressBlock_t)progressBlock
                   uploadBlock:(uploadBlock_t)uploadBlock
                 completeBlock:(completeBlock_t)completeBlock 
                    errorBlock:(errorBlock_t)errorBlock;

- (id)initWithURLRequest:(NSURLRequest *)URLRequest 
           responseBlock:(responseBlock_t)responseBlock 
           progressBlock:(progressBlock_t)progressBlock 
             uploadBlock:(uploadBlock_t)uploadBlock
           completeBlock:(completeBlock_t)completeBlock 
              errorBlock:(errorBlock_t)errorBlock;




@end