//
//  PrimaryButtonStyle.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 4/23/23.
//

import SwiftUI

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .cornerRadius(10)
    }
}

struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Sign In", action: {})
            .buttonStyle(.primary)
            .padding()
            .previewLayout(.sizeThatFits)
            .disabled(true)
    }
}
