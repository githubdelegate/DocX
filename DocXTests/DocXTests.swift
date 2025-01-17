//
//  DocXTests.swift
//  DocXTests
//
//  Created by Morten Bertz on 2019/03/10.
//  Copyright © 2019 telethon k.k. All rights reserved.
//

#if os(macOS)
import XCTest
@testable import DocX
import AppKit

class DocXTests: XCTestCase {

    var tempURL:URL=URL(fileURLWithPath: "")
    
    
    override func setUp() {
        let url=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        do{
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
            self.tempURL=url
        }
        catch let error{
            print(error)
            XCTFail()
        }
        
    }
    
    override func tearDown() {
        do{
            try FileManager.default.removeItem(at: self.tempURL)
        }
        catch let error{
            print(error)
            XCTFail()
        }
    }
    
    
    
    func testWriteDocX(attributedString:NSAttributedString, useBuiltin:Bool = false){
        
        do{
            let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\(attributedString.string.prefix(10))").appendingPathExtension("docx")
            try attributedString.writeDocX(to: url, useBuiltIn: useBuiltin)
            var readAttributes:NSDictionary?=nil
            let docXString=try NSAttributedString(url: url, options: [:], documentAttributes: &readAttributes)
            guard let attributes=readAttributes as? [String:Any] else{
                XCTFail()
                return
            }
            XCTAssertEqual(attributes[NSAttributedString.DocumentAttributeKey.documentType.rawValue] as! String, NSAttributedString.DocumentType.officeOpenXML.rawValue)
            let string=docXString.string
            print(string)
            XCTAssertEqual(docXString.string, string)
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    
    func testBlank(){
        let string=""
        let attributedString=NSAttributedString(string: string)

        testWriteDocX(attributedString: attributedString)
    }

    func test山田Plain() {
        let string="山田"
        testWriteDocX(attributedString: NSAttributedString(string: string))
    }

    func test山田Attributed() {
        let string="山田"
        let attributed=NSAttributedString(string: string, attributes: [.font:NSFont.systemFont(ofSize: NSFont.systemFontSize)])
        testWriteDocX(attributedString: attributed)
    }

    func test山田FuriganaAttributed() {
        let string="山田"
        let furigana="やまだ"
        let ruby=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, furigana as CFString, [kCTRubyAnnotationSizeFactorAttributeName:0.5] as CFDictionary)
        let rubyKey=NSAttributedString.Key(kCTRubyAnnotationAttributeName as String)
        let attributed=NSAttributedString(string: string, attributes: [.font:NSFont.systemFont(ofSize: NSFont.systemFontSize), rubyKey:ruby])
        testWriteDocX(attributedString: attributed)
    }


    var yamadaDenkiString:NSMutableAttributedString{
        let string="山田電気"
        let furigana="やまだ"
        let sizeFactorDictionary=[kCTRubyAnnotationSizeFactorAttributeName:0.5] as CFDictionary
        let yamadaRuby=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, furigana as CFString, sizeFactorDictionary)

        let rubyKey=NSAttributedString.Key(kCTRubyAnnotationAttributeName as String)
        let attributedString=NSMutableAttributedString(string: string, attributes: [.font:NSFont.systemFont(ofSize: NSFont.systemFontSize), .foregroundColor:NSColor.red])
        attributedString.addAttributes([rubyKey:yamadaRuby], range: NSRange(location: 0, length: 2))
        let denkiRuby=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, "でんき" as CFString, sizeFactorDictionary)
        attributedString.addAttributes([rubyKey:denkiRuby], range: NSRange(location: 2, length: 2))
        return attributedString
    }

    func test山田電気FuriganaAttributed() {
        testWriteDocX(attributedString: yamadaDenkiString)
    }

    func test山田電気FuriganaAttributed_ParagraphStyle() {
        let attributed=yamadaDenkiString
        let style=NSParagraphStyle.default
        attributed.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attributed.length))
        testWriteDocX(attributedString: attributed)

    }

    func test山田電気FuriganaAttributed_ParagraphStyle_vertical() {
        let attributed=yamadaDenkiString
        let style=NSParagraphStyle.default
        attributed.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attributed.length))
        attributed.addAttribute(.verticalForms, value: true, range:NSRange(location: 0, length: attributed.length))
        testWriteDocX(attributedString: attributed)
    }

    func test山田電気FuriganaAttributed_ParagraphStyle_bold() {
        let attributed=yamadaDenkiString
        let style=NSParagraphStyle.default
        attributed.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attributed.length))
        let boldFont=NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
        attributed.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: 2))
        testWriteDocX(attributedString: attributed)

    }

    //crashes the cocoa docx writer!
    func test山田電気FuriganaAttributed_ParagraphStyle_underline() {
        let attributed=yamadaDenkiString
//        let style=NSParagraphStyle.default
//        attributed.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attributed.length))
        let underlineStyle:NSUnderlineStyle = .single
        attributed.addAttribute(.underlineStyle, value: underlineStyle.rawValue, range:NSRange(location: 0, length: attributed.length))
        testWriteDocX(attributedString: attributed)
    }

    func test山田電気FuriganaAttributed_ParagraphStyle_backgroundColor() {
        let attributed=yamadaDenkiString
        let style=NSMutableParagraphStyle()
        style.setParagraphStyle(NSParagraphStyle.default)
        style.alignment = .center
        attributed.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attributed.length))

        attributed.addAttribute(.backgroundColor, value: NSColor.blue, range:NSRange(location: 0, length: attributed.length))
        testWriteDocX(attributedString: attributed)

    }
    func test山田電気FuriganaAttributed_ParagraphStyle_strikethrough() {
        let attributed=yamadaDenkiString
        //        let style=NSParagraphStyle.default
        //        attributed.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attributed.length))
        let underlineStyle:NSUnderlineStyle = [.single]
        attributed.addAttribute(.strikethroughStyle, value: underlineStyle.rawValue, range:NSRange(location: 0, length: attributed.length))
        testWriteDocX(attributedString: attributed)
        
        sleep(1)
    }
    
    func testLink(){
        let string="楽天 https://www.rakuten-sec.co.jp/"
        let attributed=NSMutableAttributedString(string: string)
        attributed.addAttributes([.font:NSFont.systemFont(ofSize: NSFont.systemFontSize)], range: NSRange(location: 0, length: attributed.length))
        let furigana="らくてん"
        let furiganaAnnotation=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, furigana as CFString, [kCTRubyAnnotationSizeFactorAttributeName:0.5] as CFDictionary)
        attributed.addAttribute(.ruby, value: furiganaAnnotation, range: NSRange(location: 0, length: 2))
        attributed.addAttribute(.link, value: URL(string: "https://www.rakuten-sec.co.jp/")!, range: NSRange(location: 3, length: 30))
        testWriteDocX(attributedString: attributed, useBuiltin: false)
        
        sleep(1)
    }
    
    
    
    
    func test_ParagraphStyle() {
        let string =
        """
This property contains the space (measured in points) added at the end of the paragraph to separate it from the following paragraph. This value is always nonnegative. The space between paragraphs is determined by adding the previous paragraph’s paragraphSpacing and the current paragraph’s paragraphSpacingBefore.
Specifies the border displayed above a set of paragraphs which have the same set of paragraph border settings. Note that if the adjoining paragraph has identical border settings and a between border is specified, a single between border will be used instead of the bottom border for the first and a top border for the second.
"""
        
        let style=NSMutableParagraphStyle()
        style.setParagraphStyle(NSParagraphStyle.default)
        style.alignment = .left
        style.paragraphSpacing=20
        style.lineHeightMultiple=1.5
        //style.firstLineHeadIndent=20
        style.headIndent=20
        style.tailIndent=20
        
        let font=NSFont(name: "Helvetica", size: 13) ?? NSFont.systemFont(ofSize: 13)
        
        let attributed=NSMutableAttributedString(string: string, attributes: [.paragraphStyle:style, .font:font])
        testWriteDocX(attributedString: attributed, useBuiltin: false)
       
    }
    
    func testOutline(){
        let outlineString=NSAttributedString(string: "An outlined String\r", attributes: [.font:NSFont.systemFont(ofSize: 13),.strokeWidth:3,.strokeColor:NSColor.green, .foregroundColor:NSColor.blue, .backgroundColor:NSColor.orange])
        let outlinedAndStroked=NSMutableAttributedString(attributedString: outlineString)
        outlinedAndStroked.addAttribute(.strokeWidth, value: -3, range: NSRange(location: 0, length: outlinedAndStroked.length))
        let noBG=NSMutableAttributedString(attributedString: outlineString)
        noBG.removeAttribute(.backgroundColor, range: NSMakeRange(0, noBG.length))
        noBG.append(outlinedAndStroked)
        noBG.append(outlineString)
        
        testWriteDocX(attributedString: noBG)
    
    }
    
    func testComposite(){
        let rootAttributedString = NSMutableAttributedString()
        
        rootAttributedString.append(NSAttributedString(string: "blah blah blah 1 ... but more text"))
        rootAttributedString.append(NSAttributedString(string: "blah blah blah 2 ... more text here also"))
        
        testWriteDocX(attributedString: rootAttributedString, useBuiltin: true)
        
    }
    
    func testMultipage(){
        let longString = """
            1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            
            2. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            
            3. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            4. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            
            5. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """
        let attributed=NSAttributedString(string: longString, attributes: [.font:NSFont.systemFont(ofSize: 20)])
        testWriteDocX(attributedString: attributed, useBuiltin: true)
        
    }
    
    func testImage() throws{
        let longString = """
            1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """
        let imageURL=URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Picture1.png")
        let imageData=try XCTUnwrap(Data(contentsOf: imageURL), "Image not found")
        let attachement=NSTextAttachment(data: imageData, ofType: kUTTypePNG as String)
        let attributed=NSAttributedString(string: longString, attributes: [.foregroundColor: NSColor.green])
        let imageString=NSAttributedString(attachment: attachement)
        let result=NSMutableAttributedString()
        result.append(attributed)
        result.append(imageString)
        testWriteDocX(attributedString: result, useBuiltin: false)
    }
    
    func testImageAndLink() throws{
        let longString = """
        1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """
        let imageURL=URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Picture1.png")
        let imageData=try XCTUnwrap(Data(contentsOf: imageURL), "Image not found")
        let attachement=NSTextAttachment(data: imageData, ofType: kUTTypePNG as String)
        let attributed=NSMutableAttributedString(string: longString, attributes: [:])
        attributed.addAttributes([.link:URL(string: "http://officeopenxml.com/index.php")!], range: NSRange(location: 2, length: 6))
        let imageString=NSAttributedString(attachment: attachement)
        let result=NSMutableAttributedString()
        result.append(attributed)
        result.append(imageString)
        testWriteDocX(attributedString: result, useBuiltin: false)
    }
    
    func test2Images() throws{
        let longString = """
        1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum\r.
        """
        let imageURL=URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Picture1.png")
        let imageData=try XCTUnwrap(Data(contentsOf: imageURL), "Image not found")
        let attachement=NSTextAttachment(data: imageData, ofType: kUTTypePNG as String)
        let attributed=NSMutableAttributedString(string: longString, attributes: [:])
        attributed.addAttributes([.link:URL(string: "http://officeopenxml.com/index.php")!], range: NSRange(location: 2, length: 6))
        let imageString=NSAttributedString(attachment: attachement)
        let result=NSMutableAttributedString()
        result.append(attributed)
        result.append(imageString)
        result.append(attributed)
        result.append(imageString)
        result.append(attributed)
        testWriteDocX(attributedString: result, useBuiltin: false)
    }
    
    func testMultiPage() {
        let string =
        """
This property contains the space (measured in points) added at the end of the paragraph to separate it from the following paragraph. This value is always nonnegative. The space between paragraphs is determined by adding the previous paragraph’s paragraphSpacing and the current paragraph’s paragraphSpacingBefore.
Specifies the border displayed above a set of paragraphs which have the same set of paragraph border settings. Note that if the adjoining paragraph has identical border settings and a between border is specified, a single between border will be used instead of the bottom border for the first and a top border for the second.
"""
        
       
        let font=NSFont(name: "Helvetica", size: 13) ?? NSFont.systemFont(ofSize: 13)
        
        let attributed=NSMutableAttributedString(string: string, attributes: [.font:font])
        let attr_break=NSAttributedString(string: "\r", attributes: [.breakType:BreakType.page])
        
        let result=NSMutableAttributedString()
        result.append(attributed)
        result.append(attr_break)
        result.append(attributed)
        
        testWriteDocX(attributedString: result, useBuiltin: false)
       
    }
    
    func testMultiPageWriter() {
        
        let string =
        """
This property contains the space (measured in points) added at the end of the paragraph to separate it from the following paragraph. This value is always nonnegative. The space between paragraphs is determined by adding the previous paragraph’s paragraphSpacing and the current paragraph’s paragraphSpacingBefore.
Specifies the border displayed above a set of paragraphs which have the same set of paragraph border settings. Note that if the adjoining paragraph has identical border settings and a between border is specified, a single between border will be used instead of the bottom border for the first and a top border for the second.
"""
        
       
        let font=NSFont(name: "Helvetica", size: 13) ?? NSFont.systemFont(ofSize: 13)
        
        let attributed=NSMutableAttributedString(string: string, attributes: [.font:font])
        
        let numPages=10
        
        let pages=Array(repeating: attributed, count: numPages)
        
        let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\(attributed.string.prefix(10))").appendingPathExtension("docx")
        
        do{
            try DocXWriter.write(pages: pages, to: url)
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testImageAndLinkMetaData() throws{
        let longString = """
        1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """
        let imageURL=URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Picture1.png")
        let imageData=try XCTUnwrap(Data(contentsOf: imageURL), "Image not found")
        let attachement=NSTextAttachment(data: imageData, ofType: kUTTypePNG as String)
        let attributed=NSMutableAttributedString(string: longString, attributes: [:])
        attributed.addAttributes([.link:URL(string: "http://officeopenxml.com/index.php")!], range: NSRange(location: 2, length: 6))
        let imageString=NSAttributedString(attachment: attachement)
        let result=NSMutableAttributedString()
        result.append(attributed)
        result.append(imageString)
        
        var options=DocXOptions()
        options.author="Barack Obama"
        options.createdDate = .init(timeIntervalSinceNow: -100000)
        options.keywords=["Lorem", "Ipsum", "a longer keyword"]
        options.description="Take a bike out for a spin"
        options.title="Lorem Ipsum String + Image"
        options.subject="Test Metadata"
        let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\(longString.prefix(10))").appendingPathExtension("docx")
        try result.writeDocX(to: url, options: options)
        var readAttributes:NSDictionary?=nil
        let docXString=try NSAttributedString(url: url, options: [:], documentAttributes: &readAttributes)
        guard let attributes=readAttributes as? [String:Any] else{
            XCTFail()
            return
        }
        XCTAssertEqual(attributes[NSAttributedString.DocumentAttributeKey.documentType.rawValue] as! String, NSAttributedString.DocumentType.officeOpenXML.rawValue)
        XCTAssertEqual(docXString.string.prefix(10), result.string.prefix(10))
    }
    
    func testMichaelKnight(){
        let font = NSFont(name: "Helvetica", size: 13)!
        let string = NSAttributedString(string: "The Foundation For Law and Government favours Helvetica.", attributes: [.font: font])

        var options = DocXOptions()
        options.author = "Michael Knight"
        options.title = "Helvetica Document"

        let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\(string.string.prefix(10))").appendingPathExtension("docx")
        do{
            try string.writeDocX(to: url, options:options)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
        
    }
    
    
    
    func testLenna_size() throws{
        let longString = """
        1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum\r.
        """
        let imageURL=URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("lenna.png")
        let imageData=try XCTUnwrap(Data(contentsOf: imageURL), "Image not found")
        let attachement=NSTextAttachment(data: imageData, ofType: kUTTypePNG as String)
        attachement.bounds=CGRect(x: 0, y: 0, width: 128, height: 128)
        
        let attributed=NSMutableAttributedString(string: longString, attributes: [:])
//        attributed.addAttributes([.link:URL(string: "http://officeopenxml.com/index.php")!], range: NSRange(location: 2, length: 6))
        let imageString=NSAttributedString(attachment: attachement)
        let result=NSMutableAttributedString()
        result.append(attributed)
        result.append(imageString)
        result.append(attributed)
//        result.append(attributed)
        testWriteDocX(attributedString: result, useBuiltin: false)
    }
    
    
    
    @available(macOS 12, *)
    func testAttributed(){
        var att=AttributedString("Lorem ipsum dolor sit amet")
        att.strokeColor = .green
        att.strokeWidth = -2
        att.font = NSFont(name: "Helvetica", size: 12)
        att.foregroundColor = .gray
        let title=String(att.characters.prefix(10))
        let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\(title)").appendingPathExtension("docx")
        print(url.absoluteString)
        do{
            try att.writeDocX(to: url)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
        
    }
    
    @available(macOS 12, *)
    
    func testMarkdown()throws{
        let mD="~~This~~ is a **Markdown** *string*."
        let att=try AttributedString(markdown: mD)
        let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\("Markdown")").appendingPathExtension("docx")
        try att.writeDocX(to: url)
    }
    
    @available(macOS 12, *)
    func testMarkdown_linkNewline()throws{
        let mD =
"""
~~This~~ is a **Markdown** *string*.\\
And this is a [link](http://www.example.com).
"""
                             
        let att=try AttributedString(markdown: mD)
        let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\("Markdown")").appendingPathExtension("docx")
        try att.writeDocX(to: url)
    }
    
   
    
    @available(macOS 12, *)
    func testMarkdown_Image()throws{
        
#if SWIFT_PACKAGE
        let bundle=Bundle.module
#else
        let bundle=Bundle(for: DocXTests.self)
#endif
        
        let url=try XCTUnwrap(bundle.url(forResource: "lenna", withExtension: "md"))

        let att=try AttributedString(contentsOf: url, baseURL: url.deletingLastPathComponent())
        let imageRange=try XCTUnwrap(att.range(of: "This is an image"))
        let imageURL=try XCTUnwrap(att[imageRange].imageURL)
        let imageURLInBundle=try XCTUnwrap(bundle.url(forResource: "lenna", withExtension:"png"))
        XCTAssertEqual(imageURL.absoluteString, imageURLInBundle.absoluteString)
        let temp=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\("Markdown_image")").appendingPathExtension("docx")
        try att.writeDocX(to: temp)
    }
    
    @available(macOS 12, *)
    func testMarkdown_mixed()throws{
        let mD =
"""
~~This~~ is a **Markdown** *string*.\\
And this is a [link](http://www.example.com).
"""
                             
        var att=try AttributedString(markdown: mD)
        att[att.range(of: "This")!].foregroundColor = .red
        let url=self.tempURL.appendingPathComponent(UUID().uuidString + "_myDocument_\("Markdown")").appendingPathExtension("docx")
        try att.writeDocX(to: url)
    }

}

#endif

