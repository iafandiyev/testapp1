import SwiftUI

struct Note: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var date: Date = Date()
}

struct ContentView: View {
    @AppStorage("notesData") private var notesData = "[]"

    @State private var notes: [Note] = []
    @State private var showingEditor = false
    @State private var editingNote: Note?

    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Tap + to create your first note.")
                    )
                } else {
                    List {
                        ForEach(notes) { note in
                            Button {
                                editingNote = note
                                title = note.title
                                content = note.content
                                showingEditor = true
                            } label: {
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(note.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(note.content)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)

                                    Text(note.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingNote = nil
                        title = ""
                        content = ""
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack {
                    Form {
                        Section("Title") {
                            TextField("Enter title", text: $title)
                        }

                        Section("Content") {
                            TextEditor(text: $content)
                                .frame(minHeight: 220)
                        }
                    }
                    .navigationTitle(editingNote == nil ? "New Note" : "Edit Note")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingEditor = false
                            }
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                saveNote()
                            }
                            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
            .onAppear {
                loadNotes()
            }
        }
        .preferredColorScheme(.light)
    }

    private func loadNotes() {
        guard let data = notesData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([Note].self, from: data) else {
            notes = []
            return
        }

        notes = decoded
    }

    private func saveNotesToStorage() {
        guard let data = try? JSONEncoder().encode(notes),
              let json = String(data: data, encoding: .utf8) else {
            return
        }

        notesData = json
    }

    private func saveNote() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty else {
            return
        }

        if let editingNote,
           let index = notes.firstIndex(where: { $0.id == editingNote.id }) {
            notes[index].title = cleanTitle
            notes[index].content = content
            notes[index].date = Date()
        } else {
            let newNote = Note(
                title: cleanTitle,
                content: content
            )

            notes.insert(newNote, at: 0)
        }

        saveNotesToStorage()
        showingEditor = false
    }

    private func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotesToStorage()
    }
}