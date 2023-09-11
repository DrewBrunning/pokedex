//
//  DynamicStack.swift
//  Pokedex
//
//  Created by Drew Brunning on 9/11/23.
//

import SwiftUI

struct DynamicStack<Content: View>: View {
    var horizontalAlignment = HorizontalAlignment.center
    var verticalAlignment = VerticalAlignment.center
    var spacing: CGFloat?
    
    @ViewBuilder var content: () -> Content
    
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        switch sizeClass {
        case .regular:
            hStack
        case .compact, .none:
            vStack
        @unknown default:
            vStack
        }
    }
    
    var hStack: some View {
        HStack(
            alignment: verticalAlignment,
            spacing: spacing,
            content: content
        )
    }

    var vStack: some View {
        VStack(
            alignment: horizontalAlignment,
            spacing: spacing,
            content: content
        )
    }
}

struct DynamicStack_Previews: PreviewProvider {
    static var previews: some View {
        DynamicStack {
            Text("First")
            Text("Second")
            Text("Third")
        }
    }
}
