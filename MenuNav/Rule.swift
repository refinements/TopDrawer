//
//  Rule.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - ConditionProtocol

protocol CondtionProtocol {
    var displayDiscription: String {get}
}

// MARK: - Rule

protocol Rule: DictionaryRepresentable {
    
    associatedtype Condition: CondtionProtocol, DecisionTreeElement
    
    static var storageKey: String {get}
    
    init(conditions: [Condition])
    
    var numberOfConditions: Int {get}
    
    var conditions: [Condition] {get}
    
    static func makeDecisionTree() -> DecisionNode<Condition>
}

// MARK: - FormatterSupplier

protocol FormatterProvider {
    
    associatedtype T
    
    func string(from: T) -> String
}


// MARK: - Rule Loader

extension Rule {
    
    static var ruleLoader: RuleLoader<Self> {
        return makeRuleLoader()
    }
    
    static func makeRuleLoader<T>() -> RuleLoader<T> {
        return RuleLoader()
    }
}

class RuleLoader<T: Rule> {
    
    let userDefaults = UserDefaults.standard
    
    var numberOfRules: Int {
        return rules.count
    }
    
    var rules: [T] {
        get {
            let key = T.storageKey
            guard let array = userDefaults.object(forKey: key) as? Array<Dictionary<String, Any>> else {
                return []
            }
            return array.flatMap{ T(dictionaryRepresentation: $0) }
        }
        set {
            let key = T.storageKey
            let array = newValue.map{ $0.dictionaryRepresentation }
            userDefaults.set(array, forKey: key)
            userDefaults.synchronize()
        }
    }
    
    func add(rule: T) {
        rules = rules.appending(rule)
    }
    
    func update(rule: T, atIndex index: Int) {
        var copy = rules
        copy[index] = rule
        rules = copy
    }
    
    func deleteRule(atIndex index: Int) {
        var copy = rules
        copy.remove(at: index)
        rules = copy
    }
}
