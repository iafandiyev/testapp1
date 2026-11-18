
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
                    emptyState
                } else {
                    notesList
                }
            }
            .navigationTitle("My Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createNote) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(.black, in: Circle())
                    }
                    .accessibilityLabel("Create note")
                }
            }
            .sheet(isPresented: $showingEditor) {
                editorSheet
            }
            .onAppear(perform: loadNotes)
        }
        .preferredColorScheme(.light)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "note.text")
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(.secondary)

            Text("No Notes Yet")
                .font(.title2.weight(.semibold))

            Text("Tap the + button to create your first note.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notesList: some View {
        List {
            ForEach(notes) { note in
                Button {
                    editNote(note)
                } label: {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(note.title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if !note.content.isEmpty {
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Text(note.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: deleteNotes)
        }
        .listStyle(.plain)
    }

    private var editorSheet: some View {
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingEditor = false
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveNote)
                        .disabled(
                            title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                        )
                }
            }
        }
    }

    private func createNote() {
        editingNote = nil
        title = ""
        content = ""
        showingEditor = true
    }

    private func editNote(_ note: Note) {
        editingNote = note
        title = note.title
        content = note.content
        showingEditor = true
    }

    private func loadNotes() {
        guard let data = notesData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([Note].self, from: data) else {
            notes = []
            return
        }

        notes = decoded.sorted { $0.date > $1.date }
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
            notes.insert(
                Note(title: cleanTitle, content: content),
                at: 0
            )
        }

        notes.sort { $0.date > $1.date }
        saveNotesToStorage()
        showingEditor = false
    }

    private func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotesToStorage()
    }
}
