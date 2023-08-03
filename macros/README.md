For now I am resisting the strong urge to add some way to modify state
(i.e. define macros or set variables) from the input itself. To add new
macros just add a new hare source file to the `macro` module. Use the
existing definitions as examples. Even complex macros shouldn't take
more than ten or twenty lines of "real" code; though mind your P's and
Q's writing the regular expression used to match the macro.
