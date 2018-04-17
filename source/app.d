import dsfml.window;
import dsfml.system;
import dsfml.graphics;

import game;

import std.random : Random, unpredictableSeed;

void main()
{
	Random rng = Random(unpredictableSeed);
	auto game = new Game(64 * 16, 64 * 16, Color(255, 255, 255), rng);
	game.run();
}
