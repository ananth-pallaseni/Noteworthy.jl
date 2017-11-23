# Noteworthy

<!-- [![Build Status](https://travis-ci.org/ananth-pallaseni/Noteworthy.jl.svg?branch=master)](https://travis-ci.org/ananth-pallaseni/Noteworthy.jl)

[![Coverage Status](https://coveralls.io/repos/ananth-pallaseni/Noteworthy.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ananth-pallaseni/Noteworthy.jl?branch=master)

[![codecov.io](http://codecov.io/github/ananth-pallaseni/Noteworthy.jl/coverage.svg?branch=master)](http://codecov.io/github/ananth-pallaseni/Noteworthy.jl?branch=master) -->

Found some piece of knowledge that you know you're going to forget when you need it? Leave yourself a note.

A package that adds a Note mode to the Julia REPL, allowing you to make or search for notes.

## Installation
```julia
Pkg.clone("https://github.com/ananth-pallaseni/Noteworthy.jl")
```

## Usage
Enter Notes mode by pressing `/` at the REPL.

#### Search for notes
To search for notes, enter notes mode and then enter a set of space separated tags that you would like to search for. All notes containing tags in this set will be returned.

You can return all notes by using the tag `#`


#### Create notes
To create a note, first enter notes mode then type in new and hit enter. This will take you to the note writing interface.

Type your note in markdown, then finish with a set of tags in the last line.

```
note body is like this

put some code here : `code(example)`

end with tags on final line

#tag1 #tag2
```
