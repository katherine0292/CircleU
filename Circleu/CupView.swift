//
//  CupView.swift
//  Circleu
//
//  Created by David Oyarekhua on 3/6/2026.
//

import SwiftUI

struct CupView: View {
    
    // These are properties your view accepts
    
    var guest: Guest = Guest(name: "Shuvam", prefersSugar: true, yearOfBirth: 1996, vehicle: .semitruck)
    
    // If things change on your screen use state properties
    
    @State private var degree: Double = 0
    
    // This is your View
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 999)
                    .frame(width: 100, height: 12)
                    .foregroundStyle(cupColor.opacity(0.3))
                Rectangle()
                    .frame(width: 80, height: 100)
                    .foregroundStyle(cupColor)
            }
            Text(nameInitials)
                .foregroundStyle(Color.white)
                .font(.largeTitle)
                .fontWeight(.heavy)
        }
        
        
        .rotationEffect(.degrees(degree))
        .onTapGesture {
            flipCup()
        }
    }
    
    // These are Computed Properties
    
    var cupColor: Color {
        if guest.prefersSugar == true {
            return Color.pink
        } else {
            return Color.cyan
        }
    }
    
    var nameInitials: String {
        return String(guest.name.prefix(2).uppercased())
    }
    
    // These are functions
    
    func flipCup() {
        withAnimation {
            degree = degree + 180
        }
    }
}

#Preview {
    CupView()
}
