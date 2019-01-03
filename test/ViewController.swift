////
////  ViewController.swift
////  test
////
////  Created by 上田　護 on 2019/01/02.
////  Copyright © 2019 mamoru.ueda. All rights reserved.
////
//
//import UIKit
//import Charts
//
//class ViewController: UIViewController {
//
//    @IBOutlet weak var pieChartView: PieChartView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupPieChartView()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    /**
//     円グラフをセットアップする
//     */
//    private func setupPieChartView() {
//        self.pieChartView.usePercentValuesEnabled = true
////        self.pieChartView.descriptionText = "チャートの説明"
//          self.pieChartView.chartDescription?.text = "test"
//        // 円グラフに表示するデータ
//        var dataEntries = [ChartDataEntry]()
//        for index in (1...4).reversed() {
//            dataEntries.append(ChartDataEntry(x: Double(index) * 10.0, y: Double(index)))
//        }
//        let dataSet = PieChartDataSet(values: dataEntries, label: "チャートのラベル")
//        dataSet.colors = ChartColorTemplates.colorful()
//
//        //        let data = ChartData(values: ["A", "B", "C", "D"], dataSet: dataSet)
//        let data = ChartData(dataSet: dataSet)
//
//        // %表示
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = NumberFormatter.Style.percent
//        numberFormatter.maximumFractionDigits = 1;
//        numberFormatter.multiplier = NSNumber(value: 1)
//        numberFormatter.percentSymbol = " %";
//        data.setValueFormatter(numberFormatter as? IValueFormatter)
//
//        self.pieChartView.data = data
//    }
//
//
//}
//
import UIKit
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var pieChart: PieChartView!
    
    //UIButtonをタップすることで下記の追記した二つの関数を呼び出しチャートを書き換えます。
    //追記
//    @IBAction func tap(_ sender: UIButton) {
//        let hourValues = [9, 3, 5, 7.0]
//        let set = makeSet(values: hourValues)
//        change(types: set.types, values: set.values)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makePieChart() //メソッドを呼び出す
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //追記  だいたいこういう感じでvaluesを元にしたり他の引数を入れたりしてFormatterに入れる引数を作ったりします
    func makeSet(values: [Double]) -> (types: [ActivityType], values: [Double]) {
        let minutesValues = values.map{$0 * 60} // 分表記
        let types: [ActivityType] = [.sleeping, .blank, .training, .blank]
        return (types, minutesValues)
    }
    
    //追記  ここではすでに作られたpieChartの一部分だけを修正して、それをpieChartに通知します。そうすることで画面に表示されているチャートの情報が書き換わります。
    func change(types: [ActivityType], values: [Double]) {
        guard let dataSet = pieChart.data?.dataSets.first as? PieChartDataSet else {
            fatalError()
        }
        let entries = values.map{PieChartDataEntry(value: Double($0))}
        dataSet.values = entries
        dataSet.valueFormatter = CustomLabelFomatter(types: types, values: values)
        pieChart.notifyDataSetChanged()
    }
    
    func makePieChart() {
        let hourValues = [8, 4, 2, 9.6, 0.4] // <=24時間、時間表記
        let minutesValues = hourValues.map{$0 * 60} // 分表記
        let types: [ActivityType] = [.sleeping, .blank, .training, .blank, .training]
        
        let entries = minutesValues.map{ element -> PieChartDataEntry in
            let value = Double(element)
            return PieChartDataEntry(value: value)
        }
        //entriesは[PieChartDataEntry]
        let dataSet = PieChartDataSet(values: entries, label: "")
        
        dataSet.colors = [.purple, .gray, .blue, .gray, .blue]
        dataSet.valueFormatter = CustomLabelFomatter(types: types, values: minutesValues)  //<=ここでFormatterを設定
        
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
    }
}

//下記にもありますが[String]を用意せずにtype.rawValueという形でlabelを表示していきます。ここはそのための下準備
enum ActivityType: String {
    case sleeping = "睡眠"
    case training = "トレーニング"
    case blank = "空白"
}

class CustomLabelFomatter: NSObject, IValueFormatter {
    
    let types: [ActivityType] //最初は[String]でやっていましたがTypeを作ってやる方法に興味がありそうなのでそちらでやっています
    let values: [Double]
    
    init(types: [ActivityType], values: [Double]) {
        self.types = types
        self.values = values
    }
    
    func convert(value: Double) -> String {
        guard let convertedString = values
            .enumerated()
            .filter({$0.element == value})
            .map({ tuple -> String in
                
                let index = tuple.offset
                let type = types[index]
                
                //例えがvalueが5.0より少ないときは何も表示しないとの事でしたが5.0だと扱いにくいので条件を変えています。具体的にはvalueの中身を分表記にして30分未満の場合は何も表示しないとしています。なので最後のPieChartDataEntryにはlabelがありません。
                //ちなみにこんな風に処理の途中でreturnするのを早期リターンと言います。早期リターンを行うとそこより下の処理はせずとっとと次の処理に行くのでいろんな面で優しいです。
                if value < 0.5 * 60 {
                    print("早期リターン")
                    return ""
                    //ちなみにこんな風に処理の途中でreturnするのを早期リターンと言います。早期リターンを行うとそこより下の処理はせずとっとと次の処理に行くのでいろんな面で優しいです。
                }
                
                print("処理継続中")
                
                switch type {  //今回はあまりメリットがありませんがswitch + enumはかなり強力です。漏れがあるとXcodeからお叱りが飛んできます。単純な処理だけど場合分けの量が多い時なんかはif文よりswitch文 + enumの方が楽でしょうね。
                case .blank:
                    return ""  //.blankの場合は何も表示しません
                default:
                    return type.rawValue  //が、そのほかのtypeだった場合enumのrawValueを呼び出します。こいつはActivityTypeを見れば分かりますがStringを返しています。
                }
                
            }).first else {fatalError()}
        
        return convertedString
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        print(value)  //ここでのvalueは各々のPieChartDataEntryのvalueです
        return convert(value: value)
    }
}
