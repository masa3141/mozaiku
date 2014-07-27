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
    
    //変数の初期化
    AlAssetsArr = [NSMutableArray array];
    cameraArr = [NSMutableArray array];
    pixelArr = [NSMutableArray array];
    library = [[ALAssetsLibrary alloc] init];
    
    //カメラロールのフォルダ名
    AlbumName = @"Test";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//画像を圧縮する
-(IBAction)resize:(id)sender{
    //画像をリサイズして UIImageに格納
    //CGRectMake(0, 0, 16, 16)は、16×16ピクセルに圧縮するという意味
    imgView.image = [Image resize:imgView.image rect:CGRectMake(0, 0, 30, 30)];
}

//画像を選択する
-(IBAction)select:(id)sender{
    if([UIImagePickerController
        isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *ipc =
        [[UIImagePickerController alloc] init];  // 生成
        ipc.delegate = self;  // デリゲートを自分自身に設定
        ipc.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;  // 画像の取得先をカメラロールに設定
        ipc.allowsEditing = YES;  // 画像取得後編集する
        [self presentViewController:ipc animated:YES completion:nil];
        // モーダルビューとしてカメラ画面を呼び出す
    }

}
//画像が選択された時に呼ばれるデリゲートメソッド
-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    [self dismissModalViewControllerAnimated:YES];  // モーダルビューを閉じる
    imgView.image = image;//選択した画像に差し替える
}

//モザイクアートを作成する
-(IBAction)btnMozaiku:(id)sender{
    //モザイクアートの元画像の各ピクセルの色情報をpixelArrに格納する
    [self pixelRGB:imgView.image];
    //カメラロールから画像を読み取って、色情報を配列に格納して、格納後モザイクアートを作成する
    [self inputCamera];
}

//カメラロールから画像を読み取って、色情報を配列に格納して、格納後モザイクアートを作成する
-(void)inputCamera{
    //カメラロールから画像を取り出す
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               
                               //カメラロール内のすべてのアルバムが列挙される
                               if (group) {
                                   
                                   //アルバム名がTestと同一だった時の処理
                                   if ([AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                       
                                       //Test内の画像を取得する
                                       ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                           
                                           if (result) {
                                               //画像をAlAssetsArrという配列に格納
                                               [AlAssetsArr addObject:result];
                                               
                                               //画像の色情報をcameraArrという配列に格納する
                                               UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                                               UIImage *sampleImage = [Image resize:image
                                                                               rect:CGRectMake(0, 0, 10, 10)];
                                               [cameraArr addObject:[self checkColor:sampleImage]];
                                               
                                           }else{
                                               //画像の格納が終了した時に呼ばれる
                                               //モザイクアートを作成する
                                               [self makeMozaiku];
                                           }
                                           
                                       };
                                       
                                       //アルバム(group)からALAssetの取得
                                       [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                                   }
                               }
                               
                           } failureBlock:nil];
    
    
}

//モザイクアートのアルゴリズム
-(void)makeMozaiku{
    int imageWidth = imgView.image.size.width;//元画像の横のピクセル値
    int imageHeight = imgView.image.size.height;//元画像の縦のピクセル値
    int pixelSize = 320/imgView.image.size.width;//ピクセルの大きさ
    //各ピクセルを類似したカメラロールの画像に置き換える
    for (int i=0; i<imageWidth*imageHeight; i++) {
        float min_value = 999;
        NSLog(@"今=%d/%d",i+1,imageWidth*imageHeight);
        for (int j=0; j<[cameraArr count]; j++) {
            int x,y;
            UIColor *pixelColor = [pixelArr objectAtIndex:i];//ピクセルの色情報
            UIColor *cameraColor = [cameraArr objectAtIndex:j];//カメラロールの画像の色情報
            const CGFloat *pixelComponents = CGColorGetComponents(pixelColor.CGColor);
            const CGFloat *cameraComponents = CGColorGetComponents(cameraColor.CGColor);
            float r1 = pixelComponents[0];//ピクセルの赤
            float g1 = pixelComponents[1];//ピクセルの緑
            float b1 = pixelComponents[2];//ピクセルの青
            float r2 = cameraComponents[0];//カメラロールの赤
            float g2 = cameraComponents[1];//カメラロールの緑
            float b2 = cameraComponents[2];//カメラロールの青
            
            //ピクセルの色とカメラロールの色の差を計算する
            float diff = pow((r1-r2),2.0) + pow((g1-g2),2.0) + pow((b1-b2),2.0);
            //距離は↑ユークリッド距離↑、↓コサイン距離でも可↓
            //float diff = (r1*r2 + g1*g2 + b1*b2 )/ sqrt( r1*r1 + g1*g1 + b1*b1 ) /sqrt(r2*r2 + g2*g2 + b2*b2 );
            //画像を差し替える
            if (diff < min_value) {
                min_value = diff;
                //タイル上に並べるためのx、yの計算
                x = ((i / imageHeight) * pixelSize) ;
                y = ((i % imageWidth) * pixelSize) ;
                //NSLog(@"i=%d,x=%d,y=%d,diff=%f",i,x,y,diff);
                //ALAssetからサムネール画像を取得してUIImageに変換
                UIImage *image = [UIImage imageWithCGImage:[[AlAssetsArr objectAtIndex:j] thumbnail]];
                //表示させるためにUIImageViewを作成
                UIImageView *imageView = [[UIImageView alloc] init];
                //UIImageViewのサイズと位置を設定
                imageView.frame = CGRectMake(x,y,pixelSize,pixelSize);
                imageView.image = image;
                //画面に貼り付ける
                [self.view addSubview:imageView];
            }
        }
        
    }

}

//画像の各ピクセル値を格納する
- (void)pixelRGB:(UIImage *)img
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
            
            //NSLog(@"x:%d y:%d R:%d G:%d B:%d", checkX, checkY, r, g, b);
            //ピクセルの色情報を配列に格納する
            UIColor *color = [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1];
            [pixelArr addObject:color];

        }
    }
    CFRelease(dataRef);
    
}


//画像の平均RGB値を返す
- (UIColor *)checkColor:(UIImage *)img{
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
    
    int red =0 ;
    int green = 0;
    int blue = 0;
    
    // 画像全体を１ピクセルずつ走査する
    for (int checkX = 0; checkX < img.size.width; checkX++) {
        for (int checkY=0; checkY < img.size.height; checkY++) {
            // ピクセルのポインタを取得する
            pixelPtr = buffer + (int)(checkY) * bytesPerRow + (int)(checkX) * 4;
            
            // 色情報を取得する
            r = *(pixelPtr + 2);  // 赤
            g = *(pixelPtr + 1);  // 緑
            b = *(pixelPtr + 0);  // 青
            red += r;
            green += g;
            blue += b;
         }
    }
    CFRelease(dataRef);
    
    int num = img.size.width * img.size.height;
    //NSLog(@"color red=%f green=%f blue=%f",(float)red/255.0/num,(float)green/255.0/num,(float)blue/255.0/num);
    //画像の平均RGBを返す
    UIColor *averageColor = [UIColor colorWithRed:(float)red/255.0/num green:(float)green/255.0/num blue:(float)blue/255.0/num alpha:1];
    return averageColor;
}


@end
