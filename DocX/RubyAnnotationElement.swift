//
//  RubyAnnotationElement.swift
//  DocX
//
//  Created by Morten Bertz on 2019/03/10.
//  Copyright © 2019 telethon k.k. All rights reserved.
//

import Foundation
import AEXML

extension CTRubyAnnotation{
    func rubyElement(baseString:NSAttributedString)->AEXMLElement?{
        guard let rubyText=self.rubyText else{return nil}
        
        let rubyElement=AEXMLElement(name: "w:ruby", value: nil, attributes: [:])
        let rubyFormat=AEXMLElement(name: "w:rubyPr")
        rubyElement.addChild(rubyFormat)
        if let font=baseString.attribute(.font, at: 0, effectiveRange: nil) as? NSFont{
            let scaleFactor=CTRubyAnnotationGetSizeFactor(self)
            let size=Int(font.pointSize*scaleFactor*2)
            let rubySizeElement=AEXMLElement(name: "w:hps", value: nil, attributes: ["w:val":String(size)])
            let baseSizeElement=AEXMLElement(name: "w:hpsBaseText", value: nil, attributes: ["w:val":String(Int(font.pointSize*2))])
            let lid=AEXMLElement(name: "w:lid", value: nil, attributes: ["w:val":"ja-JP"])
            let alignment=CTRubyAnnotationGetAlignment(self).alignmentElement
            rubyFormat.addChildren([rubySizeElement,baseSizeElement,lid,alignment])
        }
        
        let rubyTextElementWrapper=AEXMLElement(name: "w:rt", value: nil, attributes: [:])
        rubyElement.addChild(rubyTextElementWrapper)
        let rubyTextElement=AEXMLElement(name: "w:r", value: nil, attributes: ["w:rsidR":"00604B72", "w:rsidRPr":"00604B72"])
        rubyTextElementWrapper.addChild(rubyTextElement)
        
        let rubyRunElement=AEXMLElement(name: "w:rPr")
        rubyTextElement.addChild(rubyRunElement)
        if let font=baseString.attribute(.font, at: 0, effectiveRange: nil) as? NSFont{
            let scaleFactor=CTRubyAnnotationGetSizeFactor(self)
            let size=Int(font.pointSize*scaleFactor*2)
            let sizeElement=AEXMLElement(name: "w:sz", value: nil, attributes: ["w:val":String(size)])
            rubyRunElement.addChildren([sizeElement,FontElement(font: font)].compactMap({$0}))
            
        }
        
        if let color=baseString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor{
            rubyRunElement.addChild(color.colorElement)
        }
       
        
        
        let rubyTextLiteral=AEXMLElement(name: "w:t", value: rubyText, attributes: [:])
        rubyTextElement.addChild(rubyTextLiteral)
        
        let baseElement=AEXMLElement(name: "w:rubyBase", value: nil, attributes: [:])
        rubyElement.addChild(baseElement)
        let baseRun=AEXMLElement(name: "w:r", value: nil, attributes: ["w:rsidR":"00604B72"])
        baseElement.addChild(baseRun)
        
        let baseRunFormat=AEXMLElement(name: "w:rPr", value: nil, attributes: [:])
        baseRun.addChild(baseRunFormat)
        
        if let font=baseString.attribute(.font, at: 0, effectiveRange: nil) as? NSFont, let fontElement=FontElement(font: font){
            baseRunFormat.addChild(fontElement)
        }
        if let color=baseString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor{
            baseRunFormat.addChild(color.colorElement)
        }
        
        
        
        
        let baseLiteral=AEXMLElement(name: "w:t", value: baseString.string, attributes: [:])
        baseRun.addChild(baseLiteral)
        
        return rubyElement
    }
    
    var rubyText:String?{
        let positions:[CTRubyPosition]=[.before,.after,.inline,.interCharacter]
        let text=positions.map({CTRubyAnnotationGetTextForPosition(self, $0)}).compactMap({$0}).first
        return text as String?
        
    }
}

extension CTRubyAlignment{
    #warning("not really implemented")
    var alignmentElement:AEXMLElement{
        switch self {
        default:
            return AEXMLElement(name: "w:rubyAlign", value: nil, attributes: ["w:val":"center"])
        }
    }
}
