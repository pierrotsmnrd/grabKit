/*
 * ASyncURLConnection, 
 * based on http://stackoverflow.com/questions/5037545/nsurlconnection-and-grand-central-dispatch
 *
 *
 *  2012 Pierre-Olivier Simonard <pierre.olivier.simonard@gmail.com>
 *   
*/

#import "AsyncURLConnection.h"

@implementation AsyncURLConnection

#pragma mark Constructors

+ (id)connectionWithString:(NSString *)requestUrl responseBlock:(responseBlock_t)responseBlock progressBlock:(progressBlock_t)progressBlock completeBlock:(completeBlock_t)completeBlock errorBlock:(errorBlock_t)errorBlock;
{
	return [[self alloc] initWithString:requestUrl
						   responseBlock:responseBlock
						   progressBlock:progressBlock
						   completeBlock:completeBlock 
							  errorBlock:errorBlock];
}

- (id)initWithString:(NSString *)requestUrl 
	   responseBlock:(responseBlock_t)responseBlock 
	   progressBlock:(progressBlock_t)progressBlock 
	   completeBlock:(completeBlock_t)completeBlock 
		  errorBlock:(errorBlock_t)errorBlock;
{
    NSURL *url = [NSURL URLWithString:requestUrl];
    
    return [self initWithURLRequest:[NSURLRequest requestWithURL:url] 
                      responseBlock:responseBlock 
                      progressBlock:progressBlock 
                        uploadBlock:nil
                      completeBlock:completeBlock 
                         errorBlock:errorBlock];
}

+ (id)connectionWithURLRequest:(NSURLRequest *)requestUrl 
                 responseBlock:(responseBlock_t)responseBlock 
                 progressBlock:(progressBlock_t)progressBlock
                   uploadBlock:(uploadBlock_t)uploadBlock
                 completeBlock:(completeBlock_t)completeBlock 
                    errorBlock:(errorBlock_t)errorBlock;
{
    
    return [[self alloc] initWithURLRequest:requestUrl 
						   responseBlock:responseBlock
						   progressBlock:progressBlock
                             uploadBlock:(uploadBlock_t)uploadBlock
						   completeBlock:completeBlock 
							  errorBlock:errorBlock];
}

- (id)initWithURLRequest:(NSURLRequest *)requestUrl 
		responseBlock:(responseBlock_t)responseBlock 
		progressBlock:(progressBlock_t)progressBlock
		  uploadBlock:(uploadBlock_t)uploadBlock
		completeBlock:(completeBlock_t)completeBlock 
		   errorBlock:(errorBlock_t)errorBlock;
{

	request_ = requestUrl;
	if ((self = [super initWithRequest:request_ delegate:self startImmediately:NO])) {
        
		data_ = [[NSMutableData alloc] init];

        responseBlock_ = responseBlock;
		progressBlock_ = progressBlock ;
		uploadBlock_ = uploadBlock ;
		completeBlock_ = completeBlock;
		errorBlock_ = errorBlock;
		
	}

	return self;
	
}


-(void) cancel {
    
    data_ = nil;
    responseBlock_ = nil;
    progressBlock_ = nil;
    uploadBlock_   = nil;
    completeBlock_ = nil;
    errorBlock_    = nil;
    
    [super cancel];
    
}


#pragma mark - Delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
	if ( responseBlock_ != nil ){
		responseBlock_(response);
	}
	
	fileSize_ = [response expectedContentLength];
	
	[data_ setLength:0];
	startDate_=[NSDate date];

}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
	if ( uploadBlock_ != nil ){
		uploadBlock_(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[data_ appendData:data];
	if( progressBlock_ != nil ) {
		progressBlock_(data_, startDate_, fileSize_);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	/* 
     Specific fix for Amazon S3 : when the file you want to download is missing, Amazon S3 doesn't send an 404 HTTP header, 
     it sends an XML error file. 
     The following code detects if the markup <Error> exists in the string representation of the data, and calls the errorBlock if needed
	*/ 
	if ( [data_ length] < 300 ) {
		
		NSString * content = [[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding] ;
		NSRange r = [content rangeOfString:@"<Error>"];
		
		if ( content != nil && r.location != NSNotFound ){
			NSError * error = [NSError errorWithDomain:@"Error. check file presence on the server" code:0 userInfo:nil];
			errorBlock_(error);	
			return;
		}
		
	}
    
    if ( completeBlock_ != nil ){
        completeBlock_(data_);
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ( errorBlock_ != nil ){
        errorBlock_(error);
    }
}

@end