import std.stdio, std.conv, std.string, std.getopt;

struct Variable {
    string name;
    int start, min, max;
    double c, R;

    this (string[] tokens) {
        assert(tokens.length == 6);

        name = tokens[0];
        start = to!int(tokens[1]);
        min = to!int(tokens[2]);
        max = to!int(tokens[3]);
        c = to!double(tokens[4]);
        R = to!double(tokens[5]);

        writefln("%s,%d,%d,%d,%f,%f", name, start, min, max, c, R);
    }
}

Variable[] read_variables(string fileName)
{
    writefln("Reading variables from %s:", fileName);
    writeln("name,start,min,max,c,R");

    Variable[] variables;

    auto f = File(fileName, "r");
    string line;

    while (!(line = f.readln()).empty)
        variables ~= Variable(line.chop.split(","));

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
