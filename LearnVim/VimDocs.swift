import Foundation

/// Hardcoded Vim reference for the prototype.
/// Will be replaced with RAG-based retrieval later.
struct VimDocs {
    
    static let systemPrompt = """
    You are a Vim expert. RESPOND WITH KEYSTROKES ONLY.
    
    RULES:
    1. Start your response with the keys in backticks, nothing before them
    2. Maximum ONE short sentence after the keys, only if truly needed
    3. NEVER write "To do X, use:" or "You can use:" — just the keys
    4. NEVER explain what the command does unless asked
    
    GOOD: `G`
    GOOD: `ciw` — change inner word
    BAD: To move to the end of a file, use: G
    BAD: This will take you to the last line.
    """
    static let reference = """
    # Vim Quick Reference

    ## Modes
    - Normal mode: Default mode for navigation and commands. Press Esc to return here.
    - Insert mode: For typing text. Enter with i, a, o, etc.
    - Visual mode: For selecting text. Enter with v (char), V (line), Ctrl+v (block).
    - Command-line mode: For ex commands. Enter with : from Normal mode.
    - Replace mode: Overwrite text. Enter with R.

    ## Movement (Normal Mode)
    - h, j, k, l: Left, down, up, right
    - w: Next word start
    - b: Previous word start
    - e: Next word end
    - 0: Start of line
    - ^: First non-blank character
    - $: End of line
    - gg: Go to first line
    - G: Go to last line
    - {number}G: Go to line number
    - %: Jump to matching bracket
    - f{char}: Jump to next occurrence of char on line
    - t{char}: Jump to just before next occurrence of char on line
    - ;: Repeat last f/t motion
    - ,: Repeat last f/t motion in reverse
    - Ctrl+d: Half page down
    - Ctrl+u: Half page up
    - Ctrl+f: Full page down
    - Ctrl+b: Full page up
    - H: Top of screen
    - M: Middle of screen
    - L: Bottom of screen
    - zz: Center cursor line on screen
    - zt: Cursor line to top of screen
    - zb: Cursor line to bottom of screen

    ## Entering Insert Mode
    - i: Insert before cursor
    - I: Insert at start of line
    - a: Append after cursor
    - A: Append at end of line
    - o: Open new line below
    - O: Open new line above
    - s: Substitute character (delete char, enter insert)
    - S: Substitute line (delete line, enter insert)
    - C: Change to end of line
    - ci{: Change inside braces
    - cw: Change word

    ## Editing (Normal Mode)
    - x: Delete character under cursor
    - X: Delete character before cursor
    - dd: Delete (cut) line
    - dw: Delete word
    - d$: Delete to end of line
    - D: Delete to end of line (same as d$)
    - yy: Yank (copy) line
    - yw: Yank word
    - y$: Yank to end of line
    - p: Paste after cursor
    - P: Paste before cursor
    - u: Undo
    - Ctrl+r: Redo
    - .: Repeat last change
    - ~: Toggle case of character
    - >>: Indent line
    - <<: Unindent line
    - ==: Auto-indent line
    - J: Join line below with current line

    ## Text Objects (use with d, c, y, v)
    - iw: Inner word
    - aw: A word (includes surrounding space)
    - i": Inner double quotes
    - a": A double-quoted string (includes quotes)
    - i': Inner single quotes
    - i(: Inner parentheses
    - i{: Inner braces
    - i[: Inner brackets
    - it: Inner tag (HTML/XML)
    - ip: Inner paragraph
    - ap: A paragraph (includes surrounding blank lines)
    - is: Inner sentence
    - as: A sentence

    ## Visual Mode
    - v: Character-wise visual
    - V: Line-wise visual
    - Ctrl+v: Block visual
    - o: Move to other end of selection
    - gv: Reselect last visual selection
    - After selecting: d (delete), y (yank), c (change), > (indent), < (unindent)

    ## Search and Replace
    - /pattern: Search forward
    - ?pattern: Search backward
    - n: Next match
    - N: Previous match
    - *: Search for word under cursor (forward)
    - #: Search for word under cursor (backward)
    - :%s/old/new/g: Replace all in file
    - :%s/old/new/gc: Replace all with confirmation
    - :s/old/new/g: Replace all in current line

    ## Files and Buffers
    - :w: Save
    - :q: Quit
    - :wq or :x or ZZ: Save and quit
    - :q!: Quit without saving
    - :e filename: Open file
    - :bn: Next buffer
    - :bp: Previous buffer
    - :ls: List buffers
    - :bd: Close buffer

    ## Windows and Tabs
    - :split or :sp: Horizontal split
    - :vsplit or :vsp: Vertical split
    - Ctrl+w h/j/k/l: Move between windows
    - Ctrl+w =: Equal size windows
    - Ctrl+w _: Maximize height
    - Ctrl+w |: Maximize width
    - :tabnew: New tab
    - gt: Next tab
    - gT: Previous tab
    - :tabclose: Close tab

    ## Macros
    - q{register}: Start recording macro (e.g., qa)
    - q: Stop recording
    - @{register}: Play macro (e.g., @a)
    - @@: Replay last macro
    - {count}@{register}: Play macro N times

    ## Marks
    - m{letter}: Set mark (lowercase=local, uppercase=global)
    - '{letter}: Jump to mark line
    - `{letter}: Jump to mark position
    - :marks: List marks

    ## Registers
    - "{register}y: Yank into register
    - "{register}p: Paste from register
    - ": is the default register
    - "0 contains last yank
    - "1-"9 contain last deletes
    - "+ is the system clipboard
    - :registers: List registers

    ## Folding
    - zf: Create fold
    - zo: Open fold
    - zc: Close fold
    - za: Toggle fold
    - zR: Open all folds
    - zM: Close all folds

    ## Common Patterns
    - ciw: Change inner word (replace a word)
    - dap: Delete a paragraph
    - yi": Yank text inside double quotes
    - va{: Select a block including braces
    - gUiw: Uppercase inner word
    - guiw: Lowercase inner word
    - dG: Delete from cursor to end of file
    - =G: Auto-indent from cursor to end of file

    ## Tips
    - Use counts: 5dd deletes 5 lines, 3w moves 3 words forward
    - Combine operators with motions: d2w deletes 2 words
    - . repeats the last change — the most powerful Vim command
    - Use text objects over motions: ciw is better than bcw
    - :set number / :set relativenumber for line numbers
    - :set hlsearch to highlight search matches
    - :noh to clear search highlighting
    - :set ignorecase / :set smartcase for search case handling
    """

    /// Build a prompt context from the reference docs
    /// - Note: Deprecated. Use `RAGService.shared.contextForQuery()` for RAG-based retrieval.
    @available(*, deprecated, message: "Use RAGService.shared.contextForQuery() for better retrieval")
    static func contextForQuery(_ query: String) -> String {
        // Legacy: returns full reference
        // Now replaced by RAG-based retrieval in RAGService
        
        var context = """
        Reference material:
        \(reference)
        """
        
        // Add user's vim setup context if available
        if let vimContext = VimContext.contextDescription() {
            context += "\n\nUser's setup: \(vimContext)"
        }
        
        context += "\n\nQuestion: \(query)"
        
        return context
    }
}
