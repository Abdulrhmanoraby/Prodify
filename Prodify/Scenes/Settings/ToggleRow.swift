//
//  ToggleRow.swift
//  Settings2
//
//  Created by Ahmed Tarek on 05/11/2025.
//

import SwiftUI

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
        }
        .padding(.vertical, 6)
    }
}


