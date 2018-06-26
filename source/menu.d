import dsfml.graphics;
import dsfml.system;

import std.stdio;

import states;
import button;

class Menu
{
private:
	RenderWindow window;
	Vector2i size;
	Color color;

	Texture buttonTex;

	Button easyButton;
	Button mediumButton;
	Button hardButton;
	Button quitButton;

	Font font;

	int mode;

	bool running = true;

public:
	this(RenderWindow window, Vector2i size)
	{
		this.window = window;
		this.size = size;
		this.loadImages();
		this.loadFonts();
		this.setupButtons();
		this.color = Color(200, 200, 200);
	}

	void run()
	{
		while (this.window.isOpen() && this.running)
		{
			this.update();
			this.draw();
		}
	}

	int getMode()
	{
		return this.mode;
	}

private:
	void getEvents()
	{
		Event event;
		while (this.window.pollEvent(event))
		{
			switch (event.type)
			{
				case Event.EventType.Closed:
					this.window.close();
					break;
				case Event.EventType.MouseButtonPressed:
					if (this.easyButton.isPressed())
					{
						this.mode = EASY;
						this.running = false;
					}
					else if (this.mediumButton.isPressed())
					{
						this.mode = MEDIUM;
						this.running = false;
					}
					else if (this.hardButton.isPressed())
					{
						this.mode = HARD;
						this.running = false;
					}
					else if (this.quitButton.isPressed())
						this.window.close();
					break;
				default:
					break;

			}
		}
	}

	void update()
	{
		this.getEvents();
		this.easyButton.update();
		this.mediumButton.update();
		this.hardButton.update();
		this.quitButton.update();
	}

	void draw()
	{
		this.window.clear(this.color);
		this.easyButton.draw();
		this.mediumButton.draw();
		this.hardButton.draw();
		this.quitButton.draw();
		this.window.display();
	}

	void loadImages()
	{
		this.buttonTex = new Texture();

		assert(this.buttonTex.loadFromFile("sprites/button_static.png"), "Failed to load button image");
	}

	void loadFonts()
	{
		this.font = new Font();
		assert(this.font.loadFromFile("fonts/Kata.ttf"), "Failed to load font");
	}

	void setupButtons()
	{
		Vector2f buttonSize = this.buttonTex.getSize();
		float x = this.size.x / 2;
		float y = this.size.y / 3 - 20;

		this.easyButton = new Button(this.window, Vector2f(x, y), buttonSize, this.buttonTex, this.font, "Easy");
		y += 60;
		this.mediumButton = new Button(this.window, Vector2f(x, y), buttonSize, this.buttonTex, this.font, "Medium");
		y += 60;
		this.hardButton = new Button(this.window, Vector2f(x, y), buttonSize, this.buttonTex, this.font, "Hard");
		y += 60;
		this.quitButton = new Button(this.window, Vector2f(x, y), buttonSize, this.buttonTex, this.font, "Quit");
	}
}