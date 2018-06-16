import dsfml.graphics;
import dsfml.window;
import dsfml.system;

class Cell
{
	Vector2f pos;
	bool shown;
	int numNeighbors;
	RectangleShape current;
	bool mine;
	bool exploded;
	bool flagged;
	int size;

	this(Vector2f pos, int size)
	{
		this.pos = pos;
		this.current = new RectangleShape();
		this.current.position(this.pos);
		this.current.fillColor(Color(255, 255, 255));
		this.current.size = Vector2f(size, size);
		this.size = size;
	}

	void draw(RenderWindow window, Texture[] board, Texture blank, Texture mine, Texture exploded, Texture flag)
	{
		if (shown)
		{
			if (this.exploded)
				this.current.setTexture(exploded);
			else if (this.mine)
				this.current.setTexture(mine);
			else
				this.current.setTexture(board[numNeighbors]);
		}
		else
		{
			if (this.flagged)
				this.current.setTexture(flag);
			else
				this.current.setTexture(blank);
		}
		window.draw(this.current);
	}

	void show()
	{
		this.shown = true;
	}

	bool isShown()
	{
		return this.shown;
	}

	int countNeighbors(Cell[][] cells)
	{
		Vector2i curr = Vector2i(cast(int) this.pos.x / this.size, cast(int) this.pos.y / this.size);
		int count;
		foreach (i; curr.x - 1 .. curr.x + 2)
			foreach (j; curr.y - 1 .. curr.y + 2)
				if (i >= 0 && i < cells.length && j >= 0 && j < cells.length)
					if (cells[i][j] != this && cells[i][j].mine)
						count++;
		return count;
	}
}