//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import Foundation
import SwiftUI

struct RoundedFilledButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .padding()
            .foregroundColor(.white)
            .background(
                Color(configuration.isPressed ? Theme.Colors.Controls.highlighed : Theme.Colors.Controls.active)
            )
            .cornerRadius(Theme.Metrics.cornerRadius)
    }
}

struct RoundedFilledInactiveButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .padding()
            .foregroundColor(.white)
            .background(Color(Theme.Colors.Controls.inactive))
            .cornerRadius(Theme.Metrics.cornerRadius)
            .disabled(true)
    }
}

struct LinkButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .padding()
            .foregroundColor(
                Color(configuration.isPressed ? Theme.Colors.Text.themeHighlighted : Theme.Colors.Text.theme)
            )
            .background(Color(.clear))
    }
}

struct TextLinkButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .padding()
            .foregroundColor(
                Color(configuration.isPressed ? Theme.Colors.Text.themeHighlighted : Theme.Colors.Text.theme)
            )
            .background(Color(.clear))
    }
}

struct NoPaddingLinkButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .foregroundColor(
                Color(configuration.isPressed ? Theme.Colors.Text.themeHighlighted : Theme.Colors.Text.theme)
            )
            .background(Color(.clear))
    }
}