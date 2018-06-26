import dsfml.system;
import dsfml.graphics;
import dsfml.window;

import button;

class SubMenu
{
	RenderWindow window;
	Vector2i size;

	Button yesButton;
	Button noButton;

	Text text;

	Texture buttonTex;
	Font font;

	bool done;
	bool running = true;

	this(string text)
	{
		this.size = Vector2i(210, 210);
		this.window = new RenderWindow(VideoMode(size.x, size.y), "Mines");
		this.loadImages();
		this.loadFonts();
		this.yesButton = new Button(this.window, Vector2f(this.size.x / 3, (this.size.y / 4) * 3), Vector2f(50, 50), this.buttonTex, this.font, "Yes");
		this.noButton = new Button(this.window, Vector2f((this.size.x / 3) * 2, (this.size.y / 4) * 3), Vector2f(50, 50), this.buttonTex, this.font, "No");
		this.setUpText(this.font, text);
		
	}

	void run()
	{
		while (this.running)
		{
			this.draw();
			this.update();
		}
		this.window.close();
	}

	bool getDone()
	{
		return this.done;
	}

private:
	void draw()
	{
		this.window.clear(Color(200, 200, 200));
		this.yesButton.draw();
		this.noButton.draw();
		this.window.draw(this.text);
		this.window.display();
	}

	void update()
	{
		this.getEvents();
	}

	void getEvents()
	{
		Event event;
		while (this.window.pollEvent(event))
		{
			switch (event.type)
			{
				case Event.EventType.Closed:
					this.window.close();
					this.done = true;
					this.running = false;
					break;
				case Event.EventType.MouseButtonPressed:
					if (this.yesButton.isPressed())
					{
						this.done = false;
						this.running = false;
					}
					else if (this.noButton.isPressed())
					{
						this.done = true;
						this.running = false;
					}
					break;
				default:
					break;

			}
		}
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

	void setUpText(Font font, string text)
	{
		this.text = new Text();
		this.text.setColor = Color(0, 0, 0);
		this.text.setFont(font);
		this.text.setCharacterSize(30);
		this.text.setString(text);

		FloatRect textSize = this.text.getLocalBounds();
		this.text.origin = Vector2f(textSize.width / 2, textSize.height / 2);
		this.text.position = Vector2f(this.size.x / 2, 60);
	}
}