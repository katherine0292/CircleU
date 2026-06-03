//
//  partyCup2.swift
//  Circleu
//
//  Created by David Oyarekhua on 2/6/2026.
//

import SwiftUI

struct Cup {
    var color : Color
    var title:String
}

struct CupStackView:View{
    var cups:[Cup] = [Cup(color: .red, title: "AS")]
    
    var body:some View{
        RoundedRectangle(cornerRadius:20)
            .frame(width:54, height:72)
            .foregroundColor(.red)
        
        RoundedRectangle(cornerRadius:20)
            .frame(width:54, height:72)
            .foregroundColor(.red)
        
        RoundedRectangle(cornerRadius:20)
            .frame(width:54, height:72)
            .foregroundColor(.red)
        
    }
}

#Preview{
    CupStackView(cups: [])
}
