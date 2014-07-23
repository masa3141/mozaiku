//
//  ViewController.m
//  mozaiku
//
//  Created by mk on 2014/07/21.
//  Copyright (c) 2014年 mk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)resize:(id)sender{
    //画像をリサイズして UIImageに格納
    //CGRectMake(0, 0, 16, 16)は、16×16ピクセルに圧縮するという意味
    UIImage *sampleImage = [Image resize:[Image getUIImageFromResources:@"heart" ext:@"png"]
                                    rect:CGRectMake(0, 0, 16, 16)];
    
    //画像を UIImageViewに格納
    imgView.image = sampleImage;

}
//色確認用ボタン
-(IBAction)check:(id)sender{
    [self checkRGB:imgView.image];
}
- (void)checkRGB:(UIImage *)img
{
    // CGImageを取得する
    CGImageRef  imageRef = img.CGImage;
    
    // データプロバイダを取得する
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    // ビットマップデータを取得する
    CFDataRef dataRef = CGDataProviderCopyData(dataProvider);
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(dataRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    UInt8 *pixelPtr;
    UInt8 r;
    UInt8 g;
    UInt8 b;
    
    // 画像全体を１ピクセルずつ走査する
    for (int checkX = 0; checkX < img.size.width; checkX++) {
        for (int checkY=0; checkY < img.size.height; checkY++) {
            // ピクセルのポインタを取得する
            pixelPtr = buffer + (int)(checkY) * bytesPerRow + (int)(checkX) * 4;
            
            // 色情報を取得する
            r = *(pixelPtr + 2);  // 赤
            g = *(pixelPtr + 1);  // 緑
            b = *(pixelPtr + 0);  // 青
            
            NSLog(@"x:%d y:%d R:%d G:%d B:%d", checkX, checkY, r, g, b);
        }        
    }
    CFRelease(dataRef);
    
}


@end
