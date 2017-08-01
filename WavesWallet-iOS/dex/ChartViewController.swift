//
//  ChartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import Charts

protocol ChartViewControllerDelegate {

    func chartViewControllerDidChangeTimeFrame()
}

class ChartViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate : ChartViewControllerDelegate!
    
    var timeframe = DataManager.getCandleTimeFrame()
    var candles = NSMutableArray()
    
    var dateFrom = Date()
    var dateTo = Date()
    var isLoading = false
    var lastOffsetX : Double = 0
    
    @IBOutlet weak var viewLimitLine: UIView!
    @IBOutlet weak var viewLimitLineOffset: NSLayoutConstraint!
    
    @IBOutlet weak var labelCandleInfo: UILabel!
    
    @IBOutlet weak var candleChartView: CandleStickChartView!
    @IBOutlet weak var barChartView: BarChartView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupChartsStyle()
        
        candleChartView.isHidden = true
        barChartView.isHidden = true
        
        setupLabelCandleInfo()
        
        viewLimitLine.isHidden = true
        
        preloadInfo {
            self.activityIndicator.stopAnimating()
            self.candleChartView.isHidden = false
            self.barChartView.isHidden = false
            
            self.candleChartView.zoom(scaleX: 10, scaleY: 0, x:CGFloat.greatestFiniteMagnitude, y: 0)
            self.barChartView.zoom(scaleX: 10, scaleY: 0, x:CGFloat.greatestFiniteMagnitude, y: 0)
        
            self.updateCandleLimitLine()
        }
    }
    
    
    
    func updateCandleLimitLine() {
        NetworkManager.getCandleLimitLine(amountAsset: "WAVES", priceAsset: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS") { (price, errorMessage) in
            
            if price > 0 && self.candleChartView.data != nil {
                
                let limitLine = ChartLimitLine(limit: price)
                
                limitLine.lineColor = ((((self.candleChartView.data as? CandleChartData)?.dataSets.first) as? CandleChartDataSet)?.highlightColor)!
                limitLine.lineWidth = 1
                
                self.candleChartView.rightAxis.removeAllLimitLines()
                self.candleChartView.rightAxis.addLimitLine(limitLine);
                self.candleChartView.notifyDataSetChanged()
            }
        }
    }
    
    func setupLabelCandleInfo() {
        
        if candleChartView.highlighted.first != nil && candles.count > 0 {
            let highlighted = candleChartView.highlighted.first

            for model in candles as! [CandleModel] {
                if model.timestamp == highlighted?.x {
                    labelCandleInfo.text = "WAVES/BTC, \(nameFromTimeFrame(timeframe)), \(model.getFormatterDateTime(timeFrame: timeframe))\nO: \(model.open), H: \(model.high), L: \(model.low), C: \(model.close)\nV: \(model.volume)"
                }
            }
        }
        else {
            labelCandleInfo.text = "WAVES/BTC, \(nameFromTimeFrame(timeframe))"
        }
    }

    func nameFromTimeFrame(_ value: Int) -> String {
        
        if value == 1440 {
            return "D1"
        }
        else if value >= 60 {
            return "H\(value / 60)"
        }
        
        return "M\(value)"
    }
    
    func updateCandle() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        candleChartView.isHidden = true
        barChartView.isHidden = true
        dateFrom = Date()
        
        let prevCount = self.candles.count
        self.candles.removeAllObjects()
        setupLabelCandleInfo()
        
        preloadInfo {
            self.activityIndicator.stopAnimating()
            self.candleChartView.isHidden = false
            self.barChartView.isHidden = false

            let zoom = CGFloat(self.candles.count) * self.candleChartView.scaleX / CGFloat(prevCount)
            let additionalZoom = zoom / self.candleChartView.scaleX
            
            self.candleChartView.moveViewToAnimated(xValue: Double(CGFloat.greatestFiniteMagnitude), yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
            self.candleChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)

            self.barChartView.moveViewToAnimated(xValue: Double(CGFloat.greatestFiniteMagnitude), yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
            self.barChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)

            self.candleChartView.highlightValue(nil)
            self.barChartView.highlightValue(nil)
        }
    }
    
    func timeFrameTapped() {
        
        let controller = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = UIColor.black
        
        let cancelButton = UIAlertAction.init(title: nameFromTimeFrame(timeframe), style: .cancel, handler: nil)

        let buttonTime5 = UIAlertAction.init(title: nameFromTimeFrame(5), style: .default) { (action: UIAlertAction) in
          
            self.timeframe = 5
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime15 = UIAlertAction.init(title: nameFromTimeFrame(15), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 15
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime30 = UIAlertAction.init(title: nameFromTimeFrame(30), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 30
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime60 = UIAlertAction.init(title: nameFromTimeFrame(60), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 60
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime240 = UIAlertAction.init(title: nameFromTimeFrame(240), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 240
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime1440 = UIAlertAction.init(title: nameFromTimeFrame(1440), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 1440
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        
        controller.addAction(cancelButton)
        
        if timeframe != 5 {
            controller.addAction(buttonTime5)
        }
        if timeframe != 15 {
            controller.addAction(buttonTime15)
        }
        if timeframe != 30 {
            controller.addAction(buttonTime30)
        }
        if timeframe != 60 {
            controller.addAction(buttonTime60)
        }
        if timeframe != 240 {
            controller.addAction(buttonTime240)
        }
        if timeframe != 1440 {
            controller.addAction(buttonTime1440)
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    func preloadInfo(complete: @escaping () -> Void) {
        
        if isLoading {
            return
        }
        
        isLoading = true
        
        dateTo = dateFrom
        let additionalTime : Double = Double(3600 * ((timeframe * 100) / 60))
        dateFrom = dateFrom.addingTimeInterval(-additionalTime)
        
        NetworkManager.getCandles(amountAsset: "WAVES", priceAsset: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", timeframe: timeframe, from: dateFrom, to: dateTo) { (items: NSArray?, errorMessage: String?) in
            
            self.isLoading = false
            
            if items != nil {
                self.setupData(items!)
                complete()
            }
        }
    }
    
    func setupData(_ items: NSArray) {
        
        let valueFormatter = candleChartView.xAxis.valueFormatter as! CandleTimeAxisValueFormatter
        valueFormatter.timeFrame = timeframe
        
        let sortedItems = items.sortedArray(using: [NSSortDescriptor.init(key: "timestamp", ascending: true)])

        for item in sortedItems {
            let model = CandleModel()
            model.setupModel(item as! NSDictionary, timeFrame: timeframe)
            
            if model.volume == 0 || candles.contains(model) {
                continue
            }
            
            candles.add(model)
        }
        
        candles.sort(using: [NSSortDescriptor.init(key: "timestamp", ascending: true)])
        
        let candleYVals = NSMutableArray()
        let barYVals = NSMutableArray()

        for _model in candles {
            let model = _model as! CandleModel
            
            candleYVals.add(CandleChartDataEntry(x: model.timestamp, shadowH:model.high , shadowL:model.low , open:model.open, close: model.close))
            barYVals.add(BarChartDataEntry.init(x: model.timestamp, y: model.volume))
        }
        
        let candleSet = CandleChartDataSet.init(values: candleYVals as? [ChartDataEntry], label: "")
        candleSet.axisDependency = .right
        candleSet.setColor(NSUIColor.init(cgColor: UIColor.init(white: 80/255, alpha: 1).cgColor))
        candleSet.drawIconsEnabled = false
        candleSet.drawValuesEnabled = false
        candleSet.shadowWidth = 0.7;
        candleSet.decreasingColor = UIColor(red: 228, green: 91, blue: 87)
        candleSet.decreasingFilled = true
        candleSet.increasingColor = UIColor(red: 98, green: 171, blue: 109)
        candleSet.increasingFilled = true
        candleSet.neutralColor = UIColor(red: 136, green: 226, blue: 247)
        candleSet.shadowColorSameAsCandle = true
        candleSet.drawHorizontalHighlightIndicatorEnabled = false
        candleSet.highlightLineWidth = 0.4
        
        candleChartView.data = CandleChartData.init(dataSet: candleSet)
        candleChartView.notifyDataSetChanged()
        
        
        
        let barSet = BarChartDataSet.init(values: barYVals as? [ChartDataEntry], label: "")
        barSet.axisDependency = .right
        barSet.drawIconsEnabled = false
        barSet.drawValuesEnabled = false
        barSet.highlightColor = UIColor(red: 103, green: 105, blue: 111)
        barSet.setColor(UIColor(red: 195, green: 199, blue: 210))
        
        let barData = BarChartData.init(dataSet:barSet)
        barData.barWidth = 0.80
        barChartView.data = barData
        barChartView.notifyDataSetChanged()
    }

    
    //MARK: ChartViewDelegate
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if chartView == barChartView {
            candleChartView.highlightValue(chartView.highlighted.first)
        }
        else {
            barChartView.highlightValue(chartView.highlighted.first)
        }
        
        setupLabelCandleInfo()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
        if chartView == barChartView {
            candleChartView.highlightValue(nil)
        }
        else {
            barChartView.highlightValue(nil)
        }

        setupLabelCandleInfo()
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {

        if chartView == candleChartView {
            barChartView.zoom(scaleX: candleChartView.scaleX, scaleY: candleChartView.scaleY, xValue: 0, yValue: 0, axis: YAxis.AxisDependency.right)
            barChartView.moveViewToX(candleChartView.lowestVisibleX)
        }
        else {
            candleChartView.zoom(scaleX: barChartView.scaleX, scaleY: barChartView.scaleY, xValue: 0, yValue: 0, axis: YAxis.AxisDependency.right)
            candleChartView.moveViewToX(barChartView.lowestVisibleX)
        }
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        if chartView == candleChartView {
            barChartView.moveViewToX(candleChartView.lowestVisibleX)
        }
        else {
            candleChartView.moveViewToX(barChartView.lowestVisibleX)
        }
        
        if candles.count > 0 {
            
            let value = round(candleChartView.lowestVisibleX)
            let model = candles.firstObject as! CandleModel
            
            if value == model.timestamp && !isLoading {
                
                lastOffsetX = candleChartView.lowestVisibleX
                let prevCount = self.candles.count
                
                preloadInfo {
                    
                    if self.candles.count > prevCount {
                        
                        let zoom = CGFloat(self.candles.count) * self.candleChartView.scaleX / CGFloat(prevCount)
                        let additionalZoom = zoom / self.candleChartView.scaleX
                        
                        self.candleChartView.moveViewToAnimated(xValue: self.lastOffsetX, yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
                        self.candleChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)
                        
                        self.barChartView.moveViewToAnimated(xValue: self.lastOffsetX, yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
                        self.barChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)
                    }
                }
            }
        }
        
        viewLimitLineOffset.constant = getLimitLineOffset() - viewLimitLine.frame.size.height / 2
    }
    
    func getLimitLineOffset() -> CGFloat {

        var position = CGPoint(x: 0.0, y: 0.0)
        let trans = candleChartView.rightYAxisRenderer.transformer?.valueToPixelMatrix
        let l = candleChartView.rightAxis.limitLines.first!
        var clippingRect = candleChartView.viewPortHandler.contentRect
        clippingRect.origin.y -= l.lineWidth / 2.0
        clippingRect.size.height += l.lineWidth
        position.x = 0.0
        position.y = CGFloat(l.limit)
        position = position.applying(trans!)
        
        return position.y
    }
    
    //MARK: SetupBars
    
    func setupChartsStyle() {
        
        candleChartView.delegate = self
        candleChartView.chartDescription?.enabled = false
        candleChartView.pinchZoomEnabled = false
        candleChartView.scaleYEnabled = false
        candleChartView.scaleXEnabled = true
        candleChartView.autoScaleMinMaxEnabled = true
        candleChartView.autoScaleMinMaxEnabled = true
        candleChartView.leftAxis.enabled = false
        candleChartView.legend.enabled = false
        candleChartView.doubleTapToZoomEnabled = false
        candleChartView.drawGridBackgroundEnabled = false
        candleChartView.noDataTextColor = UIColor.white
        
        candleChartView.xAxis.labelPosition = .bottom;
        candleChartView.xAxis.gridLineWidth = 0.2
        candleChartView.xAxis.labelCount = 4
        candleChartView.xAxis.gridLineDashPhase = 0.1
        candleChartView.xAxis.gridLineDashLengths = [0.1, 0.3, 0.6]
        candleChartView.xAxis.gridLineCap = CGLineCap.butt
        candleChartView.xAxis.labelTextColor = UIColor.white
        candleChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        candleChartView.xAxis.valueFormatter = CandleTimeAxisValueFormatter()
        candleChartView.xAxis.granularityEnabled = true
        
        candleChartView.rightAxis.enabled = true
        candleChartView.rightAxis.labelCount = 10
        candleChartView.rightAxis.gridLineWidth = 0.2
        candleChartView.rightAxis.gridLineDashPhase = 0.1
        candleChartView.rightAxis.gridLineDashLengths = [0.1, 0.3, 0.6]
        candleChartView.rightAxis.gridLineCap = CGLineCap.butt
        candleChartView.rightAxis.labelTextColor = UIColor.white
        candleChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 8)
        candleChartView.rightAxis.valueFormatter = CandleAxisValueFormatter()
        candleChartView.rightAxis.minWidth = 55
        candleChartView.rightAxis.maxWidth = 55
        candleChartView.rightAxis.forceLabelsEnabled = true
        
        barChartView.delegate = self
        barChartView.chartDescription?.enabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.scaleXEnabled = true
        barChartView.autoScaleMinMaxEnabled = true
        barChartView.leftAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.noDataTextColor = UIColor.white
        barChartView.noDataText = ""
        
        barChartView.rightAxis.enabled = true
        barChartView.rightAxis.labelCount = 4
        barChartView.rightAxis.gridLineWidth = 0.2
        barChartView.rightAxis.gridLineDashPhase = 0.1
        barChartView.rightAxis.gridLineDashLengths = [0.1, 0.3, 0.6]
        barChartView.rightAxis.gridLineCap = CGLineCap.butt
        barChartView.rightAxis.labelTextColor = UIColor.white
        barChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 8)
        barChartView.rightAxis.valueFormatter = BarAxisValueFormatter()
        barChartView.rightAxis.minWidth = 55
        barChartView.rightAxis.maxWidth = 55
        barChartView.rightAxis.axisMinimum = 0
        barChartView.rightAxis.forceLabelsEnabled = true

        barChartView.xAxis.gridLineWidth = 0.2
        barChartView.xAxis.gridLineDashPhase = 0.1
        barChartView.xAxis.gridLineDashLengths = [0.1, 0.3, 0.6]
        barChartView.xAxis.gridLineCap = CGLineCap.butt
        barChartView.xAxis.valueFormatter = BarAxisSpaceFormatter()
        barChartView.xAxis.labelPosition = .bottom;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}