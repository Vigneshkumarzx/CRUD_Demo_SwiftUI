//
//  CustomFilteringView.swift
//  CRUD_Demo_SwiftUI
//
//  Created by vignesh kumar c on 13/09/23.
//

import SwiftUI

struct CustomFilteringView< Content: View >: View {
    
    var content: ([Task], [Task]) -> Content
    @FetchRequest private var result: FetchedResults<Task>
    @Binding var filterDate: Date
    
    init(filterDate: Binding<Date>, @ViewBuilder content: @escaping ([Task], [Task]) -> Content) {
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: filterDate.wrappedValue)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
       
        _result = FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: false)], predicate: predicate, animation: .easeOut(duration: 0.25))
        
        self.content = content
        self._filterDate = filterDate
    }
    
    var body: some View {
        content(seperatorTask().0, seperatorTask().1)
            .onChange(of: filterDate) { newValue in
                result.nsPredicate = nil
                
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: newValue)
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
                let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
                result.nsPredicate = predicate
            }
    }
    
    func seperatorTask() -> ([Task],[Task]) {
        let pendingTasks = result.filter { !$0.isCompleted }
        let compledTasks = result.filter { $0.isCompleted }
        
        return (pendingTasks, compledTasks)
    }
}

struct CustomFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
