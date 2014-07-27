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

-(IBAction)resize:(id)sender{
    //画像をリサイズして UIImageに格納
    //CGRectMake(0, 0, 16, 16)は、16×16ピクセルに圧縮するという意味
    /*
    UIImage *sampleImage = [Image resize:[Image getUIImageFromResources:@"heart" ext:@"png"]
                                    rect:CGRectMake(0, 0, 30, 30)];*/
    
    imgView.image = [Image resize:imgView.image rect:CGRectMake(0, 0, 30, 30)];
    //画像を UIImageViewに格納
    //imgView.image = sampleImage;

}

-(IBAction)select:(id)sender{
    if([UIImagePickerController
        isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *ipc =
        [[UIImagePickerController alloc] init];  // 生成
        ipc.delegate = self;  // デリゲートを自分自身に設定
        ipc.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;  // 画像の取得先をカメラに設定
        ipc.allowsEditing = YES;  // 画像取得後編集する
        [self presentViewController:ipc animated:YES completion:nil];
        // モーダルビューとしてカメラ画面を呼び出す
    }

}
//画像が選択された時に呼ばれるデリゲートメソッド
-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    
    [self dismissModalViewControllerAnimated:YES];  // モーダルビューを閉じる
    imgView.image = image;
}

//色確認用ボタン
-(IBAction)check:(id)sender{
    [self checkRGB:imgView.image];
    //UIColor *color = [UIColor redColor];
    //const CGFloat *components = CGColorGetComponents(color.CGColor);
    //NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];


    //AlAssetsLibraryからALAssetGroupを検索
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                            usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                
                                //ALAssetsLibraryのすべてのアルバムが列挙される
                                if (group) {
                                    
                                    //アルバム名が「AlbumName」と同一だった時の処理
                                    if ([AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                        
                                        //assetsEnumerationBlock
                                        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                            
                                            if (result) {
                                                //asset をNSMutableArraryに格納
                                                [AlAssetsArr addObject:result];
                                                
                                            }else{
                                                //NSMutableArraryに格納後の処理
                                                for (int i=0; i<[AlAssetsArr count]; i++) {
                                                    int x,y;
                                                    
                                                    //タイル上に並べるためのx、yの計算
                                                    x = ((i % 5) * 50) + 10;
                                                    y = ((i / 5) * 50) + 10;
                                                    
                                                    //ALAssetからサムネール画像を取得してUIImageに変換
                                                    UIImage *image = [UIImage imageWithCGImage:[[AlAssetsArr objectAtIndex:i] thumbnail]];
                                                    
                                                    //表示させるためにUIImageViewを作成
                                                    UIImageView *imageView = [[UIImageView alloc] init];
                                                    
                                                    //UIImageViewのサイズと位置を設定
                                                    imageView.frame = CGRectMake(x,y,50,50);
                                                    UIImage *sampleImage = [Image resize:image
                                                                                    rect:CGRectMake(0, 0, 10, 10)];
                                                    //ViewにaddSubView
                                                    //imageView.image = sampleImage;
                                                    //imageView.backgroundColor = [self checkColor:sampleImage];
                                                    [self.view addSubview:imageView];
                                                    [cameraArr addObject:[self checkColor:sampleImage]];
                                                }
                                                [self makeMozaiku];
                                            }
                                            
                                        };
                                        
                                        //アルバム(group)からALAssetの取得
                                        [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                                    }
                                }
                                
                            } failureBlock:nil];

    
}

-(void)makeMozaiku{
    int imageWidth = imgView.image.size.width;
    int imageHeight = imgView.image.size.height;
    int pixelSize = 320/imgView.image.size.width;
    for (int i=0; i<imgView.image.size.width*imgView.image.size.height; i++) {
        float min_value = 999;
        //float max_value = 0;
        NSLog(@"今=%d/256",i);
        for (int j=0; j<[cameraArr count]; j++) {
            int x,y;
            UIColor *pixelColor = [pixelArr objectAtIndex:i];
            UIColor *cameraColor = [cameraArr objectAtIndex:j];
            const CGFloat *pixelComponents = CGColorGetComponents(pixelColor.CGColor);
            const CGFloat *cameraComponents = CGColorGetComponents(cameraColor.CGColor);
            float r1 = pixelComponents[0];
            float g1 = pixelComponents[1];
            float b1 = pixelComponents[2];
            float r2 = cameraComponents[0];
            float g2 = cameraComponents[1];
            float b2 = cameraComponents[2];
            
            //float diff = fabs(r1-r2) + fabs(g1-g2) + fabs(b1-b2);
            float diff = pow((r1-r2),2.0) + pow((g1-g2),2.0) + pow((b1-b2),2.0);
            //float diff = (r1*r2 + g1*g2 + b1*b2 )/ sqrt( r1*r1 + g1*g1 + b1*b1 ) /sqrt(r2*r2 + g2*g2 + b2*b2 );
            //NSLog(@"%f,%f,%f",r1,g1,b1);
            //NSLog(@"%f,%f,%f",r2,g2,b2);
            //NSLog(@"%f,%f,%f",r1-r2,g1-g2,b1-b2);
            //NSLog(@"%f,%f,%f",fabs(r1-r2),fabs(g1-g2),fabs(b1-b2));
            
            //NSLog(@"%f,%f,%f",sqrt([arr1[0] floatValue]- [arr2[0] floatValue]) ,sqrt([arr1[1] floatValue]- [arr2[1] floatValue]) ,sqrt([arr1[2] floatValue]- [arr2[2] floatValue]));
            //NSLog(@"%f",[arr1[0] floatValue]);
            //NSLog(@"%f",[arr2[0] floatValue]);
            //NSLog(@"%f",[arr2[0] floatValue]-[arr2[0] floatValue]);
            //NSLog(@"%f",r1-r2);
            
            //NSLog(@"%f",sqrt([arr2[0] floatValue]-[arr2[0] floatValue]));
            
            //NSLog(@"arr1=%@,arr2=%@",arr1,arr2);
            //NSLog(@"i=%d,diff=%f",i,diff);
             if (diff < min_value) {
            //if (diff > max_value) {
                //max_value = diff;
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
                /*
                 UIImage *sampleImage = [Image resize:image
                 rect:CGRectMake(0, 0, 10, 10)];
                 */
                //imageView.backgroundColor = [self checkColor:sampleImage];
                imageView.image = image;
                
                //ViewにaddSubView
                [self.view addSubview:imageView];
            }
        }
        
    }

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
            UIColor *color = [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1];
            [pixelArr addObject:color];

        }
    }
    CFRelease(dataRef);
    
}



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
    NSLog(@"color red=%f green=%f blue=%f",(float)red/255.0/num,(float)green/255.0/num,(float)blue/255.0/num);
    UIColor *averageColor = [UIColor colorWithRed:(float)red/255.0/num green:(float)green/255.0/num blue:(float)blue/255.0/num alpha:1];
    return averageColor;
}


@end
