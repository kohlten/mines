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
	Vector2i size = Vector2i(500, 500);
	VideoMode mode = VideoMode(size.x, size.y);
	Vector2i monitorSize = Vector2i(mode.getDesktopMode().width, mode.getDesktopMode().height);
	RenderWindow window = new RenderWindow(VideoMode(size.x, size.y), "Mines", RenderWindow.Style.Titlebar | RenderWindow.Style.Close);
	window.position(Vector2i(monitorSize.x / 2 - size.x / 2, monitorSize.y / 2 - size.y / 2));
	window.setVerticalSyncEnabled(true);
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
