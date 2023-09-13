//
//  ContentView.swift
//  CRUD_Demo_SwiftUI
//
//  Created by vignesh kumar c on 13/09/23.
//

import SwiftUI

struct ContentView: View {
     

    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("To-Do")
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
