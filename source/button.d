import dsfml.graphics;
import dsfml.system;
import dsfml.window;

import std.stdio;

class Button
{
private:
	RenderWindow window;

	Vector2f pos;
	Vector2f size;

	Texture buttonTex;

	Text text;

	RectangleShape button;

public:
	this(RenderWindow window, Vector2f pos, Vector2f size, Texture buttonTex, Font font, string text, uint textSize = 30)
	{
		this.pos = pos;
		this.size = size;
		this.window = window;
		this.buttonTex = buttonTex;	
		this.setUpText(font, text, textSize);
		this.setUpButton();
	}

	void update()
	{
		if (this.isPressed())
		{
			this.button.fillColor = Color(150, 150, 150);
			this.text.setColor = Color(255, 255, 255);
		}
		else
		{
			this.button.fillColor = Color(255, 255, 255);
			this.text.setColor = Color(0, 0, 0);
		}
	}

	void draw()
	{
		this.window.draw(this.button);
		this.window.draw(this.text);
	}

	bool isPressed()
	{
		Vector2f mousePos = Mouse.getPosition(this.window);
		if (mousePos.x <= (this.pos.x + this.size.x / 2) && mousePos.x >= this.pos.x - this.size.x / 2)
			if (mousePos.y <= (this.pos.y + this.size.y / 2) && mousePos.y >= this.pos.y - this.size.y / 2)
				return true;
		return false;
	}
private:
	void setUpText(Font font, string text, uint textSize)
	{
		this.text = new Text();
		this.text.setColor = Color(0, 0, 0);
		this.text.setFont(font);
		this.text.setCharacterSize(textSize);
		this.text.setString(text);

		FloatRect textRect = this.text.getLocalBounds();
		writeln(textSize);
		this.text.origin = Vector2f(textRect.width / 2, textRect.height / 2);
		this.text.position = this.pos;
	}

	void setUpButton()
	{
		this.button = new RectangleShape(this.size);
		this.button.fillColor = Color(255, 255, 255);
		this.button.setTexture(this.buttonTex);
		this.button.origin = Vector2f(this.button.size.x / 2, this.button.size.y / 2);
		this.button.position(this.pos);
	}
}
