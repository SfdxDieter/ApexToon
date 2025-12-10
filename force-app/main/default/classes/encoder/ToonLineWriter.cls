/**
 * Builds TOON output string with proper indentation.
 * 
 * Accumulates lines of output and manages indentation depth.
 */
public class ToonLineWriter {
    private final List<String> lines;
    private String indentationString;
    
    public ToonLineWriter(Integer indentSize) {
        this.lines = new List<String>();
        this.indentationString = '';
        for (Integer i = 0; i < indentSize; i++) {
            this.indentationString += ' ';
        }
    }
    
    /**
     * Add a line with specified indentation depth.
     * 
     * @param depth Number of indentation levels (0 = no indent)
     * @param content Line content to add
     */
    public void push(Integer depth, String content) {
        String indent = '';
        for (Integer i = 0; i < depth; i++) {
            indent += this.indentationString;
        }
        this.lines.add(indent + content);
    }
    
    /**
     * Get the final TOON output string.
     * 
     * @return All lines joined with newlines
     */
    public override String toString() {
        return String.join(this.lines, '\n');
    }
    
    /**
     * Get number of lines written.
     * 
     * @return Line count
     */
    public Integer size() {
        return this.lines.size();
    }
    
    /**
     * Check if writer is empty.
     * 
     * @return True if no lines have been written
     */
    public Boolean isEmpty() {
        return this.lines.isEmpty();
    }
}
