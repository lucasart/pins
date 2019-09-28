import std.stdio, std.string, std.algorithm, std.conv: to;

struct Variable {
    string name;
    double start, min, max, c, R;
}

Variable[] read_variables(string fileName)
{
    import std.exception: enforce;
    import std.ascii: isAlphaNum;

    Variable[] variables;
    auto f = File(fileName, "r");
    string line;

    // Read file line by line
    while (!(line = f.readln()).empty) {
        // Parse line into tokens
        auto tokens = line.chop.split(",");
        writeln(tokens);

        // Validate line before casting
        enforce(tokens.length == 6, "wrong number of columns!");
        enforce(all!isAlphaNum(tokens[0]), tokens[0] ~ " must be a string!");
        foreach (t; tokens[1..$])
            enforce(isNumeric(t), t ~ " must be numeric!");

        // Cast and append to variables[]
        variables ~= Variable(tokens[0], to!int(tokens[1]),
            to!int(tokens[2]), to!int(tokens[3]),
            to!double(tokens[4]), to!double(tokens[5]));
    }

    return variables;
}

class ChessOptions {
    string enginePath, bookPath, uciLogPath;
    int baseTime, increment,
        resignThreshold, resignCount,
        drawThreshold, drawCount;

    this() {
        bookPath = "book.epd";
        uciLogPath = "uci_%d.log";
        baseTime = 4000; increment = 40;
        resignThreshold = 500; resignCount = 6;
        drawThreshold = 20; drawCount = 8;
    }
}

class TuneOptions {
    string variablesPath, tuneLogPath;
    int iterations, concurrency;

    this() {
        variablesPath = "variables.csv";
        iterations = 100;
        concurrency = 1;
        tuneLogPath = "tune.log";
    }
}

void run_tuner(ChessOptions chessOptions, TuneOptions tuneOptions)
{
    const Variable[] variables = read_variables(tuneOptions.variablesPath);
    const auto book = File(chessOptions.bookPath).byLine().map!(s => s.chop().split(";")[0]);
}

void main(string[] args)
{
    import std.getopt;

    // STEP. Initialize options with their default values
    auto chessOptions = new ChessOptions();
    auto tuneOptions = new TuneOptions();

    // STEP. Parse options
    auto optionInfo = getopt(args,
        // Chess options
        "engine", "uci engine file", &chessOptions.enginePath,
        "openings", "[" ~ chessOptions.bookPath ~ "] file of FEN start positions", &chessOptions.bookPath,
        "time", "[" ~ to!string(chessOptions.baseTime) ~ "] base time in ms", &chessOptions.baseTime,
        "increment", "[" ~ to!string(chessOptions.increment) ~ "] increment in ms", &chessOptions.increment,
        "resignthreshold", "[" ~ to!string(chessOptions.resignThreshold) ~ "] resign threshold in cp", &chessOptions.resignThreshold,
        "resigncount", "[" ~ to!string(chessOptions.resignCount) ~ "] resign count in plies", &chessOptions.resignCount,
        "drawthreshold", "[" ~ to!string(chessOptions.drawThreshold) ~ "] draw threshold in cp", &chessOptions.drawThreshold,
        "drawcount", "[" ~ to!string(chessOptions.drawCount) ~ "] draw count in plies", &chessOptions.drawCount,
        "ucilog", "[" ~ chessOptions.uciLogPath ~ "] log file for uci communications (%d for thread id when using concurrency)", &chessOptions.uciLogPath,
        // SPSA options
        "variables", "[" ~ tuneOptions.variablesPath ~ "] csv file of tuning variables", &tuneOptions.variablesPath,
        "iterations", "[" ~ to!string(tuneOptions.iterations) ~ "] number of iterations, where each iteration plays 2 games", &tuneOptions.iterations,
        "concurrency", "[" ~ to!string(tuneOptions.concurrency) ~ "] number of concurrent games", &tuneOptions.concurrency,
        "tunelog", "[" ~ tuneOptions.tuneLogPath ~ "] log file for tuning", &tuneOptions.tuneLogPath,
    );

    if (optionInfo.helpWanted) {
        defaultGetoptPrinter("Options [default]", optionInfo.options);
        return;
    }

    run_tuner(chessOptions, tuneOptions);
}
