//
//  ViewController.m
//  Echat_AES_Demo
//
//  Created by xll on 2018/4/20.
//  Copyright © 2018年 xielang. All rights reserved.
//


#import "ViewController.h"
#import "NSDictionary+Echat_dic2xml.h"
#import "AESCrypt.h"

@interface ViewController (){
    NSDictionary * _testdict;
}

@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UITextField *appId;
@property (weak, nonatomic) IBOutlet UITextField *encodingAesKey;
@property (weak, nonatomic) IBOutlet UITextView *AES;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

/********************************************前言********************************************
 
 1 .完全参照Java后端写法 先进行 PKCS#7 补全  然后采用java   AES/CBC/NoPadding  加密  再进行base64
 2 .AesKey 与 偏移向量相同
 3 .以字节流形式传输
 4 .只提供加密如要验证请前往http://wiki.echatsoft.com/api/echat_aes/?TypeStatus=des验证
 */


static int BLOCK_SIZE = 32;
//--newByte 传入 contentString字节长度
- (NSData *)Echat_netBytesTransferFor32Bit:(UInt32)origin {
    Byte blockIndexArray[4];
    blockIndexArray[0] = (Byte)(origin >> 24) & 0xFF;
    blockIndexArray[1] = (Byte)(origin >> 16) & 0xFF;
    blockIndexArray[2] = (Byte)(origin >> 8) & 0xFF;
    blockIndexArray[3] = (Byte)(origin & 0xFF);
    return [NSData dataWithBytes:blockIndexArray length:sizeof(blockIndexArray)];
}

//--补
static NSData * chr(int a){
    Byte target[1];
    target[0] = (Byte)(a & 0xFF);
    return [NSData dataWithBytes:target length:sizeof(target)];
}

//PKCS#7补码(参照)
-(NSData * )PKCS7Encode:(int)count{
    int amount2Pad = BLOCK_SIZE - (count % BLOCK_SIZE);
    if (amount2Pad == 0) {
        amount2Pad = BLOCK_SIZE;
    }
    NSMutableData * dataM = [NSMutableData data];
    NSData * data = chr(amount2Pad);
    for (int i = 0;i<amount2Pad; i++) {
        [dataM appendData:data];
    }
    return dataM.copy;
}

//*******************************************************************************************



/*
 *           点击
 */
- (IBAction)Click2encrypt:(UIButton *)sender {
    NSString * secret = [self EchatEncryptWithContent:self.content.text andEncodingAesKey:self.encodingAesKey.text];
  [self.AES setText:secret];
    
    NSLog(@"AES密文----[%@]",secret); //别复制括号哦～～～～～～
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化参数//
    [self.encodingAesKey setText:@"p6vO6IZQM6VAaVCV3swPgDbq8F68cQMZwQ5tjrYNKZ7"];
    [self.appId setText:@"A87FF679A2F3E71D9181A67B7542122C"];
    
    //字典转XML  样板//
    _testdict = @{@"uid":@"wbq1981",@"name":@"王宝强"};
    [self.content setText:[_testdict Echat_trans2XMLString]];

    
    {//监控textfield
    [self.appId addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventValueChanged];
    [self.encodingAesKey addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventValueChanged];
    }
   
    // Do any additional setup after loading the view, typically from a nib.
}

/*
 *           监听
 */
-(void)textChanged:(UITextField * )textFiled{
    self.btn.enabled = self.content.text.length && self.appId.text.length &&self.encodingAesKey.text.length;
}


-(NSString *)EchatEncryptWithContent:(NSString * )content andEncodingAesKey:(NSString * )encodingAesKey{
    //创建一个容器//
    NSMutableData * dataTube = [NSMutableData data];
    
    //random(16)//
    NSData * randomData = [[self Echat_return16LetterAndNumber] dataUsingEncoding:NSUTF8StringEncoding];
    
    //conteData//
    NSData * contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    //netWorkBtyesData//
    NSData * netByteData = [self Echat_netBytesTransferFor32Bit:(unsigned int)[contentData length]];
    
    //appIdData//
    NSData * appIdData = [self.appId.text dataUsingEncoding:NSUTF8StringEncoding];
    
    //组合---次序很重要//
    [dataTube appendData:randomData];
    [dataTube appendData:netByteData];
    [dataTube appendData:contentData];
    [dataTube appendData:appIdData];
    
    //进行PKCS#7补码
    NSData * supplyData = [self PKCS7Encode:(int)dataTube.length];
    [dataTube appendData:supplyData];
    
    //aesKey
    NSString * encodeString = [NSString stringWithFormat:@"%@=",self.encodingAesKey.text];
    NSData * aesKey2 = [[NSData alloc]initWithBase64EncodedString:encodeString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    //加密
    return [AESCrypt encrypt:dataTube.copy password:aesKey2];
}


/*
 *           random(16)
 */
-(NSString *)Echat_return16LetterAndNumber{
    //池//
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    //初始化//
    NSString * result = [[NSMutableString alloc]initWithCapacity:16];
    for (int i = 0; i < 16; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    
    return result;
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
