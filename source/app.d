import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import game;
import menu;
import states;

import std.stdio : writeln;
import std.conv : to;

int STATE = MENU;
int MODE;

void main()
{
	writeln(MENU, " ", GAME, " E: ", EASY, " M: ", MEDIUM, " H:", HARD);
	Vector2i size = Vector2i(500, 500);
	RenderWindow window = new RenderWindow(VideoMode(size.x, size.y), "Mines", RenderWindow.Style.Titlebar | RenderWindow.Style.Close);

	while (window.isOpen())
	{
		if (STATE == MENU)
		{
			Menu menu = new Menu(window, size);
			menu.run();
			MODE = menu.getMode();
			STATE = GAME;

		}
		else if (STATE == GAME)
		{
			Game game = new Game(window, MODE, size);
			game.run();
			STATE = MENU;
		}
	}
}
