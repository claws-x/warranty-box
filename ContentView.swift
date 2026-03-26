//
//  ContentView.swift
//  WarrantyBox
//
//  Created by AI Agent on 2026-03-26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showingAddItem = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WarrantyItem.purchaseDate, ascending: false)],
        animation: .default)
    private var items: FetchedResults<WarrantyItem>
    
    var filteredItems: [WarrantyItem] {
        var result = items.filter { item in
            if searchText.isEmpty {
                return true
            }
            return item.productName.localizedCaseInsensitiveContains(searchText) ||
                   (item.storeName?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 类别筛选
                CategoryFilterView(selectedCategory: $selectedCategory)
                
                // 保修项目列表
                List(filteredItems) { item in
                    WarrantyItemRow(item: item)
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "搜索商品或商家")
            }
            .navigationTitle("保修管家")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
        }
    }
}

/// 类别筛选视图
struct CategoryFilterView: View {
    @Binding var selectedCategory: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(title: "全部", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                
                ForEach(ProductCategory.allCases) { category in
                    FilterChip(title: category.rawValue, isSelected: selectedCategory == category.rawValue) {
                        selectedCategory = category.rawValue
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6))
    }
}

/// 筛选按钮
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

/// 保修项目行视图
struct WarrantyItemRow: View {
    let item: WarrantyItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 商品图片
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                Image(systemName: item.categoryIcon)
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(.headline)
                
                Text(item.storeName ?? "未知商家")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text(item.statusText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Text("购买：\(item.purchaseDate.formatted())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    var statusColor: Color {
        if item.isExpired {
            return .red
        } else if item.daysRemaining <= 7 {
            return .orange
        } else if item.daysRemaining <= 30 {
            return .yellow
        } else {
            return .green
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, DataController(inMemory: true).container.viewContext)
    }
}

// MARK: - UIImage Extension
extension UIImage {
    convenience init?(data: Data) {
        self.init(data: data)
    }
}

extension WarrantyItem {
    var categoryIcon: String {
        ProductCategory.allCases.first { $0.rawValue == category }?.icon ?? "bag"
    }
}
