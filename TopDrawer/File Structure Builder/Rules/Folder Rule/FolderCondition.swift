//
//  FolderCondition.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

enum FolderCondition {
    case path(PathMatcher)
    case name(StringMatcher)
    case contains(FolderContentsMatcher)
    case doesntContain(FolderContentsMatcher)
    
    func matches(directory: Directory) -> Bool {
        
        switch self {
        case let .path(pathMatcher):
            return pathMatcher.matches(string: directory.path)
        case let .name(stringMatcher):
            return stringMatcher.matches(string: directory.name)
        case let .contains(contentsMatcher):
            return contentsMatcher.matches(directory: directory)
        case let .doesntContain(contentsMatcher):
            return !contentsMatcher.matches(directory: directory)
        }
    }
   }

// MARK: - Equatable

extension FolderCondition: Equatable {
    
    static func == (lhs: FolderCondition, rhs: FolderCondition) -> Bool {
        switch (lhs, rhs) {
        case let (.path(pathMatcher1), .path(pathMatcher2)):
            return pathMatcher1 == pathMatcher2
        case let (.name(stringMatcher1), .name(stringMatcher2)):
            return stringMatcher1 == stringMatcher2
        case let (.contains(contentsMatcher1), .contains(contentsMatcher2)):
            return contentsMatcher1 == contentsMatcher2
        case let (.doesntContain(contentsMatcher1), .doesntContain(contentsMatcher2)):
            return contentsMatcher1 == contentsMatcher2
        default:
            return false
        }
    }
}

// MARK: - ConditionProtocol

extension FolderCondition: ConditionProtocol {
 
    var displayDescription: String {
        let formatter = FolderConditionFormatter()
        return formatter.string(fromCondition: self)
    }
    
    func attributedDisplayDescription(withAttributes attributes: ConditionFormatterAttributes) -> NSAttributedString {
        let formatter = FolderConditionFormatter()
        return formatter.attributedString(fromCondition: self, withAttributes: attributes)
    }
}

// MARK: - DecisionTreeElement

extension FolderCondition: DecisionTreeElement {
    
    func decisionTreeInput() -> String {
        switch self {
        case let .contains(contentsMatcher):
            return contentsMatcher.inputString
        case let .doesntContain(contentsMatcher):
            return contentsMatcher.inputString
        case let .name(stringMatcher):
            return stringMatcher.inputString
        case let .path(pathMatcher):
            return pathMatcher.inputString
        }
    }
}

// MARK: - DictionaryRepresentable

extension FolderCondition: DictionaryRepresentable {
    
    struct Keys {
        static let CaseKey = "CaseKey"
        struct Case {
            static let Path = "Path"
            static let Name = "Name"
            static let Contains = "Contains"
            static let DoesntContain = "DoesntContain"
        }
        static let AssociatedValue = "AssociatedValue"
    }
    
    init?(dictionaryRepresentation dictionary: [String: Any]) {
        
        guard let caseType = dictionary[Keys.CaseKey] as? String else {
            return nil
        }
        
        var result: FolderCondition?
        
        switch caseType {
        case Keys.Case.Path:
            
            if let pathMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let pathMatcher = PathMatcher(dictionaryRepresentation: pathMatcherDictionary) {
                result = .path(pathMatcher)
            }
            
        case Keys.Case.Name:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .name(stringMatcher)
            }
            
        case Keys.Case.Contains:
            
            if let contentsMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let contentsMatcher = FolderContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
                result = .contains(contentsMatcher)
            }
            
        case Keys.Case.DoesntContain:
            
            if let contentsMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let contentsMatcher = FolderContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
                result = .doesntContain(contentsMatcher)
            }
            
        default:
            break
        }
        
        if let result = result {
            self = result
        } else {
            return nil
        }
    }
    
    var dictionaryRepresentation: [String: Any] {
        
        var dictionary = [String: Any]()
        
        switch self {
        case let .path(pathMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.Path
            dictionary[Keys.AssociatedValue] = pathMatcher.dictionaryRepresentation
            
        case let .name(stringMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.Name
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation
            
        case let .contains(contentsMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.Contains
            dictionary[Keys.AssociatedValue] = contentsMatcher.dictionaryRepresentation
            
        case let .doesntContain(contentsMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.DoesntContain
            dictionary[Keys.AssociatedValue] = contentsMatcher.dictionaryRepresentation
        }
        
        return dictionary
    }
    
}
