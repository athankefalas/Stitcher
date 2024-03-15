//
//  IndexingTask.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation

class IndexingTask: CancellableTask {
    
    @Atomic
    private var subtasks: [AsyncTask]
    
    init(subtasks: [AsyncTask] = []) {
        self.subtasks = subtasks
    }
    
    func append(_ task: AsyncTask) {
        subtasks.append(task)
    }
    
    func cancel() {
        subtasks.forEach({ $0.cancel() })
        subtasks.removeAll()
    }
}
