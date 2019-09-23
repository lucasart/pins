import std.range, std.stdio, std.conv, std.string;

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

        writefln("%s: start=%d, min=%d, max=%d, c=%f, R=%f", name, start, min, max, c, R);
    }
}

Variable[] read_variables(string fileName)
{
    writefln("Reading variables from %s:", fileName);
    Variable[] variables;

    auto f = File(fileName);
    string line;

    while (!(line = f.readln()).empty)
        variables ~= Variable(line.chop.split(","));

    return variables;
}

void main(string[] args)
{
    Variable[] variables = read_variables(args[1]);
}
