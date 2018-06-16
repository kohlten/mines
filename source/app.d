import dsfml.window;
import dsfml.system;
import dsfml.graphics;

import game;

import std.stdio : writeln;
import std.conv : to;

void main(string[] argv)
{
	if (argv.length != 4)
	{
		writeln("Invalid usage!\n./bin/mines SIZE MINES CELLSIZE");
		return;
	}
	int size = to!int(argv[1]);
	int mines = to!int(argv[2]);
	int cellSize = to!int(argv[3]);
	if (size % cellSize != 0)
	{
		writeln("Size must be a multiple of cell size!");
		return;
	}
	if (mines >= (size * size) / 2)
	{
		writeln("Mines cannot be greater than all the spots!");
		return;
	}
	auto game = new Game(size, size, mines, cellSize);
	game.run();
}
