import dsfml.window;
import dsfml.system;
import dsfml.graphics;

import game;

import std.stdio : writeln;
import std.conv : to;

enum
{
	MENU = 1 << 10,
	GAME = 1 << 11
}

enum
{
	EASY = 0,
	MEDIUM = 1,
	HARD = 2
}

void main()
{
	writeln(MENU, " ", GAME, " E: ", EASY, " M: ", MEDIUM, " H:", HARD);
	Vector2i size = Vector2i(500, 500);
	RenderWindow window = new RenderWindow(VideoMode(size.x, size.y), "Mines");
	int mode = 1;
	auto game = new Game(window, mode, size);
	game.run();
}
