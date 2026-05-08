import Foundation

/// Extended Vim documentation for RAG retrieval
/// Includes advanced topics, real-world examples, and plugin info
extension VimDocs {
    
    /// Additional documentation that supplements the main reference
    static let extendedReference = """
    ## Delete Operations
    - x: Delete character under cursor
    - X: Delete character before cursor
    - dw: Delete from cursor to start of next word
    - de: Delete from cursor to end of current word
    - db: Delete from cursor to beginning of current word
    - dd: Delete entire line
    - D or d$: Delete from cursor to end of line
    - d0: Delete from cursor to beginning of line
    - dG: Delete from cursor to end of file
    - dgg: Delete from cursor to beginning of file
    - d}: Delete to end of paragraph
    - d{: Delete to beginning of paragraph
    - dt{char}: Delete until character (not including)
    - df{char}: Delete through character (including)
    - diw: Delete inner word (word under cursor)
    - daw: Delete a word (includes surrounding whitespace)
    - dis: Delete inner sentence
    - das: Delete a sentence
    - dip: Delete inner paragraph
    - dap: Delete a paragraph
    - di": Delete inside double quotes
    - da": Delete around double quotes (includes quotes)
    - di': Delete inside single quotes
    - di(: Delete inside parentheses
    - di): Same as di(
    - dib: Delete inside block (parentheses)
    - di[: Delete inside square brackets
    - di]: Same as di[
    - di{: Delete inside curly braces
    - di}: Same as di{
    - diB: Delete inside Block (curly braces)
    - di<: Delete inside angle brackets
    - dit: Delete inside tag (HTML/XML)
    - dat: Delete a tag (includes tags)

    ## Change Operations
    - cw: Change word (delete and enter insert)
    - ce: Change to end of word
    - cb: Change to beginning of word
    - cc: Change entire line
    - C or c$: Change to end of line
    - c0: Change to beginning of line
    - ciw: Change inner word
    - caw: Change a word
    - ci": Change inside double quotes
    - ca": Change around double quotes
    - ci': Change inside single quotes
    - ci(: Change inside parentheses
    - ci{: Change inside curly braces
    - ci[: Change inside square brackets
    - cit: Change inside tag
    - cat: Change a tag
    - ct{char}: Change until character
    - cf{char}: Change through character
    - s: Substitute character (delete char, enter insert)
    - S: Substitute line (delete line, enter insert)
    - r{char}: Replace single character without entering insert mode
    - R: Enter replace mode (overwrite characters)

    ## Yank (Copy) Operations
    - yy or Y: Yank entire line
    - yw: Yank word
    - ye: Yank to end of word
    - yb: Yank to beginning of word
    - y$: Yank to end of line
    - y0: Yank to beginning of line
    - yG: Yank to end of file
    - ygg: Yank to beginning of file
    - yiw: Yank inner word
    - yaw: Yank a word
    - yi": Yank inside double quotes
    - ya": Yank around double quotes
    - yi(: Yank inside parentheses
    - yi{: Yank inside curly braces
    - yit: Yank inside tag
    - yap: Yank a paragraph
    - yip: Yank inner paragraph

    ## Advanced Motions
    - ): Move forward one sentence
    - (: Move backward one sentence
    - }: Move forward one paragraph
    - {: Move backward one paragraph
    - ]]: Move to next section/function
    - [[: Move to previous section/function
    - ][: Move to end of section/function
    - []: Move to previous section end
    - gd: Go to local declaration
    - gD: Go to global declaration
    - gf: Go to file under cursor
    - gF: Go to file and line number under cursor
    - gi: Go to last insert position and enter insert mode
    - g;: Go to previous change position
    - g,: Go to next change position
    - `: Jump to exact position of mark
    - ': Jump to beginning of line containing mark
    - ``: Jump back to previous position
    - '': Jump back to beginning of line of previous position
    - Ctrl+o: Jump to older position in jump list
    - Ctrl+i: Jump to newer position in jump list

    ## Line Operations
    - J: Join current line with next line (with space)
    - gJ: Join lines without space
    - >>: Indent line
    - <<: Unindent line
    - ==: Auto-indent line
    - =G: Auto-indent from cursor to end of file
    - gg=G: Auto-indent entire file
    - gq{motion}: Format text (e.g., gqap for paragraph)
    - gw{motion}: Format text, cursor stays in place
    - gu{motion}: Lowercase (e.g., guiw)
    - gU{motion}: Uppercase (e.g., gUiw)
    - g~{motion}: Toggle case
    - ~: Toggle case of character under cursor
    - Ctrl+a: Increment number under cursor
    - Ctrl+x: Decrement number under cursor
    - g Ctrl+a: Increment numbers in visual selection sequentially

    ## Visual Mode Advanced
    - v: Character-wise visual mode
    - V: Line-wise visual mode
    - Ctrl+v: Block visual mode (column selection)
    - gv: Reselect last visual selection
    - o: Move to other end of selection
    - O: Move to other corner in block mode
    - I: Insert at beginning of each line in block selection
    - A: Append at end of each line in block selection
    - c: Change all selected text
    - d: Delete selected text
    - y: Yank selected text
    - p: Paste over selection (replaces)
    - >: Indent selection
    - <: Unindent selection
    - =: Auto-indent selection
    - u: Lowercase selection
    - U: Uppercase selection
    - J: Join selected lines
    - :: Enter command mode for selection (:'<,'>)
    - r{char}: Replace all selected characters with char
    - Shift+i then type then Esc: Insert same text at start of each line in block

    ## Search Advanced
    - /pattern: Search forward
    - ?pattern: Search backward
    - n: Next match (same direction)
    - N: Previous match (opposite direction)
    - *: Search forward for word under cursor
    - #: Search backward for word under cursor
    - g*: Like * but without word boundaries
    - g#: Like # but without word boundaries
    - /pattern/e: Position cursor at end of match
    - /pattern/b+1: Position cursor 1 char after match start
    - /\\cpattern: Case-insensitive search
    - /\\Cpattern: Case-sensitive search
    - /\\<word\\>: Match whole word only
    - /^pattern: Match at start of line
    - /pattern$: Match at end of line
    - /\\v: Very magic (more regex-like)
    - :noh or :nohlsearch: Clear search highlighting
    - Ctrl+l: Redraw screen and clear highlighting

    ## Substitute (Search and Replace)
    - :s/old/new/: Replace first occurrence in current line
    - :s/old/new/g: Replace all in current line
    - :%s/old/new/g: Replace all in file
    - :%s/old/new/gc: Replace all with confirmation
    - :%s/old/new/gi: Replace all, case-insensitive
    - :5,10s/old/new/g: Replace in lines 5-10
    - :'<,'>s/old/new/g: Replace in visual selection
    - :%s/\\<word\\>/new/g: Replace whole word only
    - :s/old/new/gI: Replace case-sensitive
    - :%s//new/g: Replace last search pattern with new
    - &: Repeat last substitute
    - g&: Repeat last substitute on entire file
    - :s/old/\\=@a/g: Replace with contents of register a
    - :%s/\\n//g: Remove all newlines
    - :%s/\\s\\+$//: Remove trailing whitespace

    ## Registers Advanced
    - "": Unnamed register (default for d, c, y, p)
    - "0: Yank register (last yank only)
    - "1-"9: Delete registers (numbered history)
    - "a-"z: Named registers (lowercase appends if uppercase)
    - "A-"Z: Append to named registers
    - "-: Small delete register (less than one line)
    - "_: Black hole register (delete without saving)
    - "+: System clipboard (requires +clipboard)
    - "*: Primary selection (X11) or clipboard (macOS/Windows)
    - "/: Last search pattern
    - ":: Last command
    - "..: Last inserted text
    - "%: Current filename
    - "#: Alternate filename
    - "=: Expression register (evaluate expression)
    - :reg: View all registers
    - Ctrl+r{register}: Insert register contents in insert mode
    - Ctrl+r=: Insert expression result in insert mode

    ## Macros Advanced
    - q{a-z}: Start recording macro to register
    - q: Stop recording
    - @{a-z}: Play macro
    - @@: Repeat last macro
    - 10@a: Play macro 10 times
    - :5,10normal @a: Play macro on lines 5-10
    - :'<,'>normal @a: Play macro on visual selection
    - Recording tips: Use 0 or ^ to start at consistent position
    - Recording tips: Use n to find next match
    - Recording tips: End with j to move to next line
    - :let @a = 'content': Set macro content directly
    - :let @a .= 'more': Append to macro

    ## Marks Advanced
    - m{a-z}: Set local mark (file-specific)
    - m{A-Z}: Set global mark (across files)
    - '{mark}: Jump to beginning of line with mark
    - `{mark}: Jump to exact position of mark
    - :marks: Show all marks
    - :delmarks a-z: Delete local marks a-z
    - :delmarks!: Delete all local marks
    - Special marks:
    - '.: Position of last change
    - '": Position when last exiting buffer
    - '^: Position of last insert
    - '[: Start of last yank or change
    - ']: End of last yank or change
    - '<: Start of last visual selection
    - '>: End of last visual selection

    ## Buffers, Windows, Tabs
    - :e filename: Open file in new buffer
    - :e!: Reload current file (discard changes)
    - :bn: Next buffer
    - :bp: Previous buffer
    - :b{n}: Go to buffer number n
    - :b name: Go to buffer matching name
    - :ls or :buffers: List all buffers
    - :bd: Delete (close) current buffer
    - :bd!: Force delete buffer (discard changes)
    - :%bd: Close all buffers
    - :sp or :split: Horizontal split
    - :vsp or :vsplit: Vertical split
    - :sp filename: Split and open file
    - Ctrl+w s: Horizontal split
    - Ctrl+w v: Vertical split
    - Ctrl+w w: Cycle through windows
    - Ctrl+w h/j/k/l: Move to window in direction
    - Ctrl+w H/J/K/L: Move window to edge
    - Ctrl+w =: Equalize window sizes
    - Ctrl+w _: Maximize height
    - Ctrl+w |: Maximize width
    - Ctrl+w r: Rotate windows
    - Ctrl+w x: Exchange windows
    - Ctrl+w q: Close window
    - Ctrl+w o: Close all other windows
    - :tabnew: New tab
    - :tabnew filename: New tab with file
    - gt: Next tab
    - gT: Previous tab
    - {n}gt: Go to tab n
    - :tabclose: Close current tab
    - :tabonly: Close all other tabs
    - :tabmove {n}: Move tab to position n

    ## Useful Ex Commands
    - :w: Save file
    - :w filename: Save as filename
    - :w!: Force save (if permissions allow)
    - :q: Quit
    - :q!: Force quit (discard changes)
    - :wq or :x or ZZ: Save and quit
    - :wa: Save all buffers
    - :qa: Quit all
    - :qa!: Force quit all
    - :saveas filename: Save as and switch to new file
    - :r filename: Read file content into current buffer
    - :r !command: Read command output into buffer
    - :!command: Run shell command
    - :!!: Repeat last shell command
    - :sh or :shell: Open shell
    - :set option: Set option
    - :set option?: Show option value
    - :set nooption: Unset boolean option
    - :set option=value: Set option value
    - :set option!: Toggle boolean option
    - :help topic: Open help for topic
    - :version: Show Vim version and features

    ## Common Workflows
    How to delete inside quotes: Position cursor anywhere between quotes, use `ci"` to change inside or `di"` to delete inside. For single quotes use `ci'` or `di'`.

    How to delete a word: Use `diw` to delete inner word (just the word) or `daw` to delete a word (includes trailing space). Use `ciw` to change the word.

    How to delete a line: Use `dd` to delete the line. Use `D` or `d$` to delete from cursor to end of line. Use `d0` or `d^` to delete to beginning.

    How to delete multiple lines: Use `{count}dd` like `5dd` to delete 5 lines. Or use `d{motion}` like `dG` to delete to end of file.

    How to copy and paste: Use `yy` to yank (copy) a line, `p` to paste after cursor, `P` to paste before. Use `"+y` to copy to system clipboard.

    How to undo and redo: Use `u` to undo, `Ctrl+r` to redo. Use `:earlier 5m` to go back 5 minutes, `:later 5m` to go forward.

    How to search and replace: Use `/pattern` to search, then `:%s/old/new/g` to replace all, or `cgn` to change next match (repeatable with `.`).

    How to indent code: Use `>>` to indent line, `<<` to unindent. In visual mode, `>` and `<`. Use `=` to auto-indent, `gg=G` for entire file.

    How to select text in visual mode: `v` for character, `V` for lines, `Ctrl+v` for block/column. Then use motion keys to expand selection.

    How to record and play macros: `qa` to start recording to register a, perform actions, `q` to stop. `@a` to play, `@@` to repeat, `10@a` for 10 times.

    How to jump between files: Use `Ctrl+o` and `Ctrl+i` for jump list. Use `:e filename` to open, `Ctrl+^` to switch to alternate file.

    How to split windows: `:sp` for horizontal, `:vsp` for vertical. `Ctrl+w` then `h/j/k/l` to navigate, `Ctrl+w q` to close.
    """
    
    /// Combined reference for RAG indexing
    static var fullReference: String {
        return reference + "\n\n" + extendedReference
    }
}
