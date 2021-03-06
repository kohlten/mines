import dsfml.graphics;
import dsfml.system;

import std.conv : to;
import std.random : uniform;
import std.stdio : writeln;

import cell;
import algorithms;
import submenu;

class Game
{
private:
	// Window values
	RenderWindow window;
	Vector2i size;
	Color color;

	// Textures
	Texture[] board;
	Texture blank;
	Texture bomb;
	Texture failed;
	Texture flag;

	// Cells
	int cellSize;
	int mines;

	// First click
	bool clicked;

	// Deny clicking
	bool allow = true;

	// Exit game
	bool running = true;
	bool done = false;

	// Cells to hold the mines or nothing
	Cell[][] cells;

public:
	this(RenderWindow window, int mode, Vector2i size)
	{
		this.size = size;
		this.color = Color(120, 120, 120);
		if (mode == 0)
		{
            this.mines = 10;
            this.cellSize = this.size.x / 9; // 9 * 9
        }
        if (mode == 1)
        {
            this.mines = 35;
            this.cellSize = this.size.x / 16; // 16 * 16
        }
        if (mode == 2)
		{
            this.mines = 85;
            this.cellSize = this.size.x / 24; // 24 * 24
        }
		this.window = window;
		this.window.setFramerateLimit(60);

		this.cellSize = cellSize;
		this.cells.length = this.size.y / this.cellSize;

		foreach (i; 0 .. this.size.y / this.cellSize)
		{
			this.cells[i].length = this.size.x / this.cellSize;
			foreach (j; 0 .. this.size.x / this.cellSize)
				this.cells[i][j] = new Cell(Vector2f(i * this.cellSize, j * this.cellSize), this.cellSize);
		}

		this.loadTextures();
		this.mines = mines;
	}

	bool run()
	{
		while (this.window.isOpen() && this.running)
		{
			this.getEvents();
			this.draw();
		}
		return done;
	}

private:
	void getEvents()
	{
		Event event;
		while (this.window.pollEvent(event))
		{
			if (event.type == Event.EventType.Closed)
				window.close();
			if (event.type == Event.EventType.MouseButtonPressed && this.allow)
			{
				int i = event.mouseButton.x / this.cellSize;
				int j = event.mouseButton.y / this.cellSize;
				if (event.mouseButton.button == Mouse.Button.Left)
					this.left(i, j);
				if (event.mouseButton.button == Mouse.Button.Right)
					this.right(i, j);
			}
		}
	}

	void setMines(Cell current)
	{
		import std.algorithm : canFind;

		Vector2i pos;
		Vector2i[] badPlaces = findSpotsAround!Vector2i(current, this.cellSize, true);

		foreach (i; 0 .. this.mines)
		{
			do
				pos = Vector2i(uniform(0, this.size.x / this.cellSize), uniform(0, this.size.y / this.cellSize));
			while (badPlaces.canFind(pos) || this.cells[pos.x][pos.y].mine);
			this.cells[pos.x][pos.y].mine = true;
		}
	}

	void draw()
	{
		this.window.clear(this.color);
		foreach (i; 0 .. this.size.x / this.cellSize)
			foreach (j; 0 .. this.size.y / this.cellSize)
				this.cells[i][j].draw(this.window, this.board, this.blank, this.bomb, this.failed, this.flag);
		this.window.display();
	}

	void loadTextures()
	{
		bool success = true;
		foreach (i; 0 .. 9)
		{
			Texture tmp = new Texture();
			if (!tmp.loadFromFile("sprites/" ~ to!string(i) ~ "board.png"))
				success = false;
			this.board ~= tmp;
		}
		this.blank = new Texture();
		this.bomb = new Texture();
		this.flag = new Texture();
		this.failed = new Texture();
		if (!this.failed.loadFromFile("sprites/bomb_red.png") || !this.blank.loadFromFile("sprites/blank.png") ||
			!this.bomb.loadFromFile("sprites/bomb.png") || !this.flag.loadFromFile("sprites/flag.png"))
				success = false;
		assert(success, "Failed to load Textures!");
	}

	void right(int i, int j)
	{
		if (!this.cells[i][j].isShown())
				this.cells[i][j].flagged = !this.cells[i][j].flagged;
		if (countRight(this.cells) == this.mines)
		{
			this.allow = false;
			showAll(this.cells, true);
			this.draw();
			this.startSubmenu("You have won!");
		}
	}

	void left(int i, int j)
	{
		if (!this.cells[i][j].isShown())
			this.cells[i][j].show(true);
		if (!this.clicked)
		{
			this.clicked = true;
			this.setMines(this.cells[i][j]);
			countAllNeighbors(this.cells);
		}
		if (this.cells[i][j].getNeighbors() == 0)
			foreach(k; 0 .. 2)
				findBlanks(this.cells[i][j], this.cells, this.cellSize);
		if (this.cells[i][j].mine)
		{
			this.allow = false;
			this.cells[i][j].exploded = true;
			showAll(this.cells, true);
			this.draw();
			this.startSubmenu("You have lost!");
		}
	}

	void startSubmenu(string text)
	{
		SubMenu submenu = new SubMenu(text);
		submenu.run();
		this.done = submenu.getDone();
		if (this.done)
			this.window.close();
		this.running = false;
	}
}
