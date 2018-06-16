import dsfml.graphics;
import dsfml.window;
import dsfml.system;

import std.conv : to;
import std.random : uniform;
import std.stdio : writeln;

import cell;

class Game
{
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
	int cellSize = 32;
	int mines = 100;

	// First click
	bool clicked;

	// Deny clicking
	bool allow = true;

	// Cells to hold the mines or nothing
	Cell[][] cells;

	this(int x, int y, int mines, int cellSize)
	{
		this.size = Vector2f(x, y);
		this.color = Color(255, 255, 255);
		this.window = new RenderWindow(VideoMode(this.size.x, this.size.y), "Mines");
		this.window.setFramerateLimit(60);

		this.cellSize = cellSize;
		this.cells.length = this.size.y / this.cellSize;

		if (x > VideoMode.getDesktopMode().width || y > VideoMode.getDesktopMode().height)
			assert(0, "Width or height is greater than your current display!");

		foreach (i; 0 .. this.size.y / this.cellSize)
		{
			this.cells[i].length = this.size.x / this.cellSize;
			foreach (j; 0 .. this.size.x / this.cellSize)
				this.cells[i][j] = new Cell(Vector2f(i * this.cellSize, j * this.cellSize), this.cellSize);
		}

		this.loadTextures();
		this.mines = mines;
	}

	void run()
	{
		while (this.window.isOpen())
		{
			this.getEvents();
			this.window.clear(this.color);
			foreach (i; 0 .. this.size.x / this.cellSize)
				foreach (j; 0 .. this.size.y / this.cellSize)
					this.cells[i][j].draw(this.window, this.board, this.blank, this.bomb, this.failed, this.flag);
			this.window.display();
		}
	}

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
			if (event.type == Event.EventType.KeyPressed && !this.allow)
				this.showAll(false);
		}
	}

	void setMines(Cell current)
	{
		import std.algorithm : canFind;

		Vector2i[] badPlaces = this.findSpotsAround!Vector2i(current, true);
		Vector2i pos;

		foreach (i; 0 .. this.mines)
		{
			do
				pos = Vector2i(uniform(0, this.size.x / this.cellSize), uniform(0, this.size.y / this.cellSize));
			while (badPlaces.canFind(pos) || this.cells[pos.x][pos.y].mine);
			this.cells[pos.x][pos.y].mine = true;
		}
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

	void countAllNeighbors()
	{
		foreach (line; this.cells)
			foreach (cell; line)
				cell.numNeighbors = cell.countNeighbors(this.cells);
	}

	void findBlanks(Cell current)
	{
		import stack;

		Stack!Cell arr = new Stack!Cell();
		if (current.numNeighbors > 0)
		{
			current.show();
			return;
		}
		arr.push(current);
		Cell next = this.getNext(current);
		while (arr.getLen() > 0)
		{
			current.show();
			next = this.getNext(current);
			if (next)
			{
				current = next;
				arr.push(next);
			}
			else
				current = arr.pop();
		} 
	}

	Cell getNext(Cell current)
	{
		Cell[] nextOnes;
		Vector2i[] pos = this.findSpotsAround!Vector2i(current);

		if (current.numNeighbors > 0)
		{
			current.show();
			return null;
		}
		foreach (i; 0 .. pos.length)
			if (pos[i].x >= 0 && pos[i].x < cells.length && pos[i].y >= 0 && pos[i].y < cells.length)
			{
				if (!this.cells[pos[i].x][pos[i].y].mine && !this.cells[pos[i].x][pos[i].y].isShown()
					&& !this.cells[pos[i].x][pos[i].y].numNeighbors)
					nextOnes ~= this.cells[pos[i].x][pos[i].y];
				else if (this.cells[pos[i].x][pos[i].y].numNeighbors > 0)
					this.cells[pos[i].x][pos[i].y].show();
			}
		if (nextOnes.length > 0)
			return (nextOnes[uniform(0, nextOnes.length)]);
		else
			return null;
	}

	void showAll(bool show)
	{
		foreach (line; this.cells)
			foreach (cell; line)
				cell.show();
	}

	int countRight()
	{
		int count;

		foreach (line; this.cells)
			foreach (cell; line)
				if (cell.mine && cell.flagged)
					count++;
		return count;
	}

	T[] findSpotsAround(T)(Cell current, bool addCurrent = false)
	{
		T curr = T(cast(int) current.pos.x / this.cellSize,
			cast(int) current.pos.y / this.cellSize);
		T[] places;

		foreach (i; curr.x - 1 .. curr.x + 2)
			foreach (j; curr.y - 1 .. curr.y + 2)
				if (!(i == curr.x && j == curr.y))
					places ~= T(i, j);
		if (!addCurrent)
			return places;
		else
			return places ~ curr;
	}

	void right(int i, int j)
	{
		if (!this.cells[i][j].isShown())
		{
			if (this.cells[i][j].flagged)
				this.cells[i][j].flagged = false;
			else
				this.cells[i][j].flagged = true;
		}
		if (this.countRight() == this.mines)
		{
			writeln("Done!");
			this.allow = false;
			this.showAll(true);
		}
	}

	void left(int i, int j)
	{
		if (!this.cells[i][j].isShown())
			this.cells[i][j].show();
		if (!this.clicked)
		{
			this.clicked = true;
			this.setMines(this.cells[i][j]);
			this.countAllNeighbors();
		}
		if (this.cells[i][j].numNeighbors == 0)
			foreach(k; 0 .. 2)
				this.findBlanks(this.cells[i][j]);
		if (this.cells[i][j].mine)
		{
			writeln("Correct: ", countRight());
			this.allow = false;
			this.cells[i][j].exploded = true;
			this.showAll(true);
		}
	}
}