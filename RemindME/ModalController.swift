//
//  ModalController.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 3/11/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import UIKit
import SwiftDate
protocol ModalControllerDelegate {
    func saveData(data :String, points :Int, dueDate :NSDate);
}

class ModalController: UIViewController, UITextViewDelegate,  UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var task: UITextView!
    var delegate :ModalControllerDelegate! = nil
    
    //Set timers
    var days :[Int] = []
    var hours :[Int] = []
    var minutes :[Int] = []
    //Pickers
    @IBOutlet weak var daysPicker: UIPickerView!
    
    @IBOutlet weak var hoursPicker: UIPickerView!
    
    @IBOutlet weak var minutesPicker: UIPickerView!
    
    //Dates variables
    var setDay :Int = 0
    var setHour :Int = 0
    var setMinute :Int = 0
    
    @IBAction func createTask(sender: AnyObject) {
        
        if (task.text != "") {
            let date = NSDate() + setDay.days + setHour.hours + setMinute.minutes

            delegate.saveData(task.text, points: Int (actualValue.text!)!, dueDate: date)
            self.dismissViewControllerAnimated(true, completion: {
                self.presentingViewController
            })
            
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Enter your task descripton", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTask(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            self.presentingViewController
        })
    }
    
    @IBOutlet weak var slidervalue: UISlider!
    
    @IBAction func sliderAction(sender: UISlider) {
         actualValue.text = String (Int(round( sender.value)))
    }
    
    @IBOutlet weak var actualValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for var i = 0; i < 101; i++ {
            days.append(i)
        }
        for var i = 0; i < 25; i++ {
            hours.append(i)
        }
        
        for var i = 0; i < 61; i++ {
            minutes.append(i)
        }
        
        daysPicker.delegate = self
        hoursPicker.delegate = self
        minutesPicker.delegate = self
        daysPicker.dataSource = self
        hoursPicker.dataSource = self
        minutesPicker.dataSource = self
        daysPicker.tag = 0
        hoursPicker.tag = 1
        minutesPicker.tag = 2
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        task.delegate = self
        actualValue.text = String (Int(round (slidervalue.value)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 0 {
            return days.count
        } else if pickerView.tag == 1 {
            return hours.count
        } else if pickerView.tag == 2 {
            return  minutes.count
        }
        return 1
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0 {
            return String(days[row])
        } else if pickerView.tag == 1 {
            return String(hours[row])
        } else if pickerView.tag == 2 {
            return String(minutes[row])
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        
        if pickerView.tag == 0 {
            setDay = days[row]
        } else if pickerView.tag == 1 {
            setHour = hours[row]
        } else if pickerView.tag == 2 {
            setMinute = minutes[row]
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if range.length + range.location > task.text.characters.count {
            return false
        }
        
        let newLenght = task.text.characters.count  + text.characters.count - range.length
        
        if newLenght > 50 {
            let alertView = UIAlertController(title: "Error", message: "Maximum characters allowed 50", preferredStyle: UIAlertControllerStyle.Alert  )
            alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
            return false
        }
        else {
            
            return true
        }
    }
}
