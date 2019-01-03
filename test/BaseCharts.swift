//
//  BaseCharts.swift
//  test
//
//  Created by 上田　護 on 2019/01/02.
//  Copyright © 2019 mamoru.ueda. All rights reserved.
//

import UIKit
import Charts

class BaseCharts: UIView {
    @IBOutlet weak var chartView: PieChartView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func setupGraph() {
        chartView.usePercentValuesEnabled = true
        
        let values: [Double] = [0, 1, 1, 1, 1]
        let date : [Double] = [1,2,3,4,5]
        var entries: [ChartDataEntry] = Array()
        for (i, value) in values.enumerated(){
            entries.append(ChartDataEntry(x: date[i], y: value, icon: UIImage(named: "icon", in: Bundle(for: self.classForCoder), compatibleWith: nil)))
        }
        
        let dataSet = PieChartDataSet(values: entries, label: "ラベル")
        
        dataSet.colors = ChartColorTemplates.vordiplom()
        
        let chartData = PieChartData(dataSet: dataSet)
        
        chartView.data = chartData
    }
}
