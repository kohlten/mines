import dsfml.graphics;
import dsfml.window;
import dsfml.system;
import std.random : uniform;
import cell;

void findBlanks(Cell current, Cell[][] cells, int size)
{
	import stack;

	Stack!Cell arr = new Stack!Cell();
	if (current.numNeighbors > 0)
	{
		current.show(true);
		return;
	}
	arr.push(current);
	Cell next = getNext(current, cells, size);
	while (arr.getLen() > 0)
	{
		current.show(true);
		next = getNext(current, cells, size);
		if (next)
		{
			current = next;
			arr.push(next);
		}
		else
			current = arr.pop();
	} 
}

static Cell getNext(Cell current, Cell[][] cells, int size)
{
	Cell[] nextOnes;
	Vector2i[] pos = findSpotsAround!Vector2i(current, size);

	if (current.numNeighbors > 0)
	{
		current.show(true);
		return null;
	}
	foreach (i; 0 .. pos.length)
		if (pos[i].x >= 0 && pos[i].x < cells.length && pos[i].y >= 0 && pos[i].y < cells.length)
		{
			if (!cells[pos[i].x][pos[i].y].mine && !cells[pos[i].x][pos[i].y].isShown()
				&& !cells[pos[i].x][pos[i].y].numNeighbors)
				nextOnes ~= cells[pos[i].x][pos[i].y];
			else if (cells[pos[i].x][pos[i].y].numNeighbors > 0)
				cells[pos[i].x][pos[i].y].show(true);
		}
	if (nextOnes.length > 0)
		return (nextOnes[uniform(0, nextOnes.length)]);
	else
		return null;
}

void countAllNeighbors(Cell[][] cells)
{
	foreach (line; cells)
		foreach (cell; line)
			cell.numNeighbors = cell.countNeighbors(cells);
}

void showAll(Cell[][] cells, bool newBool)
{
	foreach (line; cells)
		foreach (cell; line)
			cell.show(newBool);
}

int countRight(Cell[][] cells)
{
	int count;

	foreach (line; cells)
		foreach (cell; line)
			if (cell.mine && cell.flagged)
				count++;
	return count;
}

T[] findSpotsAround(T)(Cell current, int cellSize, bool addCurrent = false)
{
	T[] places;
	T curr = T(cast(int) current.pos.x / cellSize,
		cast(int) current.pos.y / cellSize);

	foreach (i; curr.x - 1 .. curr.x + 2)
		foreach (j; curr.y - 1 .. curr.y + 2)
			if (!(i == curr.x && j == curr.y))
				places ~= T(i, j);
	if (!addCurrent)
		return places;
	else
		return places ~ curr;
}

bool canFindVec(T)(T[] vecs, T vec)
{
	foreach (i; 0 .. vecs.length)
	{
		if (vec.x == vecs[i].x && vec.y == vecs[i].y)
			return true;
	}
	return false;
}