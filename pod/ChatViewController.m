//
//  ChatViewController.m
//  pod
//
//  Created by 高山峰 on 2017/5/12.
//  Copyright © 2017年 高山峰. All rights reserved.
//

#import "ChatViewController.h"
#import <SocketRocket/SRWebSocket.h>
@interface ChatViewController ()<SRWebSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messigeTF;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
- (IBAction)didSendBtn:(id)sender;

@property (nonatomic, strong) SRWebSocket *webSocket;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webSocket.delegate = nil;
    
    [self.webSocket close];
    
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]]];
    self.webSocket.delegate = self;
    NSLog(@"Opening Connection...");
    [self.webSocket open];
}
#pragma mark - SRWebSocketDelegate
 //成功连接
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;{
    
    NSLog(@"Websocket Connected");
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"id":@"chat",@"clientid":@"hxz",@"to":@""} options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [webSocket send:jsonString];
}


//连接失败，打印错误信息
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;{
    
    NSLog(@":( Websocket Failed With Error %@", error);
    
    webSocket = nil;
    
}


//接收服务器发送的消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;{
    
    NSLog(@"Received \"%@\"", message);
    
}


// 长连接关闭
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;{
    
    NSLog(@"WebSocket closed");
    
    webSocket = nil;
    
}
//该函数是接收服务器发送的pong消息
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"%@",reply);
}
/*
    其中最后一个是接受pong消息的，在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的，例如
    NSData * data = [[NSData alloc]init];
    [_webSocket sendPing:data];
    发送过去消息以后，服务器会返回一个pong消息，这个消息是解读不了的，但是每次返回时就会调用-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload这个函数，如果要用到话，可以像我做的那样，直接在该函数里面统计一下收到的次数，跟发送的次数比较，如果每次发送之前，自己发送的ping消息的个数，跟收到pong消息的个数相同，那就代表一直在连接状态，但是服务器发送pong消息时候是自动发送的，服务器是看不到客户端发送的ping消息的，同理，服务端也一样，只要服务端建立有心跳连接，那么服务端也是一直在发送ping消息，客户端一直在回复pong消息，这两个消息是处理不了的，没办法解读这个歌消息体里面的内容。还有一点就是在发送ping消息的时候，如果非要想在里面加入一些参数，这个参数不能太大，太大的话，会提示发送失败
 */
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)didSendBtn:(id)sender {
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"id":@"chat",@"clientid":@"hxz",@"to":@"mary",@"msg":@{@"type":@"0",@"content":self.messigeTF.text}} options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self.webSocket send:jsonString];

}
@end
