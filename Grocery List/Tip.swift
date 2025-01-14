//
//  Tip.swift
//  Grocery List
//
//  Created by Fatih Emre on 14.01.2025.
//

import TipKit

struct ButtonTip: Tip {
    var title: Text = Text("Essential Foods")
    var message: Text? = Text("add some everyday items to the shopping list.")
    var image: Image? = Image(systemName: "info.circle")
}
