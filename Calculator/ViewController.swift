//
//  ViewController.swift
//  Calculator
//
//  Created by Hang Yang on 6/18/15.
//  Copyright (c) 2015 usc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var input: UILabel!
    
    var userIsInTheMiddleOfTypingNumber = false
    
    var brain = CalculatorBrain() // Use the Model
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle! //unwrap the optional
        //println("digit = \(digit)")
        if (digit != "." || display.text!.rangeOfString(".") == nil || (!userIsInTheMiddleOfTypingNumber && digit == ".")) {
            if userIsInTheMiddleOfTypingNumber {
                display.text = display.text! + digit
            } else {
                display.text = digit
                userIsInTheMiddleOfTypingNumber = true
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        
        func addEqualSign() {
            if input.text!.rangeOfString("=") != nil {
                input.text!.removeRange(input.text!.rangeOfString("=")!)
            }
            input.text! += "="
        }
        let operation = sender.currentTitle!
        
        //special case for changing sign
        if userIsInTheMiddleOfTypingNumber && operation == "ᐩ/-" {
            display.text = "\(-displayValue!)"
            return
        }
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        displayValue = brain.performOperation(operation)
        addEqualSign()
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        let symbol = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingNumber {
            enter()
        }
        displayValue = brain.pushOperand(symbol)
    }
    
    
    @IBAction func setVariable(sender: AnyObject) {
        userIsInTheMiddleOfTypingNumber = false;
        brain.learnVar("M", value: displayValue)
        displayValue = brain.evaluate()
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingNumber = false;
        displayValue = brain.pushOperand(displayValue!)
    }
    
    @IBAction func cleanUp() {
        display.text = "0"
        input.text = "0"
        userIsInTheMiddleOfTypingNumber = false
        brain.cleanUpStack()
        brain.cleanUpVar()
    }
    
    @IBAction func backSpace() {
        if userIsInTheMiddleOfTypingNumber {
            if countElements(display.text!) == 1 {
                userIsInTheMiddleOfTypingNumber = false
                display.text = "0"
            } else {
                display.text = dropLast(display.text!)
            }
        } else {
            displayValue = brain.popOperand()
        }
    }
    
    var displayValue: Double? {
        get {
//            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            return (display.text! as NSString).doubleValue
        }
        set {
            if (newValue == nil) {
                display.text = " " //set display to empty when result is nil
            } else {
                display.text = "\(newValue!)"
            }
            userIsInTheMiddleOfTypingNumber = false;
            input.text = brain.description
        }
    }
}

