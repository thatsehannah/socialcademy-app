//
//  CommentsList.swift
//  Socialcademy
//
//  Created by Elliot Hannah III on 5/10/23.
//

import SwiftUI

struct CommentsList: View {
    @StateObject var viewModel: CommentsViewModel
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.comments {
                case .loading:
                    ProgressView()
                        .onAppear {
                            viewModel.fetchComments()
                        }
                case .error(let error):
                    EmptyListView(
                        title: "Cannot Load Comments",
                        message: error.localizedDescription,
                        retryAction: {
                            viewModel.fetchComments()
                        }
                    )
                case .empty:
                    EmptyListView(
                        title: "No Comments",
                        message: "Be the first to leave a comment"
                    )
                case .loaded(let comments):
                    List(comments) { comment in
                        CommentRow(viewModel: viewModel.makeCommentRowViewModel(for: comment))
                    }
                    .animation(.default, value: comments)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NewCommentForm(viewModel: viewModel.makeNewCommentViewModel())
                }
            }
        }
        
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

private extension CommentsList {
    struct NewCommentForm: View {
        @StateObject var viewModel: FormViewModel<Comment>
        
        var body: some View {
            HStack {
                TextField("Comment", text: $viewModel.content)
                Button(action: viewModel.submit) {
                    if viewModel.isWorking {
                        ProgressView()
                    } else {
                        Label("Post", systemImage: "paperplane")
                    }
                }
            }
            .alert("Cannot Post Comment", error: $viewModel.error)
            .animation(.default, value: viewModel.isWorking)
            .disabled(viewModel.isWorking)
            .onSubmit(viewModel.submit)
        }
    }
}

struct CommentsList_Previews: PreviewProvider {
    private struct ListPreview: View {
        let state: Loadable<[Comment]>
        
        var body: some View {
            NavigationView {
                CommentsList(viewModel: CommentsViewModel(commentsRepository: CommentsRepositoryStub(state: state)))
            }
        }
    }
    
    static var previews: some View {
        ListPreview(state: .loaded([Comment.testComment]))
        ListPreview(state: .empty)
        ListPreview(state: .error)
        ListPreview(state: .loading)
    }
}
