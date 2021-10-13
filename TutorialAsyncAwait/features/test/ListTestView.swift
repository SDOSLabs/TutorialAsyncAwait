//
//  ListTestView.swift
//  TutorialAsyncAwait
//
//  Created by Rafael Fernandez Alvarez on 24/9/21.
//

import SwiftUI

struct TestableItem: Identifiable {
    var id = UUID()
    
    let instance: Testable
    let title: String
}

struct ListTestView: View {
    let items: [TestableItem] = [
        TestableItem(instance: TestAsyncAwaitSyntax.shared, title: "Test Syntax"),
        TestableItem(instance: TestAsyncAwaitParallelSimple.shared, title: "Test Parallel Simple"),
        TestableItem(instance: TestAsyncAwaitParallelImage.shared, title: "Test Parallel Image"),
        TestableItem(instance: TestAsyncAwaitSequence.shared, title: "Test Sequence"),
        TestableItem(instance: TestAsyncAwaitTasks.shared, title: "Test Tasks"),
        TestableItem(instance: TestAsyncAwaitCancelation.shared, title: "Test Cancelation"),
        TestableItem(instance: TestAsyncAwaitContinuation.shared, title: "Test Continuation"),
        TestableItem(instance: TestAsyncAwaitActor.shared, title: "Test Actor")
        
    ]
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    Button(item.title) {
                        item.instance.start()
                    }
                }
            }
            .navigationBarTitle("Test")
        }
    }
}

struct ListTestView_Previews: PreviewProvider {
    static var previews: some View {
        ListTestView()
    }
}
