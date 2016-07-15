//
//  GraphController.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 2/15/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import UIKit
import SwiftCharts
import CoreData
import SwiftDate

struct Day {
    var points :Int
    let data :String
    
    init(points :Int, data: String){
        self.points = points
        self.data = data
    }
}
class GraphController: UIViewController {
    var points :String = ""
    var date :String = ""
    var xAxis :[String] = []
    var fetchTasks = [Task]()
    var days :[Day] = []
    let interactive:UIButton = UIButton()
    private var chart: Chart? // arc
    var chartPoints : [ChartPoint] = []
   
    override func viewDidLoad() {
        super.viewDidLoad()
        /*if fetchData() {
            createChart()
        }*/
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
        
        if fetchData() {
            createChart()
        }
    }
    
    func createChart() {
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        
        //Get the points
        
        chartPoints = days.enumerate().map { index, item in
            let x = ChartAxisValueString(item.data, order: index, labelSettings: labelSettings)
            let y = ChartAxisValueInt(item.points)
            return ChartPoint(x: x, y: y)}
        for day in days {
            xAxis.append(day.data)
        }
        var max : [Int] = []
        for day in days {
            max.append(day.points)
        }
        var byMargin = 0
        if let current = max.maxElement() {
            var temp = current
            while temp  > 0 {
                temp = temp - 20
                byMargin += 1
            }
        }
        

        // define x and y axis values (quick-demo way, see other examples for generation based on chartpoints)
        let xValues = [ChartAxisValueString("", order: -1)] + chartPoints.map{$0.x} + [ChartAxisValueString("", order: days.count)]
        let yValues = 0.stride(through: max.maxElement()!, by: byMargin ).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        
        // create axis models with axis values and axis title
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Date", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Points", settings: labelSettings.defaultVertical()))
        
        let scrollViewFrame = ExamplesDefaults.chartFrame(CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 50))
        let chartFrame = CGRectMake(0, 0, 1800, scrollViewFrame.size.height)
        // generate axes layers and calculate chart inner frame, based on the axis models
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
            
            dispatch_async(dispatch_get_main_queue()) {
                let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
                let lineModel = ChartLineModel(chartPoints: self.chartPoints, lineColor: UIColor.greenColor(), animDuration: 1, animDelay: 0)
                
                // create layer with guidelines
                let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
                let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: guidelinesLayerSettings)
                
                // view generator - this is a function that creates a view for each chartpoint
                let viewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
                    
                    let viewSize: CGFloat = Env.iPad ? 30 : 20
                    let center = chartPointModel.screenLoc
                    let button = UIButton(frame: CGRectMake(center.x - viewSize / 2, center.y - viewSize / 2, viewSize + 25, viewSize))
                    
                    button.setTitle(chartPointModel.chartPoint.y.text, forState: UIControlState.Normal)
                    button.backgroundColor = UIColor.greenColor()
                    
                    button.addTarget(self, action: "showLabel:", forControlEvents: .TouchUpInside)
                    
                    return button
                }
                
                // create layer that uses viewGenerator to display chartpoints
                let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: self.chartPoints, viewGenerator: viewGenerator)
                let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: [lineModel])
                
                let scrollView = UIScrollView(frame: scrollViewFrame)
                scrollView.contentSize = CGSizeMake(chartFrame.size.width, scrollViewFrame.size.height)
                
                
                // create chart instance with frame and layers
                let chart = Chart(
                    frame: chartFrame,
                    layers: [
                        coordsSpace.xAxis,
                        coordsSpace.yAxis,
                        guidelinesLayer,
                        chartPointsLineLayer,
                        chartPointsLayer
                    ]
                )
                
                scrollView.addSubview(chart.view)
                self.view.addSubview(scrollView)
                self.chart = chart
                
            }
        }
    }
    func showLabel(sender :AnyObject) {
        let button = sender as! UIButton
        
        
        button.transform = CGAffineTransformMakeScale(0.6, 0.6)
        
        UIView.animateWithDuration(2.0,
            delay: 0,
            usingSpringWithDamping: CGFloat(0.15),
            initialSpringVelocity: CGFloat(25.0),
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                button.transform = CGAffineTransformIdentity
            },
            completion: { Void in()  }
        )
        
        for (index, chart) in chartPoints.enumerate() {
            if (button.currentTitle == chart.y.text) {
                points = chart.y.text
                date = xAxis[index]
            }
            
        }
        
        let alertView = UIAlertController(title: "Information", message: "Points: " + points + " Date: " + date, preferredStyle: UIAlertControllerStyle.Alert  )
        alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alertView.addAction(UIAlertAction(title: "More Info", style: UIAlertActionStyle.Default) { (action) in
            self.performSegueWithIdentifier("showInfo", sender: self.date)
        })
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showInfo" {
            let  vc :MoreInfoController = segue.destinationViewController as! MoreInfoController
            vc.actualDate = date
        }
    }
    
    func fetchData() -> Bool {
        fetchTasks = []
        days = []
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        do {
            
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Task]
            
            if fetchData.count == 0 {
                return false
            }
            for data in fetchData {
                if data.finished == true {
                    fetchTasks.append(data)
                }
            }
            var times :[Double] = []
            for time in fetchTasks {
                times.append((time.dateCompleted?.timeIntervalSinceReferenceDate)!)
            }
            
            let current = Region(timeZoneName: TimeZoneName.Local)
            var minimum = NSDate(timeIntervalSinceReferenceDate: times.minElement()!).inRegion(current)
            let maximum = NSDate().inRegion(current)
            
            while minimum.isBefore(NSCalendarUnit.Day, ofDate: maximum) {
                days.append(Day(points: 0, data: minimum.toShortString(date: true, time: false)!))
                minimum = minimum + 1.days
            }
            
            for task in fetchTasks {
                for (index, day) in days.enumerate() {
                    if task.dateCompleted!.inRegion(current).toShortString(date: true, time: false) == day.data {
                        days[index].points = day.points + Int (task.points!)
                    }
                }
            }
            
            if days.count == 0  {
                return false
            }
        }
        catch let error as NSError{
            print(error)
        }
        
        return true
    }
}



