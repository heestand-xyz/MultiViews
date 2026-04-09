//
//  NamedViewTask.swift
//  MultiViews
//
//  Created by Anton Heestand on 2026-02-02.
//

import SwiftUI

extension View {
    public func task(
        name: String,
        perform: @escaping () async -> Void
    ) -> some View {
        task {
            let task = Task(name: name) {
                await perform()
            }
            await withTaskCancellationHandler {
                await task.value
            } onCancel: {
                task.cancel()
            }
        }
    }

    public func task<ID: Equatable>(
        id: ID,
        name: String,
        perform: @escaping () async -> Void
    ) -> some View {
        task(id: id) {
            let task = Task(name: name) {
                await perform()
            }
            await withTaskCancellationHandler {
                await task.value
            } onCancel: {
                task.cancel()
            }
        }
    }
}
