//
//  ViewController.swift
//  TenPuzzleGameDemo3
//
//  Created by Masaki Horimoto on 2015/06/01.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit

//自分がいるlocation#を記憶できるクラス (UIImageViewを継承)
class LocationImageView: UIImageView {
    var location: Int! = -1
    var slideLocation: Int! = -1
    
}

//valueを記憶できるクラス (LocationImageViewを継承)
class ValueImageView: LocationImageView {
    var value: Int! = 0
}

//演算子を記憶できるクラス (LocationImageViewを継承)
class OperatorImageView: LocationImageView {
    var operatorName: String! = ""
}

//二つのCGPointを持つクラス (イメージ移動の座標管理)
class TwoCGPoint {
    var imagePoint: CGPoint!    //イメージの座標保存用
    var touchPoint: CGPoint!    //タッチ位置の座標保存用
}

//タッチスタート時と移動後の座標情報を持つクラス (イメージ移動の座標管理)
class ControlImageClass {
    var start: TwoCGPoint = TwoCGPoint()            //スタート時の画像座標とタッチ座標
    var destination: TwoCGPoint = TwoCGPoint()      //移動後(または移動途中の)画像座標とタッチ座標
    var draggingView: UIView?                       //どの画像を移動しているかを保存
    
    //startとdestinationからタッチ中の移動量を計算
    var delta: CGPoint {
        get {
            let deltaX: CGFloat = destination.touchPoint.x - start.touchPoint.x
            let deltaY: CGFloat = destination.touchPoint.y - start.touchPoint.y
            return CGPointMake(deltaX, deltaY)
        }
    }
    
    //移動後(または移動中の)画像の座標取得用のメソッド
    func setMovedImagePoint() -> CGPoint {
        let imagePointX: CGFloat = start.imagePoint.x + delta.x
        let imagePointY: CGFloat = start.imagePoint.y + delta.y
        destination.imagePoint = CGPointMake(imagePointX, imagePointY)
        return destination.imagePoint
    }
}

//各locationとの距離を管理するクラス
class distanceClass {
    var distanceArray: [CGFloat] = []
    var minIndex: Int!
}

//各viewArray.centerとviewとの距離とその最小値のIndexを保存するメソッド
func getDistanceWithImageWithView(view :UIView, viewArray :[UIView]) -> distanceClass {
    let distance: distanceClass = distanceClass()
    
    distance.distanceArray = viewArray.map({getDistanceWithPoint1(view.center, $0.center)})
    let (index, val) = reduce(enumerate(distance.distanceArray), (-1, CGFloat(FLT_MAX))) {
        $0.1 < $1.1 ? $0 : $1
    }
    distance.minIndex = index
    
    return distance
}

//2点の座標間の距離を取得するメソッド
func getDistanceWithPoint1(point1: CGPoint, point2: CGPoint) -> CGFloat {
    let distanceX = point1.x - point2.x
    let distanceY = point1.y - point2.y
    let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
    return distance
}




class ViewController: UIViewController {

    //問題の数値(4桁)
    @IBOutlet var valueViewArray: [ValueImageView]!

    //解答に使用する演算子(常に表示用)
    @IBOutlet var operatorViewArray: [OperatorImageView]!       //+,-,×,÷を表示
    @IBOutlet var kakkoViewArray: [OperatorImageView]!          //(,)を表示

    //解答に使用する演算子(移動用)
    @IBOutlet var operatorCopyViewArray: [OperatorImageView]!   //+,-,×,÷を表示
    @IBOutlet var kakkoCopyViewArray: [OperatorImageView]!      //(,)を表示

    //計算に使用する演算子
    @IBOutlet var calcOperatorViewArray: [OperatorImageView]!   //+,-,×,÷を表示 (3個)
    @IBOutlet var calcKakkoViewArray: [OperatorImageView]!      //(,)を表示 (6個)

    //数値を移動可能な場所を示すView(8個)
    @IBOutlet var destinationViewArray: [UIView]!
    
    //演算子を移動可能な場所を示すView(3個)
    @IBOutlet var destinationOperatorViewArray: [UIView]!


    //計算結果を表示
    @IBOutlet weak var result: UILabel!

    //移動画像管理用変数
    var pointImage: ControlImageClass! = ControlImageClass()
    
    
    let fixOperatorArray: [String] = ["+", "-", "×", "÷", "(", ")"]
    var questionValue: [Int] = [1, 1, 3, 4]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //四則演算子と()を表示するViewに情報を追加
        for (index, val) in enumerate(fixOperatorArray) {
            
            if index < 4 {
                operatorViewArray[index].operatorName = fixOperatorArray[index]
                operatorCopyViewArray[index].operatorName = fixOperatorArray[index]
                operatorCopyViewArray[index].userInteractionEnabled = true
                
            } else {
                kakkoViewArray[index - 4].operatorName = fixOperatorArray[index]
                kakkoCopyViewArray[index - 4].operatorName = fixOperatorArray[index]
                kakkoCopyViewArray[index - 4].userInteractionEnabled = true
            }
        }
        
        //問題の数値を表示するViewに情報を追加
        for (index, val) in enumerate(questionValue) {
            valueViewArray[index].value = questionValue[index]
            valueViewArray[index].location = index
            valueViewArray[index].userInteractionEnabled = true
        }
        
        //計算用の演算子 +,-,×,÷ を表示するViewに情報を追加
        for (index, val) in enumerate(calcOperatorViewArray) {
            calcOperatorViewArray[index].location = index
        }
        
        //計算用の演算子 (,) を表示するViewに情報を追加
        for (index, val) in enumerate(calcKakkoViewArray) {
            calcKakkoViewArray[index].location = index
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("\(__FUNCTION__) is called")
        
        for i in 0...7 {
            
            //最適な画像ファイルを表示
            switch i {
            case 0, 1:
                kakkoViewArray[i].image = UIImage(named: kakkoViewArray[i].operatorName + ".png")
                kakkoCopyViewArray[i].image = UIImage(named: kakkoCopyViewArray[i].operatorName + ".png")
                fallthrough
            case 2:
                calcOperatorViewArray[i].image = UIImage(named: calcOperatorViewArray[i].operatorName + ".png")
                fallthrough
            case 3:
                valueViewArray[i].image = UIImage(named: "\(valueViewArray[i].value).png")
                operatorViewArray[i].image = UIImage(named: operatorViewArray[i].operatorName + ".png")
                operatorCopyViewArray[i].image = UIImage(named: operatorCopyViewArray[i].operatorName + ".png")
                fallthrough
            default:
                calcKakkoViewArray[i].image = UIImage(named: "transparent_" + calcKakkoViewArray[i].operatorName + ".png")
                self.view.bringSubviewToFront(calcKakkoViewArray[i])                       //(,)を最前面に
                break
            }
            
            for (index, val) in enumerate(valueViewArray) {
                let location = valueViewArray[index].location!
                var point: CGPoint?
                point = destinationViewArray[location].center
                valueViewArray[index].center = point!
            }
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        //タッチスタート時の座標情報 and Otherを保存する
        if touch.view is ValueImageView {
            saveTouchStartInfoWithTouch(touch, pointImage: pointImage, shadowOpacity: 0.8, opacity: 0.5)
            animationSizeWithImageView(touch.view, duration: 0.10)          //拡大縮小アニメーション
            
        } else if touch.view is OperatorImageView {
            saveTouchStartInfoWithTouch(touch, pointImage: pointImage, shadowOpacity: 0.8, opacity: 0.5)
            animationSizeWithImageView(touch.view, duration: 0.10)          //拡大縮小アニメーション
            
        } else {
            //Do nothing
        }
    }

    //タッチスタート時の情報保存関数
    func saveTouchStartInfoWithTouch(touch: UITouch, pointImage: ControlImageClass, shadowOpacity: Float, opacity: Float) {
        pointImage.start.imagePoint = touch.view.center                 //タッチ時の情報登録1
        pointImage.start.touchPoint = touch.locationInView(self.view)   //タッチ時の情報登録2
        pointImage.draggingView = touch.view                            //現在操作中のviewを登録
        self.view.bringSubviewToFront(touch.view)                       //タッチしたviewを最前面に
        touch.view.layer.shadowOpacity = shadowOpacity                  //タッチしたviewに影を付加
        touch.view.layer.opacity = opacity                              //タッチしたViewを半透明化
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        //移動後(または移動中)の座標情報を保存し、それらの情報から画像の表示位置を変更する
        //タッチされたviewとpointに保存されたviewと等しい時のみ画像を動かす
        if touch.view == pointImage.draggingView {
            let tmpImageView = touch.view as! LocationImageView
            var distance: distanceClass = distanceClass()                               //locationとの距離を管理する変数
            distance = getDistanceWithImageWithView(touch.view, destinationViewArray)   //各locationの距離と最小値のindexを保存
            
            pointImage.destination.touchPoint = touch.locationInView(self.view)
            touch.view.center = pointImage.setMovedImagePoint()                         //移動後の座標を取得するメソッドを使って画像の表示位置を変更

            //(ValueImageViewのみの処理)最も近いdestinationに既にImageViewが存在する時、既存のViewの方をvalueViewArray上段へスライド
            if touch.view is ValueImageView {
                slideWithDistance(distance, imageView: tmpImageView, imageViewArray: valueViewArray)
                
            } //else   //touch.view is OperatorImageView
            
        } else {
            //Do nothing
        }
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        
        if touch.view == pointImage.draggingView {
            
            var distance: distanceClass = distanceClass()   //locationとの距離を管理する変数
            
            if touch.view is ValueImageView  {
                let tmpImageView = touch.view as! ValueImageView
                
                //各locationの距離と最小値のindexを保存
                distance = getDistanceWithImageWithView(touch.view, destinationViewArray)
                
                //最も近いdestinationに移動  or  元の位置へ
                moveImageWithDistance(distance, imageView: tmpImageView, imageViewArray: valueViewArray)
                
            } else  {   //touch.view is OperatorImageView
                
                let tmpImageView = touch.view as! OperatorImageView
                
                if tmpImageView.operatorName > ")" {    //+,-,×,÷時の処理
                    distance = getDistanceWithImageWithView(touch.view, destinationOperatorViewArray)  //各locationの距離と最小値のindexを保存
                    castImageWithDistance(distance, imageView: tmpImageView, imageViewArray: calcOperatorViewArray)
                    
                } else {    //(,)時の処理
                    distance = getDistanceWithImageWithView(touch.view, destinationViewArray)  //各locationの距離と最小値のindexを保存
                    castKakkoImageWithDistance(distance, imageView: tmpImageView, imageViewArray: calcKakkoViewArray)
                    
                }

            }
            
        } else {
            //Do nothing
        }
    }
    
    //特定条件でViewをvalueViewArray上段へスライドするメソッド
    func slideWithDistance(distance: distanceClass, imageView: LocationImageView, imageViewArray: [LocationImageView]) {

        //判定1: 移動させるか元の位置に戻すか
        let isMove = judgeMoveWithDistance(distance, imageView: imageView, imageViewArray: imageViewArray)

        //判定2: Value画像の移動先に既にValue画像がありスライドする必要があるか
        let (isSlide, minImageIndex) = judgeSlideWithDistance(distance, imageView: imageView, imageViewArray: imageViewArray)
        
        if isMove && isSlide {
            
            //Valueない最小のlocationへスライド & そのlocationを保存
            imageViewArray[minImageIndex].slideLocation
                = slideWithSlideView(imageViewArray[minImageIndex], imageView: imageView, imageViewArray: imageViewArray)
            
        } else {
            
            //条件を満たさない(満たさなくなった)時、スライドしていたviewを元のlocationに戻す
            let (index, val) = reduce(enumerate(imageViewArray), (-1, -1), {$1.1.slideLocation > -1 ? ($1.0, $1.1.slideLocation) : ($0.0, $0.1)})
            
            if index != -1 {
                
                let point = destinationViewArray[imageViewArray[index].location].center             //移動pointはスライド前のlocation
                animationLocateWithImageView(imageViewArray[index], point: point, duration: 0.2)    //指定位置までアニメーション
                
                imageViewArray[index].layer.shadowOpacity = 0.0
                imageViewArray[index].slideLocation = -1
                
            }
            
        }
        
    }
    
    
    //最も近いdestinationに移動 or 元の位置へ  (ValueImageView用)
    func moveImageWithDistance(distance: distanceClass, imageView: LocationImageView, imageViewArray: [LocationImageView]) {
        
        //判定1: Value画像を移動させるか元の位置に戻すか
        let isMove = judgeMoveWithDistance(distance, imageView: imageView, imageViewArray: imageViewArray)
        
        //判定2: Value画像を計算エリアから解除するか
        let isNotCalc = judgeCalcWithDistance(distance, imageView: imageView, imageViewArray: imageViewArray)

        //判定3: Value画像の移動先に既にValue画像がありスライドする必要があるか
        let (wasSlide, minImageIndex) = judgeSlideWithDistance(distance, imageView: imageView, imageViewArray: imageViewArray)
        
        //isMoveがtrueの時には最も近いdestinationに移動し、falseの時には元の位置へ
        if isMove {
            let point = destinationViewArray[distance.minIndex].center
            imageView.layer.shadowOpacity = 0.0
            imageView.location = distance.minIndex
            animationLocateWithImageView(imageView, point: point, duration: 0.2)    //指定位置までアニメーション
            
            //スライド中のviewはそのlocationに確定させる
            if wasSlide {
                imageViewArray[minImageIndex].location = imageViewArray[minImageIndex].slideLocation
                imageViewArray[minImageIndex].slideLocation = -1
                imageViewArray[minImageIndex].layer.shadowOpacity = 0.0
            }
            
        } else if isNotCalc {
            
            //Valueない最小のlocationへスライド & そのlocationを保存
            imageView.location = slideWithSlideView(imageView, imageView: imageView, imageViewArray: imageViewArray)
            imageView.layer.shadowOpacity = 0.0     //位置が確定 -> 影を消す
            
        } else {
            
            let point = pointImage.start.imagePoint                                 //移動pointは移動開始時の座標
            animationLocateWithImageView(imageView, point: point, duration: 0.2)    //指定位置までアニメーション
            
            imageView.layer.shadowOpacity = 0.0
            
        }
        
    }

    
    //Value画像の移動判定用関数
    func judgeMoveWithDistance(distance: distanceClass, imageView: LocationImageView, imageViewArray: [LocationImageView]) -> Bool {
        var isMove = true   //移動させるか元の位置に戻すか否かを判定するための変数
        let width = imageView.bounds.width      //引数のviewのwidth
        let height = imageView.bounds.height    //引数のviewのheight
        
        //valueViewArrayの上段から上段への移動 -> false
        if imageView.location < 4 && distance.minIndex < 4 {isMove = false}
            
            //minIndexとの距離が規定値以上 -> false
        else if distance.distanceArray[distance.minIndex] > sqrt(width * width + height * height) * 0.5 { isMove = false }
            
            //valueViewArrayの下段から上段への移動 -> false
        else if imageView.location > 3 && distance.minIndex < 4 {isMove = false}
            
            //valueViewArrayの下段から下段への移動 && 最短距離が規定値以上 -> false
        else if imageView.location > 3 && distance.minIndex > 3
            && distance.distanceArray[distance.minIndex] > sqrt(width * width + height * height) * 0.5 {
                isMove = false
                
        } else {
            //No case
        }
        
        return isMove
        
    }
    
    //Value画像の計算エリアからの移動判定用関数
    func judgeCalcWithDistance(distance: distanceClass, imageView: LocationImageView, imageViewArray: [LocationImageView]) -> Bool {
        
        var isNotCalc = false                   //計算用のlocationからターゲットのViewを脱出させるかを判定するための変数
        let width = imageView.bounds.width      //引数のviewのwidth
        let height = imageView.bounds.height    //引数のviewのheight
        
        //valueViewArrayの下段から上段への移動 -> true
        if imageView.location > 3 && distance.minIndex < 4 {isNotCalc = true}
            
            
            //valueViewArrayの下段から下段への移動 && 最短距離が規定値以上 -> true
        else if imageView.location > 3 && distance.minIndex > 3 {
            if distance.distanceArray[distance.minIndex] > sqrt(width * width + height * height) * 0.5 {isNotCalc = true}
        }
        
        return isNotCalc
    }
    
    //Value画像のスライド判定用関数
    func judgeSlideWithDistance(distance: distanceClass, imageView: LocationImageView, imageViewArray: [LocationImageView]) -> (Bool, Int) {
        
        var isSlide = false     //スライド実行を判定する変数
        
        //minIndexに既にimageViewが存在する -> true
        let (index, isSlide_Int) = reduce(enumerate(imageViewArray), (-1, 0), {($1.1.location == distance.minIndex) && (imageView != $1.1) ? ($1.0, $0.1 + 1) : ($0.0, $0.1)})
        
        if isSlide_Int == 1 {isSlide = true}
        let minImageIndex = index   //minImageIndexはminIndexに既にviewが存在する場合の、そのviewArrayのindex (ややこしい...)
        
        return (isSlide, minImageIndex)
        
    }

    
    //Valueがallocateされていない最小のlocationを割り出し、そのlocationへ対象viewをスライドする関数
    func slideWithSlideView(slideView: LocationImageView, imageView: LocationImageView, imageViewArray: [LocationImageView]) -> Int {
        
        //Valueがallocateされていない最小のlocationを割り出す
        let minLocation = findMinEmptyLocationWithImageView(imageView, imageViewArray: imageViewArray)
        
        //割り出したlocationへ対象のviewをスライドする
        slideView.layer.shadowOpacity = 0.8                                     //位置が未確定 -> 影を付ける
        let point = destinationViewArray[minLocation].center                    //移動pointはスライド後のlocation
        animationLocateWithImageView(slideView, point: point, duration: 0.2)    //指定位置までアニメーション
        
        return minLocation
        
    }
    
    //Valueがallocateされていない最小のlocationを探す関数
    func findMinEmptyLocationWithImageView(imageView: LocationImageView, imageViewArray: [LocationImageView]) -> Int {
        
        let minEmptyLocation = [0,1,2,3,4,5,6].filter({$0 != imageViewArray[0].location}).filter({$0 != imageViewArray[1].location}).filter({$0 != imageViewArray[2].location}).filter({$0 != imageViewArray[3].location}).first
        
        return minEmptyLocation < imageView.location ? minEmptyLocation : imageView.location
        
    }

    
    //最も近いdestinationにtargetに対応したイメージを表示 & targetを元の位置へ or targetを元の位置へ (OperatorImageView +,-,×,÷ 用)
    func castImageWithDistance(distance: distanceClass, imageView: OperatorImageView, imageViewArray: [OperatorImageView]) {

        let width = imageView.bounds.width      //引数のviewのwidth (isCast判定に使用)
        let height = imageView.bounds.height    //引数のviewのheight (isCast判定に使用)
        
        //判定1: 移動先にて画像表示するか元の位置に戻すか   minIndexとの距離が規定値以上 -> false
        let isCast = distance.distanceArray[distance.minIndex] > sqrt(width * width + height * height) * 0.5 * 1.1 ? false : true
        
        //判定2: 表示位置を動かす(ように見せる)か   imageViewのlocationが-1より大きい場合(=imageViewArrayでない) -> false
        let isMove = imageView.location != -1 && distance.minIndex != imageView.location ? true : false
        
        //isCastがtrueの時には最も近いdestinationに移動し、falseの時には元の位置へ
        if isCast {

            //最も近いdestinationへtargetの画像を表示する
            castImageWithMinIndex(distance.minIndex, imageView: imageView, imageViewArray: imageViewArray)
            
            //表示処理
            imageViewArray[distance.minIndex].image = UIImage(named: "\(imageView.operatorName).png")
            if isMove {imageView.operatorName = ""; imageView.image = UIImage(named: "")}
            
            
        } else {
            //targetを元の位置へ戻すアニメーション
            let point = pointImage.start.imagePoint
            imageView.layer.shadowOpacity = 0.0
            animationLocateWithImageView(imageView, point: point, duration: 0.2)
            
            //演算子を削除するケースの処理
            if imageView.location > -1 {imageView.operatorName = ""; imageView.image = UIImage(named: "")}
            
        }
        
    }
    
    
    
    //最も近いdestinationにtargetに対応したイメージを表示 & targetを元の位置へ or targetを元の位置へ (OperatorImageView (,) 用)
    func castKakkoImageWithDistance(distance: distanceClass, imageView: OperatorImageView, imageViewArray: [OperatorImageView]) {
        //結構特殊な処理です。頭こんがらないで下さい。
        //目的は括弧を数字の横に表示すること。
        //括弧を表示するViewはcalcKakkoViewArray。
        //しかしdestination最短距離判定はdestinationViewArrayで行う。
        //なぜならcalcKakkoViewArrayは小さい。
        //よって括弧を動かす場合、通常数字を表示しているViewに放り込む方がよいのではと考えました。
        
        let width = destinationViewArray[0].bounds.width    //引数のviewのwidth (isCast判定に使用)
        let height = destinationViewArray[0].bounds.height  //引数のviewのheight (isCast判定に使用)
        
        //判定1: 移動先にて画像表示するか元の位置に戻すか   minIndexとの距離が規定値以上 -> false
        let isCast1 = distance.distanceArray[distance.minIndex] > sqrt(width * width + height * height) * 0.5 ? false : true
        
        //判定2: minIndexが4以下 (= destinationViewArrayの上段) -> false
        let isCast2 = distance.minIndex < 4 ? false : true
        
        //判定3: 表示位置を動かす(ように見せる)か   imageViewのlocationが-1より大きい場合(=imageViewArrayでない) -> false
        let isMove = imageView.location != -1 && (imageView.operatorName == "(" ? distance.minIndex * 2 : distance.minIndex * 2 + 1) != imageView.location ? true : false
        
        if isCast1 && isCast2 {

            //最も近いdesitinationを算出する
            let minIndex = imageView.operatorName == "(" ? (distance.minIndex - 4) * 2 : (distance.minIndex - 4) * 2 + 1

            //最も近いdestinationへtargetの画像を表示する
            castImageWithMinIndex(minIndex, imageView: imageView, imageViewArray: imageViewArray)
            
            //表示処理
            imageViewArray[minIndex].image = UIImage(named: "transparent_\(imageView.operatorName).png")
            if isMove {imageView.operatorName = ""; imageView.image = UIImage(named: "")}
            

        } else {
            //targetを元の位置へ戻すアニメーション
            let point = pointImage.start.imagePoint
            imageView.layer.shadowOpacity = 0.0
            animationLocateWithImageView(imageView, point: point, duration: 0.2)
            
            //演算子を削除するケースの処理
            if imageView.location > -1 {imageView.operatorName = ""; imageView.image = UIImage(named: "")}
            
        }
        
        
    }
    
    
    func castImageWithMinIndex(minIndex: Int, imageView: OperatorImageView, imageViewArray: [OperatorImageView]) {
        //targetを元の位置へ + 透過,影を元に戻す (アニメーションはしない)
        imageView.center = pointImage.start.imagePoint
        imageView.layer.shadowOpacity = 0.0
        imageView.layer.opacity = 1.0
        
        //最も近いdestinationへtargetの画像を表示する
        imageViewArray[minIndex].operatorName = imageView.operatorName
        imageViewArray[minIndex].layer.opacity = 0.3
        
        //ちょっと派手にするためのアニメーション
        animationLocateWithImageView(imageViewArray[minIndex], point: imageViewArray[minIndex].center, duration: 0.5)
        imageViewArray[minIndex].userInteractionEnabled = true
        
    }
    
    
    //引数1のUIImageViewを拡大縮小するアニメーションを実行
    func animationSizeWithImageView(view: UIView, duration : Double) {
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            view.bounds.size.width = view.bounds.size.width * 1.5
            view.bounds.size.height = view.bounds.size.height * 1.5
            
        })
        
        UIView.animateWithDuration(duration * 2, animations: { () -> Void in
            view.bounds.size.width = view.bounds.size.width / 1.5
            view.bounds.size.height = view.bounds.size.height / 1.5
            
        })
        
    }
    
    //引数1のUIImageViewを引数2の座標へアニメーションするメソッド
    func animationLocateWithImageView(view: UIView, point: CGPoint, duration: Double) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            view.center = point
            view.layer.opacity = 1.0
        })
        
    }
    


    
    //ゲーム開始時に戻します
    @IBAction func pressReset(sender: AnyObject) {
        
        for (index, _) in enumerate(valueViewArray) {
            valueViewArray[index].location = index
            animationLocateWithImageView(valueViewArray[index], point: destinationViewArray[index].center, duration: 0.5)
        }
        
        for (index, _) in enumerate(calcOperatorViewArray) {
            calcOperatorViewArray[index].operatorName = ""
            calcOperatorViewArray[index].image = UIImage(named: "")
        }
        
        for (index, _) in enumerate(calcKakkoViewArray) {
            calcKakkoViewArray[index].operatorName = ""
            calcKakkoViewArray[index].image = UIImage(named: "")
        }
        
        
    }
    

    //計算結果を表示します
    @IBAction func pressCalculate(sender: AnyObject) {
        
        let (canCalc1, canCalc2, canCalc3) = judgeCalc()
        
        if canCalc1 && canCalc2 && canCalc3 {
            
            var calcValueArray: [Int] = [-1,-1,-1,-1,-1]
            calcValueArray = makeCalcValueArray()   //valueViewArrayを計算に使い易い形に直す
            let token = getToken(calcValueArray)    //逆ポーランド記法に変換のため、まず式のtokenを取得
            
            var rpnBuffer = changeRpnWithToken(token)   //tokenから逆ポーランド記法に変換
            let (ret, err) = calculateRPN(rpnBuffer)    //逆ポーランド記法を計算
            
            if err {
                result.text = "エラー！！\nわりざんのつかいかたにちゅうい"
            } else if ret == 10 {
                result.text = "\(ret)\nおめでとう！１０ピッタリです！"
            } else {
                result.text = "\(ret)\n１０ピッタリをめざしてください"
            }
            
            
        } else {
            if canCalc1 == false {result.text = "けいさんできません\nすうじをすべてつかいましょう"}
            else if canCalc2 == false {result.text = "けいさんできません\nキゴウをすべてうめましょう"}
            else if canCalc3 == false {result.text = "けいさんできません\nカッコがとじられていません"}
        }
        
    }
    
    

    //valueViewArrayを計算に使い易い形に直す
    func makeCalcValueArray() -> [Int] {
        var calcValueArray = [-1,-1,-1,-1,-1]
        for (index, val) in enumerate(valueViewArray) {
            if valueViewArray[index].location == 4 {calcValueArray[0] = valueViewArray[index].value}
            else if valueViewArray[index].location == 5 {calcValueArray[1] = valueViewArray[index].value}
            else if valueViewArray[index].location == 6 {calcValueArray[2] = valueViewArray[index].value}
            else if valueViewArray[index].location == 7 {calcValueArray[3] = valueViewArray[index].value}
            else {calcValueArray[4] = valueViewArray[index].value}
        }
        
        return calcValueArray
    }

    //計算可能か判別する関数
    func judgeCalc() -> (Bool, Bool, Bool) {
        
        var calcValueArray: [Int] = [-1,-1,-1,-1,-1]
        var openKakko: [Int] = []
        var closeKakko: [Int] = []
        
        //valueViewArrayを計算に使い易い形に直す
        calcValueArray = makeCalcValueArray()
        
        //calcKakkoViewArrayを使い易い形に直す
        for (index, val) in enumerate(calcKakkoViewArray) {
            if calcKakkoViewArray[index].operatorName == "(" {openKakko.append(index)}
            else if calcKakkoViewArray[index].operatorName == ")" {closeKakko.append(index)}
            else {}//Do nothing
        }
        
        //条件1: valueViewArrayが全て下段に置かれている
        let canCalc1 = calcValueArray[4] > 0 ? false : true
        
        //条件2: calcOperatorViewArray全てに演算子が入っている
        let canCalc2 = calcOperatorViewArray.reduce(0, combine: {$1.operatorName != "" ? $0 : $0 + 1}) > 0 ? false : true
        
        //条件3: 括弧と閉じ括弧の数が等しい && 括弧が閉じられている
        let canCalc3 = (openKakko.count == closeKakko.count && openKakko.last < closeKakko.last)
            || (openKakko.count == closeKakko.count && openKakko.count == 0) ? true : false
        
        return (canCalc1, canCalc2, canCalc3)
        
    }
 
    //式Token作成関数
    func getToken(calcValueArray: [Int]) -> [String] {
        
        //式を配列にする (Token作成)
        var token: [String] = []
        for index in 0...3 {
            //1. 括弧があった場合には配列に追加
            if calcKakkoViewArray[index * 2].operatorName != "" {token.append(calcKakkoViewArray[index * 2].operatorName)}
 
            //2. valueを配列に追加
            token.append("\(calcValueArray[index])")
            
            //3. 括弧閉じがあった場合には配列に追加
            if calcKakkoViewArray[index * 2 + 1].operatorName != "" {token.append(calcKakkoViewArray[index * 2 + 1].operatorName)}
            
            //4. 演算子を配列に追加
            if index != 3 {token.append(calcOperatorViewArray[index].operatorName)}
        }
        
        return token
        
    }
    
    //逆ポーランド記法への変換関数 [参考URL]("http://www.gg.e-mansion.com/~kkatoh/program/novel2/novel208.html")
    func changeRpnWithToken(rpnToken: [String]) -> [String] {
        
        var rpnBuffer: [String] = []
        var rpnStack: [String] = []
        var kakkoFlag: Bool = false
        let operatorPriorityDict: Dictionary = ["+": 0, "-": 0, "×": 1, "÷": 1]
        
        for (index, val) in enumerate(rpnToken) {

            //1. 数字であれば、TokenをBufferに追加
            if rpnToken[index] >= "0" && rpnToken[index] <= "9" {rpnBuffer.append(rpnToken[index])}
                
            //2. ")"であれば、Stackのlastから"("直前までBufferへ   "("は捨てる -> ループ終了
            else if rpnToken[index] == ")" {
                for (index2, val) in enumerate(rpnStack) {
                    
                    if rpnStack.last != "(" {rpnBuffer.append(rpnStack[rpnStack.count - index2 - 1]); rpnStack.removeLast()}
                    else {rpnStack.removeLast(); break}
                    
                }

            //3. "("であれば、TokenをStackに追加
            } else if rpnToken[index] == "(" {rpnStack.append(rpnToken[index])}
           

            //4. Other
            else {

                //4-1. Stackが空でない
                while rpnStack.isEmpty == false {

                    //4-2. Stackの最上段の演算子よりTokenの演算子の優先順位が低ければ、TokenをStackに追加 -> ループ終了
                    if operatorPriorityDict[rpnToken[index]] > operatorPriorityDict[rpnStack.last!] {
                        
                        rpnStack.append(rpnToken[index])
                        break

                    //4-3. Stackの最上段の演算子よりTokenの演算子の優先順位が高いまたは同じであれば、StackをBufferに追加
                    } else {

                        rpnBuffer.append(rpnStack.last!)
                        rpnStack.removeLast()
                        
                    }
                    
                }
                
                //4-4. Stackが空ならば、TokenをStackに追加
                if rpnStack.isEmpty {rpnStack.append(rpnToken[index])}
                
            }
            
            
        }

        //5. Tokenを全て読み出した場合、空になるまでStackをBufferに追加
        for index1 in rpnStack {
            if rpnStack.isEmpty {break}
            else {rpnBuffer.append(rpnStack.last!); rpnStack.removeLast()}
        }
        
        return rpnBuffer

    }

    //逆ポーランド記法計算関数
    func calculateRPN(var rpnBuffer: [String]) -> (Int, Bool) {
        var ret = 0
        var err = false
        
        while rpnBuffer.count > 1 {
            for (index, val) in enumerate(rpnBuffer) {
                
                if rpnBuffer[index] == "+" || rpnBuffer[index] == "-" || rpnBuffer[index] == "×" || rpnBuffer[index] == "÷" {
                    
                    if index < 2 {err = true; return (ret, err)}
                    
                    (ret, err) = calculateWithOpeartor(rpnBuffer[index], paramStr1: rpnBuffer[index - 2], paramStr2: rpnBuffer[index - 1])
                    
                    if err {return (ret, err)}
                    
                    rpnBuffer.removeAtIndex(index)
                    rpnBuffer.removeAtIndex(index - 1)
                    rpnBuffer.removeAtIndex(index - 2)
                    
                    rpnBuffer.insert("\(ret)", atIndex: index - 2)
                    
                    break
                    
                    
                }
            }
            
        }
        
        return (ret, err)
        
    }
    

    //四則演算関数
    func calculateWithOpeartor(operatorName: String, paramStr1: String, paramStr2: String) -> (Int, Bool) {
        
        var ret: Int? = nil
        var err: Bool = false
        let param1 = paramStr1.toInt()!
        let param2 = paramStr2.toInt()!
        
        switch operatorName {
        case "+":
            ret = param1 + param2
        case "-":
            ret = param1 - param2
        case "×":
            ret = param1 * param2
        case "÷":
            //0除算を考慮する
            if param2 != 0 {
                ret = param1 / param2
                if param1 % param2 != 0 {err = true}
            } else {
                ret = 0
                err = true
            }
        default:
            ret = 0
            err = true
        }
        
        if err {println("(ret, err) = (\(ret!),\(err))")}
        
        return (ret!, err)
        
    }
    
}

