/**
 * Configuration options for encoding objects to TOON format.
 */
global class EncodeOptions {
    global Integer indent { get; set; }
    global ToonDelimiter delimiter { get; set; }

    global EncodeOptions() {
        this.indent = 2;
        this.delimiter = ToonDelimiter.COMMA;
    }

    global EncodeOptions(Integer indent, ToonDelimiter delimiter) {
        this.indent = indent;
        this.delimiter = delimiter;
    }

    global String getDelimiterString() {
        switch on this.delimiter {
            when COMMA {
                return ',';
            }
            when TAB {
                return '\t';
            }
            when PIPE {
                return '|';
            }
            when else {
                return ',';
            }
        }
    }
}
