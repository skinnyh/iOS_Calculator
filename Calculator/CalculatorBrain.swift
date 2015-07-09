//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Hang Yang on 6/28/15.
//  Copyright (c) 2015 usc. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op : Printable //Protocol
    {
        case Operand(Double)
        case PI(String, Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        
        var description: String { //protocol properties
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                case .PI(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
        
        var precedence: Int {
            get {
                switch self {
                case .BinaryOperation(_,let precedence, _):
                    return precedence
                default:
                    return Int.max
                }
            }
        }
    }
    
    private var opStack = [Op]() //Array<Op>
    private var knownOps = [String: Op]()  //Dictionary<Sting, Op>
    private var variableValues = [String: Double]() //Dictionary<String,Double>
    
    var description: String {
        get {
            var (result, ops) = ("", opStack)
            do {
                var current: String
                (current, ops, _) = descript(ops)
                result = result == "" ? current : "\(current), \(result)"
            } while ops.count > 0
            return result
        }
    }
    
    init () { //class initializer
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", 2, *))
        learnOp(Op.BinaryOperation("÷", 2, { $1 * $0 }))
        learnOp(Op.BinaryOperation("+", 1, +))
        learnOp(Op.BinaryOperation("−", 1, { $1 - $0 }))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("ᐩ/-") { -$0 })
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.PI("π", M_PI))
        learnVar("x", value: 10)
        learnVar("y",value: 5)
        learnVar("z",value: 1)
    }
    
    func learnVar(symbol: String, value: Double?) {
        if value != nil {
            variableValues[symbol] = value
        }
    }
    
    private func descript(ops: [Op]) -> (result: String, remainingOps: [Op], precedence: Int) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (String(format: "%g", operand), remainingOps, op.precedence)
            case .PI(let symbol, _):
                return ("π", remainingOps, op.precedence)
            case .Variable(let symbol):
                return (symbol, remainingOps, op.precedence)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = descript(remainingOps)
                var operand = operandEvaluation.result
                if (op.precedence > operandEvaluation.precedence) {
                    operand = "(\(operand))"
                }
                return (symbol + operand, operandEvaluation.remainingOps, op.precedence)
            case .BinaryOperation(let symbol, let precedence, _):
                let op1Evaluation = descript(remainingOps)
                var operand1 = op1Evaluation.result
                if (op.precedence > op1Evaluation.precedence) {
                    operand1 = "(\(operand1))"
                }
                let op2Evaluation = descript(op1Evaluation.remainingOps)
                var operand2 = op2Evaluation.result
                if (op.precedence > op2Evaluation.precedence) {
                    operand2 = "(\(operand2))"
                }
                return (operand2 + symbol + operand1, op2Evaluation.remainingOps, op.precedence)
            }
        }
        return ("?", ops, Int.max)
    }
    
    func descript() -> String {
        let (result, _, _) = descript(opStack)
        return result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        //array and Dict, and int...are structs, pass by value
        //class are pass by reference
        //implicit "let" before every passed param
        
        if !ops.isEmpty {
            var remainingOps = ops //make a copy
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand): //assign the Double to operand
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation): //don't care about the string
                let operandEvaluation = evaluate(remainingOps) //recursion
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .PI(_, let valuePI):
                return (valuePI, remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return(nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func popOperand() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func cleanUpStack() {
        opStack.removeAll()
    }
    
    func cleanUpVar() {
        variableValues.removeAll()
    }
}