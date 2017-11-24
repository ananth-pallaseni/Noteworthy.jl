

new_note_header = "======== Input New Note ========"

function notes_handle_query(tags...)
    get_notes(tags...)
    nothing
end

function notes_handle_new(body, increment_id)
    tags = map(x->x[2:end], filter(t->startswith(t, "#") && length(t)>1, split(body)))
    if !("#" in tags) push!(tags, "#") end
    latest_id = increment_id()
    body = body[length(new_note_header)+1 : end]
    body = body[1 : search(body, "#")[1]-1]
    new_note = Note(latest_id, tags, body)
    add_note(new_note)
    nothing
end

function notes_on_done(query, increment_id)
    tags = split(query)

    if isempty(tags)
        tags = [""]
    end

    is_new = tags[1] == "new" || startswith(query, new_note_header)
    if is_new && length(tags) > 1
        body = strip(query)
        notes_handle_new(body, increment_id)
    else
        notes_handle_query(tags)
    end
    nothing
end

function create_on_done_fn(increment_id)
    done_func(query) = notes_on_done(query, increment_id)
    return done_func
end

function update_prompt(cur_mode, is_new, new_prompt, base_prompt)
    if is_new
        cur_mode.prompt = new_prompt
    else
        cur_mode.prompt = base_prompt
    end
end

new_note_header = "======== Input New Note ========"

function notes_is_complete(s, new_prompt, base_prompt)
    cur_mode = LineEdit.mode(s)
    # update_prompt(cur_mode, false, new_prompt, base_prompt)
    str = String(take!(copy(LineEdit.buffer(s))))
    if isempty(str) return true end
    if length(str) < 3 || (length(str) >= 3 && !startswith(str, "new") && !startswith(str, new_note_header)) return true end

    # Deal with the `new` keyword
    if length(str) >= 3 && str[1:3] == "new"
        # reset line and change input
        LineEdit.edit_delete_prev_word(s)
        LineEdit.edit_insert(s, new_note_header)
        # LineEdit.edit_kill_line(s)
        # update_prompt(cur_mode, true, new_prompt, base_prompt)
        return false
     end
    return str[end-1:end] == "##"
end

function create_on_complete_fn(new_prompt, base_prompt)
    return s -> notes_is_complete(s, new_prompt, base_prompt)
end
