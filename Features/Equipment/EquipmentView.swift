import SwiftUI

struct EquipmentView: View {
    @StateObject private var viewModel = EquipmentViewModel()
    @State private var isShowingAddSheet = false
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            // Main content
            VStack {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(
                            isSelected: viewModel.selectedEquipmentType == nil,
                            title: "All",
                            action: { viewModel.clearFilters() }
                        )
                        
                        ForEach(Equipment.EquipmentType.allCases, id: \.self) { type in
                            FilterChip(
                                isSelected: viewModel.selectedEquipmentType == type,
                                title: type.displayName,
                                action: { viewModel.filterByType(type) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Equipment list
                if viewModel.isLoading {
                    ProgressView("Loading equipment...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredEquipment.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "gym.bag.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No equipment found")
                            .font(.headline)
                        
                        Text("Add some equipment to your arsenal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: { isShowingAddSheet = true }) {
                            Text("Add Equipment")
                                .fontWeight(.semibold)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Array(viewModel.groupedEquipment().keys.sorted { $0.rawValue < $1.rawValue }), id: \.self) { type in
                            Section(header: Text(type.displayName)) {
                                ForEach(viewModel.groupedEquipment()[type] ?? []) { item in
                                    EquipmentRow(equipment: item)
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        if let equipment = viewModel.groupedEquipment()[type]?[index] {
                                            viewModel.deleteEquipment(withID: equipment.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                        .onTapGesture {
                            viewModel.errorMessage = nil
                        }
                }
            }
            
            // Add button
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: { isShowingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search equipment")
        .onChange(of: searchText) { _ in
            filterEquipment()
        }
        .navigationTitle("Equipment")
        .sheet(isPresented: $isShowingAddSheet) {
            AddEquipmentView(viewModel: viewModel)
        }
    }
    
    private func filterEquipment() {
        // In a more complete implementation, this would update the filter criteria in the view model
        // including both type and search text
    }
}

// MARK: - Supporting Views

struct EquipmentRow: View {
    let equipment: Equipment
    
    var body: some View {
        HStack {
            Image(systemName: equipment.type.systemImageName)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.headline)
                
                if let gymLocation = equipment.gymLocation {
                    Text(gymLocation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if equipment.isAvailable {
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            } else {
                Text("Unavailable")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FilterChip: View {
    let isSelected: Bool
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct AddEquipmentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EquipmentViewModel
    
    @State private var name = ""
    @State private var selectedType = Equipment.EquipmentType.barbell
    @State private var isAvailable = true
    @State private var gymLocation = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Equipment Details")) {
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(Equipment.EquipmentType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    Toggle("Available", isOn: $isAvailable)
                    
                    TextField("Location (e.g., Home Gym, LA Fitness)", text: $gymLocation)
                }
                
                Section {
                    Button("Add Equipment") {
                        viewModel.createNewEquipment(
                            name: name,
                            type: selectedType,
                            isAvailable: isAvailable,
                            gymLocation: gymLocation.isEmpty ? nil : gymLocation
                        )
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add Equipment")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
} 