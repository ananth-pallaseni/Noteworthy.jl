# Much of this is copied from Keno's CXX.jl

import Base: LineEdit, REPL

function create_mode(prompt, name;
    on_enter=LineEdit.default_enter_cb,
    on_done=()->nothing,
    prefix_color=Base.text_colors[:green],
    suffix_color=Base.text_colors[:red],
    repl=Base.active_repl,
    main_mode = repl.interface.modes[1])

    mirepl = isdefined(repl,:mi) ? repl.mi : repl

    done_func = REPL.respond(on_done, repl, main_mode)

    # Setup mode
    mode = LineEdit.Prompt(prompt;
        # Copy colors from the prompt object
        prompt_prefix=prefix_color,
        prompt_suffix=suffix_color,
        on_enter = on_enter,
        on_done = done_func)

    main_mode == mirepl.interface.modes[1] &&
            push!(mirepl.interface.modes,mode)

    hp = main_mode.hist
    hp.mode_mapping[name] = mode
    mode.hist = hp

    search_prompt, skeymap = LineEdit.setup_search_keymap(hp)
    mk = REPL.mode_keymap(main_mode)

    b = Dict{Any,Any}[skeymap, mk, LineEdit.history_keymap, LineEdit.default_keymap, LineEdit.escape_defaults]
    mode.keymap_dict = LineEdit.keymap(b)

    return mode
end

function add_mode_to_repl(key, mode)
    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]

    const new_keymap = Dict{Any,Any}(
            key => function (s,args...)
                if isempty(s) || position(LineEdit.buffer(s)) == 0
                    buf = copy(LineEdit.buffer(s))
                    LineEdit.transition(s, mode) do
                        LineEdit.state(s, mode).input_buffer = buf
                    end
                else
                    LineEdit.edit_insert(s,key)
                end
            end
        )

    main_mode.keymap_dict = LineEdit.keymap_merge(main_mode.keymap_dict, new_keymap);
    nothing
end
