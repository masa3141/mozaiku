//
//  ViewController.h
//  mozaiku
//
//  Created by mk on 2014/07/21.
//  Copyright (c) 2014年 mk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    IBOutlet UIImageView *imgView;//モザイクアートの元の画像
    ALAssetsLibrary *library;//カメラロールから画像を取得する
    NSURL *groupURL;
    NSString *AlbumName;//カメラロールの、どのフォルダから取得するか
    NSMutableArray *AlAssetsArr;//カメラロールの画像の配列
    NSMutableArray *cameraArr;//カメラロールの画像の色情報の配列
    NSMutableArray *pixelArr;//モザイクアートの元画像の、各ピクセルの色情報の配列
}

-(IBAction)resize:(id)sender;//画像圧縮
-(IBAction)select:(id)sender;//画像選択
-(IBAction)btnMozaiku:(id)sender;//モザイクアート

@end
