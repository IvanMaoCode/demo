//
//  ViewController.m
//  小文件下载2
//
//  Created by Kluth on 2019/8/7.
//  Copyright © 2019 Kluth. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDataDelegate>
//进度大小
@property(nonatomic,assign)NSInteger totalSize;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property(nonatomic,assign)NSInteger currentSize;
//沙河路径
@property(nonatomic,strong)NSString *fullPath;
//文件句柄
@property(nonatomic,strong)NSFileHandle *handle;
@property(nonatomic,strong)NSURLConnection *conect;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (IBAction)startBtnClick:(id)sender {
	//1.确定URL
	NSURL *url = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
	//2.创建请求对象
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	//设置请求头
	NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentSize];
	[request setValue:range forHTTPHeaderField:@"Range"];
	
	self.conect = [[NSURLConnection alloc]initWithRequest:request delegate:self];

}
- (IBAction)cancelBtnClick:(id)sender {
	[self.conect cancel];
}

#pragma mark --NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	
	if(self.currentSize > 0){
		return;
	}
	NSLog(@"didReceiveRespone");
	
	self.totalSize = response.expectedContentLength;
	
	//写到沙盒
	self.fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"123.mp4"];
	//[self.fileData writeToFile:fullPath atomically:YES];
	
	//创建一个r文件
	[[NSFileManager defaultManager] createFileAtPath:self.fullPath contents:nil attributes:nil];
	
	//创建文件句柄(指针)
	self.handle = [NSFileHandle fileHandleForWritingAtPath:self.fullPath];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//NSLog(@"%zd",data.length);
	//移动文件句柄到末尾
	[self.handle seekToEndOfFile];
	//写数据
	[self.handle writeData:data];
	
	//[data writeToFile:self.fullPath atomically:YES];
	self.currentSize += data.length;
	
	NSLog(@"%f",1.0 * self.currentSize / self.totalSize);
	
	self.progressView.progress = 1.0 * self.currentSize/self.totalSize;
	
	
	//NSLog(@"%@",self.fullPath);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"didFailWithError");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSLog(@"%@",self.fullPath);
	NSLog(@"connectionDidFinishLoading");
	//关闭文件句柄
	[self.handle closeFile];
	self.handle = nil;
	
	
	
}

@end
