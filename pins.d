import std.stdio, std.conv, std.string, std.getopt, std.exception, std.ascii, std.algorithm;

struct Variable {
    string name;
    int start, min, max;
    double c, R;
}

Variable[] read_variables(string fileName)
{
    writefln("Reading variables from %s:", fileName);

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
        enforce(all!isAlphaNum(tokens[0]), "name must be a string!");
        enforce(isNumeric(tokens[1]), "start must be numeric!");
        enforce(isNumeric(tokens[2]), "min must be numeric!");
        enforce(isNumeric(tokens[3]), "max must be numeric!");
        enforce(isNumeric(tokens[4]), "c must be numeric!");
        enforce(isNumeric(tokens[5]), "R must be numeric!");

        // Cast and append to variables[]
        variables ~= Variable(tokens[0], to!int(tokens[1]),
            to!int(tokens[2]), to!int(tokens[3]),
            to!double(tokens[4]), to!double(tokens[5]));
    }

    return variables;
}

void main(string[] args)
{
    // Options, with default value (if any)
    string enginePath,
        bookPath = "book.epd",
        variablesPath = "variables.csv",
        tuneLogPath = "tune.log",
        uciLogPath = "uci_%d.log";
    int baseTime = 4000, increment = 40,
        resignThreshold = 500, resignCount = 6,
        drawThreshold = 20, drawCount = 8,
        concurrency = 1, iterations = 10000;

    // Parse options
    auto opt = getopt(args,
        // Chess options
        "engine|e", "uci engine file", &enginePath,
        "concurrency|c", "[" ~ to!string(concurrency) ~ "] number of concurrent games", &concurrency,
        "openings|o", "[" ~ bookPath ~ "] file of FEN start positions", &bookPath,
        "time|t", "[" ~ to!string(baseTime) ~ "] base time in ms", &baseTime,
        "increment|i", "[" ~ to!string(increment) ~ "] increment in ms", &increment,
        "resignthreshold|rt", "[" ~ to!string(resignThreshold) ~ "] resign threshold in cp", &resignThreshold,
        "resigncount|rc", "[" ~ to!string(resignCount) ~ "] resign count in plies", &resignCount,
        "drawthreshold|dt", "[" ~ to!string(drawThreshold) ~ "] draw threshold in cp", &drawThreshold,
        "drawcount|dc", "[" ~ to!string(drawCount) ~ "] draw count in plies", &drawCount,

        // SPSA options
        "variables|v", "[" ~ variablesPath ~ "] csv file of tuning variables", &variablesPath,
        "tunelog|tl", "[" ~ tuneLogPath ~ "] log file for tuning", &tuneLogPath,
        "ucilog|ul", "[" ~ uciLogPath ~ "] log file for uci communications (%d for thread id when using concurrency)", &uciLogPath,
        "iterations|it", "[" ~ to!string(iterations) ~ "] number of iterations, where each iteration plays 2 games", &iterations
    );

    if (opt.helpWanted) {
        defaultGetoptPrinter("Options [default]", opt.options);
        return;
    }

    const Variable[] variables = read_variables(variablesPath);
}
