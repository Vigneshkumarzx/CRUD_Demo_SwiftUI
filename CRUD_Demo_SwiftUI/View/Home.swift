//
//  Home.swift
//  CRUD_Demo_SwiftUI
//
//  Created by vignesh kumar c on 13/09/23.
//

import SwiftUI

struct Home: View {
    
    @Environment(\.self) private var env
    @State var filterDate: Date = .init()
    @State var showPendingTasks: Bool = true
    @State var showCompletedTasks: Bool = true
    
    var body: some View {
        List {
            DatePicker(selection: $filterDate, displayedComponents: [.date]) {
                
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            
            CustomFilteringView(filterDate: $filterDate) { pendingTask, completedTask in
                DisclosureGroup(isExpanded: $showPendingTasks) {
                    
                    ForEach(pendingTask){
                        TaskRow(task: $0, isPendingTask: true)
                    }
                    
                } label: {
                    Text("pending Task's \(pendingTask.isEmpty ? "" : "(\(pendingTask.count))")")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
                
                DisclosureGroup(isExpanded: $showCompletedTasks) {
                    
                   ForEach(completedTask) { task in
                        TaskRow(task: task, isPendingTask: false)
                    }
                    
                } label: {
                    Text("Completed Task's \(completedTask.isEmpty ? "" : "(\(completedTask.count))")")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                }
            }
            
            
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    do {
                        let task = Task(context: env.managedObjectContext)
                        task.id = .init()
                        task.title = ""
                        task.date = filterDate
                        task.isCompleted = false
                        
                        try env.managedObjectContext.save()
                        showPendingTasks = true
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        
                        Text("New Task")
                    }
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TaskRow: View {
   @ObservedObject var task: Task
    var isPendingTask: Bool
    
    @Environment(\.self) private var env
    @FocusState var showKeyBoard: Bool
    
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                task.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("Task's", text: .init(get: {
                    return task.title ?? ""
                }, set: { value in
                    task.title = value
                }))
                .focused($showKeyBoard)
                .onSubmit {
                    removeTask()
                    save()
                }
                .foregroundColor(isPendingTask ? .primary : .gray)
                .strikethrough(!isPendingTask, pattern: .dash, color: .primary)
                
                Text((task.date ?? .init()).formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .overlay {
                        DatePicker(selection: .init(get: {
                            return task.date ?? .init()
                        }, set: { value in
                            task.date = value
                            save()
                        }), displayedComponents: [.hourAndMinute]) {
                            
                        }
                        .labelsHidden()
                        // hide view
                        .blendMode(.destinationOver)
                    }
               
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        .onAppear {
            if(task.title ?? "").isEmpty {
                self.showKeyBoard = true
            }
        }
        
        .onDisappear {
            removeTask()
            save()
        }
        
        .onChange(of: env.scenePhase) { newValue in
            if newValue != .active {
                showKeyBoard = false
                DispatchQueue.main.async {
                    removeTask()
                    save()
                }
            }
        }
        
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    env.managedObjectContext.delete(task)
                    save()
                }
            } label: {
                Image(systemName: "trash.fill")
            }

        }
        
    }
    
    func save() {
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeTask() {
        if(task.title ?? "").isEmpty {
            env.managedObjectContext.delete(task)
        }
    }
}
