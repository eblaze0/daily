import SwiftUI

struct WorkoutsView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        Group {
            if viewModel.isWorkoutActive {
                ActiveWorkoutView(viewModel: viewModel)
            } else {
                WorkoutHistoryView(viewModel: viewModel)
            }
        }
        .navigationTitle(viewModel.isWorkoutActive ? "Active Workout" : "Workouts")
        .toolbar {
            if viewModel.isWorkoutActive {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Finish") {
                        viewModel.finishWorkout()
                    }
                    .foregroundColor(.red)
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.startWorkout()
                    } label: {
                        Label("Start Workout", systemImage: "plus")
                    }
                }
            }
        }
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage != nil ? AlertItem(message: viewModel.errorMessage!) : nil },
            set: { _ in viewModel.errorMessage = nil }
        )) { alert in
            Alert(title: Text("Error"), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
    }
}

// Alert helper
struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - WorkoutHistoryView

struct WorkoutHistoryView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack {
            // This would show past workouts in a real implementation
            // For now, we'll just show a placeholder
            VStack(spacing: 20) {
                Image(systemName: "figure.run")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("No workout history yet")
                    .font(.headline)
                
                Text("Start a new workout to begin tracking your progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: { viewModel.startWorkout() }) {
                    Text("Start Workout")
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
        }
    }
}

// MARK: - ActiveWorkoutView

struct ActiveWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var isShowingExerciseSelector = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Workout timer
            HStack {
                Label(viewModel.formattedElapsedTime, systemImage: "clock")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Spacer()
                
                if viewModel.isRestTimerActive {
                    Label(viewModel.formattedRestTime, systemImage: "timer")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                        .transition(.scale)
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            
            // Current workout content
            if viewModel.selectedExercise == nil {
                VStack(spacing: 20) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Select an Exercise")
                        .font(.headline)
                    
                    Button(action: { isShowingExerciseSelector = true }) {
                        Text("Choose Exercise")
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Current exercise header
                        HStack {
                            VStack(alignment: .leading) {
                                Text(viewModel.selectedExercise!.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let primaryMuscle = viewModel.selectedExercise?.primaryMuscleGroups.first {
                                    Text(primaryMuscle.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { viewModel.selectedExercise = nil }) {
                                Text("Change")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Sets list
                        ForEach(getCurrentExerciseSets()) { set in
                            SetRow(set: set, onDelete: { viewModel.removeSet(set) })
                        }
                        
                        // Add set form
                        AddSetForm(viewModel: viewModel)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $isShowingExerciseSelector) {
            ExerciseSelectorView(
                exercises: viewModel.availableExercises,
                onSelect: { exercise in
                    viewModel.selectedExercise = exercise
                    isShowingExerciseSelector = false
                }
            )
        }
    }
    
    private func getCurrentExerciseSets() -> [ExerciseSet] {
        guard let exerciseId = viewModel.selectedExercise?.id else {
            return []
        }
        
        return viewModel.currentExerciseSets
            .filter { $0.exerciseId == exerciseId }
            .sorted { $0.setNumber < $1.setNumber }
    }
}

// MARK: - Supporting Views

struct SetRow: View {
    let set: ExerciseSet
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text("Set \(set.setNumber)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            if let reps = set.reps {
                Text("\(reps) reps")
                    .font(.headline)
            }
            
            if let weightStr = set.formattedWeight {
                Text("×")
                    .foregroundColor(.secondary)
                
                Text(weightStr)
                    .font(.headline)
            }
            
            Spacer()
            
            // Effort indicator (1-5)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= (set.effortRating ?? 0) ? "circle.fill" : "circle")
                        .font(.caption)
                        .foregroundColor(effortColor(for: set.effortRating ?? 0))
                }
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(8)
    }
    
    private func effortColor(for rating: Int) -> Color {
        switch rating {
        case 1:
            return .green
        case 2:
            return .mint
        case 3:
            return .yellow
        case 4:
            return .orange
        case 5:
            return .red
        default:
            return .gray
        }
    }
}

struct AddSetForm: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add Set")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                // Reps
                VStack(alignment: .leading) {
                    Text("Reps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $viewModel.newSetReps)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Weight
                VStack(alignment: .leading) {
                    Text("Weight (kg)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $viewModel.newSetWeight)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            // Effort
            VStack(alignment: .leading) {
                Text("Effort (1-5)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Effort", selection: $viewModel.newSetEffort) {
                    ForEach(1...5, id: \.self) { rating in
                        HStack {
                            ForEach(1...rating, id: \.self) { _ in
                                Image(systemName: "circle.fill")
                                    .foregroundColor(effortColor(for: rating))
                            }
                            Text("\(rating)")
                        }.tag(rating)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Add button
            Button(action: { viewModel.addSet() }) {
                Text("Add Set")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.newSetReps.isEmpty)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func effortColor(for rating: Int) -> Color {
        switch rating {
        case 1:
            return .green
        case 2:
            return .mint
        case 3:
            return .yellow
        case 4:
            return .orange
        case 5:
            return .red
        default:
            return .gray
        }
    }
}

struct ExerciseSelectorView: View {
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredExercises) { exercise in
                        Button(action: { onSelect(exercise) }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    
                                    if let primaryMuscle = exercise.primaryMuscleGroups.first {
                                        Text(primaryMuscle.name)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Select Exercise")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
} 