import dsfml.graphics;
import dsfml.window;
import dsfml.system;

import std.conv : to;
import std.random : Random, unpredictableSeed, uniform;
import std.stdio : writeln;
import core.stdc.stdlib : exit;

import cell;

class Game
{
	RenderWindow window;
	Vector2i size;
	Color color;
	ContextSettings settings;
	Texture[] board;
	Texture blank;
	Texture bomb;
	Texture failed;
	Texture flag;
	int cellSize = 32;
	int mines = 70;
	int clicked;
	bool allow = true;
	Random rng;

	Cell[][] cells;

	this(int x, int y, Color color, Random rng)
	{
		this.size.x = x;
		this.size.y = y;
		this.color = color;
		this.window = new RenderWindow(VideoMode(this.size.x, this.size.y), "Mines");
		this.window.setFramerateLimit(60);
		this.cells.length = this.size.y / this.cellSize;
		foreach (i; 0 .. this.size.x / this.cellSize)
		{
			this.cells[i].length = this.size.x / this.cellSize;
			foreach (j; 0 .. this.size.y / this.cellSize)
				this.cells[i][j] = new Cell(Vector2f(i * this.cellSize, j * this.cellSize), this.cellSize);
		}
		this.loadTextures();
		this.rng = rng;
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
		}
	}

	void setMines(Cell current)
	{
		import std.algorithm : canFind;

		Vector2i[] badPlaces = this.findSpotsAround!Vector2i(current);
		Vector2i pos;

		foreach (i; 0 .. this.mines)
		{
			do
				pos = Vector2i(uniform(0, this.size.x / this.cellSize, this.rng), uniform(0, this.size.y / this.cellSize, this.rng));
			while (badPlaces.canFind(pos) || this.cells[pos.x][pos.y].mine);
			this.cells[pos.x][pos.y].mine = true;
		}
	}

	void loadTextures()
	{
		bool success = true;
		foreach (i; 0 .. 8)
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
		if (!success)
		{
			writeln("Failed to load textures!");
			exit(1);
		}
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
			current.shown = true;
			return;
		}
		arr.push(current);
		Cell next = this.getNext(current);
		while (arr.getLen() > 0)
		{
			current.shown = true;
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
			current.shown = true;
			return null;
		}
		foreach (i; 0 .. pos.length)
			if (pos[i].x >= 0 && pos[i].x < cells.length && pos[i].y >= 0 && pos[i].y < cells.length)
			{
				if (!this.cells[pos[i].x][pos[i].y].mine && !this.cells[pos[i].x][pos[i].y].shown && !this.cells[pos[i].x][pos[i].y].numNeighbors)
					nextOnes ~= this.cells[pos[i].x][pos[i].y];
				else if (this.cells[pos[i].x][pos[i].y].numNeighbors > 0)
					this.cells[pos[i].x][pos[i].y].show();
			}
		if (nextOnes.length > 0)
			return (nextOnes[uniform(0, nextOnes.length, this.rng)]);
		else
			return null;
	}

	void showAll()
	{
		foreach (line; this.cells)
			foreach (cell; line)
				cell.shown = true;
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

	T[] findSpotsAround(T)(Cell current)
	{
		T curr = Vector2i(cast(int) current.pos.x / this.cellSize,
			cast(int) current.pos.y / this.cellSize);
		T[] places = [Vector2i(curr.x + 1, curr.y),		Vector2i(curr.x, curr.y + 1),	  Vector2i(curr.x - 1, curr.y), 	Vector2i(curr.x, curr.y - 1),
					  Vector2i(curr.x + 1, curr.y + 1), Vector2i(curr.x - 1, curr.y - 1), Vector2i(curr.x - 1, curr.y + 1), Vector2i(curr.x + 1, curr.y + 1)];
		return places;
	}

	void right(int i, int j)
	{
		if (!this.cells[i][j].shown)
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
			this.showAll();
		}
	}

	void left(int i, int j)
	{
		if (!this.cells[i][j].shown)
			this.cells[i][j].shown = true;
		if (!this.clicked)
		{
			this.clicked = true;
			this.setMines(this.cells[i][j]);
			this.countAllNeighbors();
		}
		if (this.cells[i][j].numNeighbors == 0)
			this.findBlanks(this.cells[i][j]);
		if (this.cells[i][j].mine)
		{
			this.allow = false;
			this.cells[i][j].exploded = true;
			this.showAll();
		}
	}
}