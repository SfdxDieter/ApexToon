/**
 * Configuration options for decoding TOON format to objects.
 */
global class DecodeOptions {
    private static final PathExpansion DEFAULT_PATH_EXPANSION = PathExpansion.NONE;
    private static final Boolean DEFAULT_STRICT_MODE = false;

    global PathExpansion pathExpansion { get; set; }
    global Boolean strictMode { get; set; }

    global DecodeOptions() {
        this.pathExpansion = DEFAULT_PATH_EXPANSION;
        this.strictMode = DEFAULT_STRICT_MODE;
    }

    global DecodeOptions(PathExpansion pathExpansion, Boolean strictMode) {
        this.pathExpansion = pathExpansion;
        this.strictMode = strictMode;
    }
}
