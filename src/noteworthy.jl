using JSON
import Base.show

type Note
    id::Int
    tags::Array{AbstractString, 1}
    body::AbstractString
end

function grab_json(fname="")
    res = open(fname, "r") do f
        raw_json = readstring(f)
        res = JSON.parse(raw_json)
    end
    return res
end

function read_notes(raw_notes_list)
    notes_list = []
    for raw_note in raw_notes_list
        id = raw_note["id"]
        tags = raw_note["tags"]
        body = raw_note["body"]
        note = Note(id, tags, body)
        push!(notes_list, note)
    end

    return notes_list
end

function read_notes(fname::AbstractString)
    try
        raw_notes_list = grab_json(fname)
        return read_notes(raw_notes_list)
    catch e
        if e isa LoadError
            println("File '", fname, "' does not exist. Starting with no notes")
        else
            println("Error loading notes file. Starting with no notes")
        end
        return []
    end
end

function write_dict(notes_dict, fname)
    notes_list = collect(values(notes_dict))
    open(fname, "w") do f
        write(f, json(notes_list))
    end
end

function add_note(note::Note, note_dict::Dict, tag_dict::Dict; writeback=true, fname="notes.json")
    note_dict[note.id] = note
    for tag in note.tags
        if haskey(tag_dict, tag)
            push!(tag_dict[tag], note.id)
        else
            tag_dict[tag] = [note.id]
        end
    end

    if writeback
        write_dict(note_dict, fname)
    end
end

function create_dicts(notes_list::Array)
    note_dict=Dict()
    tag_dict=Dict()
    for note in notes_list
        add_note(note, note_dict, tag_dict)
    end
    return note_dict, tag_dict
end

function create_dicts(fname::AbstractString)
    return create_dicts(read_notes(fname))
end

function search_tags(tag, tag_dict)
    tag_list = get(tag_dict, tag, [])
    return tag_list
end

function search_tags(tag, tag_dict, notes_dict)
    tag_list = search_tags(tag, tag_dict)
    return [notes_dict[idx] for idx in tag_list]
end

function print_note_body(body::AbstractString)
    md = Markdown.parse(body)
    display(md)
end


function print_tags(tags)
    tag_color_str = Base.text_colors[:blue]
    tag_str = string(tag_color_str, "  ", map(t->string("#", t, " "), tags)...)
    println(tag_str, Base.text_colors[:normal])
end

function print_note(note::Note)
    print_note_body(note.body)
    println()
    print_tags(note.tags)
end

dashed_seperator() = println(string(["=" for _ in 1:40]...))

function get_notes(tags::Array, tag_dict::Dict, notes_dict::Dict; seperator_fn=dashed_seperator)
    importance = Dict()

    for tag in tags
        id_list = search_tags(tag, tag_dict)
        for id in id_list
            if haskey(importance, id)
                importance[id] += 1
            else
                importance[id] = 1
            end
        end
    end

    sorted_ids = sort(collect(keys(importance)), by=x->importance[x], rev=true)
    notes = [notes_dict[id] for id in sorted_ids]

    if isempty(notes)
        println("No notes found containing tags in [", tags..., "]")
    else
        seperator_fn()
        for note in notes
            print_note(note)
            seperator_fn()
        end
    end
    nothing
end

function get_notes(tag::AbstractString, tag_dict, notes_dict)
    get_notes([tag], tag_dict, notes_dict)
end

function verify_notes_file(fname)
    if !(basename(fname) in readdir(dirname(fname)))
        write_dict(Dict(0=>Note(0, [], "dummy")), fname)
    end
end
