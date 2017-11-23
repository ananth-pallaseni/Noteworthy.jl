module Noteworthy

include("replmod.jl")
include("noteworthy.jl")
include("noteworthy_repl.jl")

NOTES_FNAME = "notes.json"
NOTES_PROMPT = "notes> "
NEW_NOTES_PROMPT = "new note> "
NOTES_KEY = '/'
PROMPT_COLOR = Base.text_colors[:cyan]
TEXT_COLOR = Base.text_colors[:normal]

###### Maintain State ######
verify_notes_file(NOTES_FNAME)
NOTES_DICT, TAGS_DICT = create_dicts(NOTES_FNAME)
NOTES_LATEST_ID = isempty(NOTES_DICT) ? 0 : maximum(keys(NOTES_DICT))
increment_id() = global NOTES_LATEST_ID += 1

###### Create easy functions ######
add_note(note::Note) = add_note(note, NOTES_DICT, TAGS_DICT, writeback=true, fname=NOTES_FNAME)
get_notes(tags) = get_notes(tags, TAGS_DICT, NOTES_DICT)

###### Set up REPL mode ######
repl = Base.active_repl
main_mode = repl.interface.modes[1]

NOTES_MODE = create_mode(
    NOTES_PROMPT,
    :notes,
    prefix_color=PROMPT_COLOR,
    suffix_color=TEXT_COLOR,
    on_done = create_on_done_fn(increment_id),
    on_enter = create_on_complete_fn(NEW_NOTES_PROMPT, NOTES_PROMPT)
    )

add_mode_to_repl(NOTES_KEY, NOTES_MODE)

end # module
