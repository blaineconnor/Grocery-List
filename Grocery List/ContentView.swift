//
//  ContentView.swift
//  Grocery List
//
//  Created by Fatih Emre on 13.01.2025.
//

import SwiftUI
import SwiftData
import TipKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var item: String = ""
    
    @FocusState private var isFocused: Bool
    
    let buttonTip = ButtonTip()
    
    func setupTips(){
        do {
            try Tips.resetDatastore()
            Tips.showAllTipsForTesting()
            try Tips.configure([
                .displayFrequency(.immediate)
            ])
        } catch {
            print ("Error initializing TipKit \(error.localizedDescription)")
        }
    }
    
    init() {
        setupTips()
    }
    
    func addEssentialFoods() {
        modelContext.insert( Item(title: "Fasulye", isCompleted: false))
        modelContext.insert(Item(title: "Et", isCompleted: true))
        modelContext.insert(Item(title: "Mısır Gevreği", isCompleted: .random()))
        modelContext.insert(Item(title: "Süt", isCompleted: .random()))
        modelContext.insert(Item(title: "Peynir ve Yumurta", isCompleted: .random()))
        modelContext.insert(Item(title: "Kuruyemiş", isCompleted: .random()))
    }
    
    func deleteAllItems() {
        withAnimation {
            for item in items {
                modelContext.delete(item)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Text(item.title)
                        .font(.title.weight(.light))
                        .padding(.vertical, 2)
                        .foregroundStyle(item.isCompleted == false ? Color.primary : Color.accentColor)
                        .strikethrough(item.isCompleted)
                        .italic(item.isCompleted)
                        .swipeActions {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(item)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                        }
                        .swipeActions(edge: .leading) {
                            Button("Done", systemImage: item.isCompleted == false ? "checkmark.circle" : "x.circle") {
                                item.isCompleted.toggle()
                            }
                            .tint(item.isCompleted == false ? .green : .pink)
                        }
                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                if items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            addEssentialFoods()
                        } label: {
                            Image(systemName: "carrot")
                        }
                        .popoverTip(buttonTip)
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .destructive) {
                            deleteAllItems()
                        } label: {
                            Label("Delete All", systemImage: "trash")
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    TextField("", text: $item)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(.tertiary)
                        .cornerRadius(12)
                        .font(.title.weight(.light))
                        .focused($isFocused)
                    Button {
                        guard !item.isEmpty else {
                            return
                        }
                        
                        let newItem = Item(title: item, isCompleted: false)
                        modelContext.insert(newItem)
                        item = ""
                        isFocused = false
                    } label: {
                        Text("Save")
                            .font(.title2.weight(.medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .controlSize(.extraLarge)
                }
                .padding()
                .background(.bar)
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView("Empty Cart", systemImage: "cart.cicrle", description: Text("Add some items to the shopping list."))
                }
            }
        }
    }
}

#Preview("Sample Data") {
    let sampleData: [Item] = [
        Item(title: "Fasulye", isCompleted: false),
        Item(title: "Et", isCompleted: true),
        Item(title: "Mısır Gevreği", isCompleted: .random()),
        Item(title: "Süt", isCompleted: .random()),
        Item(title: "Peynir ve Yumurta", isCompleted: .random()),
        Item(title: "Kuruyemiş", isCompleted: .random())
    ]
    
    let container = try! ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    for item in sampleData {
        container.mainContext.insert(item)
    }
    
    return ContentView()
        .modelContainer(container)
}

#Preview("Empty List") {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
