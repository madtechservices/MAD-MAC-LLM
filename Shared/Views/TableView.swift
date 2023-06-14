//
//  TableView.swift
//  Stoic
//
//  Created by PEXAVC on 5/2/23.
//

/* Basic TableView starter implementation w/ resultBuilder
 
 Example Usage:
 
 TableView {
     TableRow(text: .init("Table Row 1")) {
         // action
     }
 }.tableViewStyle(.init(title: "TableView",
                        rowHeight: 66,
                        paddingRow: .init(12, 0)))
 
 
 */

import Foundation
import SwiftUI

//MARK: TableView

public struct TableView : View {
    @Environment(\.tableViewStyle) var style
    
    @State var toggleDropdown: Bool = false
    
    let rows: (() -> [TableRow])
    
    init(@TableRowBuilder rows : @escaping () -> [TableRow]) {
        self.rows = rows
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = style.title {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, style.paddingRow.leading)
                    .font(Fonts.live(.headline, .bold))
            }
            
            ForEach(rows()) { row in
                if style.showSeperators {
                    seperator
                }
                
                TableRowView(row: row)
                    .environment(\.tableViewStyle, style)
                    .onTapGesture {
                        if case let .dropdown(properties) = row.kind {
                            properties.selector.wrappedValue = "nice"
                        }
                        switch row.kind {
                        case .dropdown:
                            toggleDropdown.toggle()
                        default:
                            if row.kind.isInteractable {
                                row.action?()
                            }
                        }
                    }
            }
            
            if style.showSeperators {
                seperator
            }
        }
        .padding(style.paddingTable)
        .background(style.background)
    }
    
    var seperator: some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .foregroundColor(Color.white.opacity(0.66))
            .padding(.leading, style.paddingRow.leading)
    }
}

//MARK: TableRow

public struct TableRowView: View {
    @Environment(\.tableViewStyle) var style
    
    let row: TableRow
    @State var isHovering: Bool = false
    
    public var body: some View {
        HStack(spacing: 16) {
            if let graphic = row.graphicModel {
                IconView(systemName: graphic.leading,
                         bgColor: graphic.leadingBGColor,
                         withBlur: false,
                         withTexture: graphic.texture)
                    .padding(.vertical, 24)
            }
            
            Text(row.textModel.leading)
                .foregroundColor(.foreground)
                .font(Fonts.live(row.textModel.fontSize, .bold))
            
            if let subleading = row.textModel.subLeading {
                Text(subleading)
                    .foregroundColor(.foreground)
                    .font(Fonts.live(row.textModel.subheadlineFontSize, .regular))
            }
            
            Spacer()
            
            switch row.kind {
            case .dropdown:
                Image(systemName: "arrowtriangle.down.fill")
                    .frame(width: 12, height: 12)
            case .toggle:
                if let trailingText = row.textModel.trailing {
                    Text(trailingText)
                }
            case .label(let color):
                if let trailingText = row.textModel.trailing {
                    Text(trailingText)
                        .font(Fonts.live(.footnote, .bold))
                        .padding(.vertical, 4)
                        .foregroundColor(color)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(color,
                                              lineWidth: 2)
                                .padding(.horizontal, -6)
                        )
                        .padding(.horizontal, 6)
                }
            default:
                if let trailingText = row.textModel.trailing {
                    Text(trailingText)
                }
            }
        }
        .padding(style.paddingRow)
        .frame(maxWidth: .infinity)
        .frame(height: style.rowHeight)
        .background(isHovering ? Color.accentColor : style.backgroundColor)
        .onHover { isHovered in
            DispatchQueue.main.async { //<-- Here
                self.isHovering = isHovered
                if self.isHovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

public enum TableRowKind {
    case dropdown(DropdownProperties)
    case toggle
    case label(Color)
    case none
    
    public struct DropdownProperties {
        let options: [String]
        let selector: Binding<String>
    }
    
    var isInteractable: Bool {
        switch self {
        case .dropdown, .toggle:
            return false
        default:
            return true
        }
    }
}

public struct TableRow : Identifiable, Hashable, Equatable {
    public let id: UUID = .init()
    
    var index: Int = 0
    let kind: TableRowKind
    let textModel: TextModel
    let graphicModel: GraphicModel?
    let action: (() -> Void)?
    
    init(kind: TableRowKind = .none,
         text: TextModel,
         graphic: GraphicModel? = nil,
         _ action: (() -> Void)? = nil) {
        self.kind = kind
        self.textModel = text
        self.graphicModel = graphic
        self.action = action
    }
    
    struct TextModel {
        let leading: LocalizedStringKey
        let subLeading: LocalizedStringKey?
        let trailing: LocalizedStringKey?
        let fontSize: Fonts.FontSize
        let subheadlineFontSize: Fonts.FontSize
        
        init(_ leading: LocalizedStringKey,
             subLeading: LocalizedStringKey? = nil,
             trailing: LocalizedStringKey? = nil,
             fontSize: Fonts.FontSize = .headline,
             subheadlineFontSize: Fonts.FontSize = .subheadline) {
            self.leading = leading
            self.subLeading = subLeading
            self.trailing = trailing
            self.fontSize = fontSize
            self.subheadlineFontSize = subheadlineFontSize
        }
    }
    
    struct GraphicModel {
        let leading: String
        let trailing: String?
        let leadingBGColor: Color
        let texture: Bool
        
        init(_ leading: String, leadingBGColor: Color, trailing: String? = nil, texture: Bool = false) {
            self.leading = leading
            self.leadingBGColor = leadingBGColor
            self.trailing = trailing
            self.texture = texture
        }
    }
    
    public mutating func updateIndex(_ index: Int) -> TableRow {
        self.index = index
        return self
    }
    
    //Equatable & Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: TableRow, rhs: TableRow) -> Bool {
        lhs.id == rhs.id
    }
}

//MARK: TableViewStyle

public struct TableViewStyle {
    let title: LocalizedStringKey?
    let rowHeight: CGFloat
    let showSeperators: Bool
    let backgroundColor: Color
    let background: AnyView
    let paddingRow: EdgeInsets
    let paddingTable: EdgeInsets
    
    public init(title: LocalizedStringKey? = nil,
                rowHeight: CGFloat = 75,
                showSeperators: Bool = true,
                backgroundColor: Color = .clear,
                paddingRow: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                paddingTable: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                @ViewBuilder background: (() -> some View) = { EmptyView() }) {
        self.title = title
        self.rowHeight = rowHeight
        self.showSeperators = showSeperators
        self.backgroundColor = backgroundColor
        self.paddingRow = paddingRow
        self.paddingTable = paddingTable
        self.background = AnyView(background())
    }
}

private struct TableViewStyleKey: EnvironmentKey {
    static let defaultValue: TableViewStyle = .init() { }
}

extension EnvironmentValues {
    var tableViewStyle: TableViewStyle {
        get { self[TableViewStyleKey.self] }
        set { self[TableViewStyleKey.self] = newValue }
    }
}

extension View {
    func tableViewStyle(_ style: TableViewStyle) -> some View {
        return self.environment(\.tableViewStyle, style)
    }
}

//MARK: TableRow ResultBuilder

public protocol TableViewRowGroup {
    
    var rows : [TableRow] { get }
    
}

extension TableRow : TableViewRowGroup {
    
    public var rows: [TableRow] {
        [self]
    }
    
}

extension Array: TableViewRowGroup where Element == TableRow {
    
    public var rows: [TableRow] {
        self
    }
    
}

@resultBuilder public struct TableRowBuilder {
    
    public static func buildBlock() -> [TableRow] {
        []
    }
    
    public static func buildBlock(_ row : TableRow) -> [TableRow] {
        [row]
    }
    
    public static func buildBlock(_ rows: TableViewRowGroup...) -> [TableRow] {
        rows.flatMap { $0.rows }
    }
    
    public static func buildEither(first row: [TableRow]) -> [TableRow] {
        row
    }
    
    public static func buildEither(second row: [TableRow]) -> [TableRow] {
        row
    }
    
    public static func buildOptional(_ rows: [TableRow]?) -> [TableRow] {
        rows?.flatMap { $0.rows } ?? []
    }
    
}
