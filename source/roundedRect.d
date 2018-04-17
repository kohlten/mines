import dsfml.graphics;
import dsfml.window;
import dsfml.system;

class RoundedRectangle
{
	Vector2f position;
	Vector2f size;
	private Vertex[] lines;
	private float angle = 10.0;

	this()
	{ }

	void setPosition(Vector2f position)
	{
		this.position = position;
	}

	void setSize(Vector2f size)
	{
		this.size = size;
	}

	void draw(RenderWindow window)
	{
		window.draw(this.lines, PrimitiveType.Lines);
	}

	void createRectangle()
	{
		float current = this.angle;
		while (current < (this.angle + 360.0))
		{
			float x = this.position.x + (cos(current) * 20);
			float y = this.position.y + (sin(current) * 20);
			if (x >= this.position.x && x <= this.position.x + 20 && y >= this.position.y - 20 && y <= this.position.y)
				x += this.size.x / 2;
			if (x >= this.position.x - 20 && x <= this.position.x && y >= this.position.y && y <= this.position.y + 20)
				y += this.size.y / 2;
			if (x >= this.position.x && x <= this.position.x + 20 && y >= this.position.y && y <= this.position.y + 20)
			{
				x += this.size.x / 2;
				y += this.size.y / 2;
			}
			this.lines ~= Vertex(Vector2f(x, y), Color(255, 255, 255));
			current += 0.1;
		}
	}
}