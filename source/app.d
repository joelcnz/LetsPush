//#rename
//#work here
/+
Welcome to Lets Push!

Road map:

New idea have a toggle with pushing and not pushing

Help:
Except for recording the screen or so, don't switch programs while this one is running.

       Command + Q - to quit program
   Use cursor keys - to move the pusher around
       Command + S - to save a snapshot
                 X - Add (or takeaway if one underneath) a pusher
                 Z - Toggle control of one or all pushers
			     A - Toggle all terminal or just last line
				 P - Rotate switch between: noPush, weakPush and strongPush

+/

module main;

import std.math;

import base;

int main(string[] args) {
	scope(exit)
		"\n#\n#\n#\n#\n###\n".writeln;
    g_window = new RenderWindow(VideoMode(SCREEN_W, SCREEN_H),
							  "Welcome to Lets-Push! Press [System] + [Q] to quit"d);

	g_font = new Font;
	g_font.loadFromFile("DejaVuSans.ttf");
	if (! g_font) {
		import std.stdio;
		writeln("Font not load");
		return -1;
	}

	if (g_setup.setup != 0) {
		gh("Setup error, aborting...");
		g_window.close;

		return -1;
	}

	scope(exit)
		g_setup.shutdown;

	g_historyMan.add("Welcome to Lets-Push");

	JSound saveSound;
	import std.path;
	saveSound = new JSound(buildPath("Audio", "snapshot.wav"));

	g_window.setFramerateLimit(60);

	g_board.setup;

	bool moveAllCursors;

	auto userMode = UserMode.mainMode;
	bool justSwitchedT;

	ConvergeMan convergeMan;
	convergeMan.load;
	//bool converge = true;
	bool converge;

	import std.datetime.stopwatch: StopWatch;
	StopWatch timer;
	timer.start;

	string[] files = cat(/* display: */ false);

    while(g_window.isOpen())
    {
        Event event;

        while(g_window.pollEvent(event))
        {
            if(event.type == event.EventType.Closed)
            {
                g_window.close();
            }
        }

		if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
			Keyboard.isKeyPressed(Keyboard.Key.Q)) {
			g_window.close;
		}

		bool jXProcess(in dstring input) {
			void displayHelp() {
				jx.addToHistory("t - return to main editing");
				jx.addToHistory("clearCursors");
				jx.addToHistory("converge - free tiles");
				jx.addToHistory("cat - list project files");
				jx.addToHistory("save <file name>");
				jx.addToHistory("load (@onlyPushers) <file name>");
				jx.addToHistory("delete <file name>");
			}
			if (! input.length) {
				displayHelp;
				return false;
			}

			import std.ascii: isDigit;
			import std.string: split, join;
			import std.algorithm: startsWith, acountUntil = countUntil;
			import std.path: setExtension;

			string news = input.to!string;
			string command = news.split[0];
			//#work here
			auto args = news.split[1 .. $];

			auto pos = news.acountUntil(" ");
			if (pos == -1)
				pos = 0;
			string forQuotes = news[pos .. $] ~ " ";
			forQuotes.gh;
			args.length = 0;
			int i, qsp, wsp;
			bool inQuotes, inWord;
			while(i < forQuotes.length) {
				// save 0 @onlyPushers
				// to ["0", "@onlyPushers"]
				/+
				+/
				//quotes:
				if (! inWord && forQuotes[i] == '"') {
					if (! inQuotes) {
						inQuotes = true;
						qsp = i + 1;
					} else if (inQuotes) {
						args ~= forQuotes[qsp .. i];
						inQuotes = false;
					}
				}
				//word:
				if (! inQuotes) {
					if (inWord) {
						if (forQuotes[i] == ' ') {
							args ~= forQuotes[wsp .. i];
							inWord = false;
						}
					}
					if (! inWord && forQuotes[i] != ' ' && forQuotes[i] != '"') {
						wsp = i;
						inWord = true;
					}
				}
				i += 1;
			}

			string[] types;
			string values;
			foreach(arg; args)
				if (arg.startsWith("@"))
					types ~= arg;
				else
					values ~= arg ~ " ";
			if (values.length)
				values = values[0 .. $ - 1]; // remove the space at the end
			string fileName = buildPath("saves", values.setExtension(".bin"));

			string someException() {
				import std.conv: text;

				return text(command, " ", values, " - some exception");
			}

			try {
				import std.string: strip;

				writeln(values);
				if (values.length) {
					auto svalue = values.strip;
					writeln(svalue);
					if (svalue[0].isDigit)
						mixin(jecho("fileName = files[svalue.to!int];"));
				}
			} catch(Exception e) {
				writeln(someException);
			}

			switch(command) {
				default:
				case "help":
					displayHelp;
					jx.addToHistory("Help displayed..");
				break;
				case "cat":
					files = cat(/* display: */ true);
				break;
				case "save":
					Save s;
					if (s.save(fileName, moveAllCursors, userMode))
						jx.addToHistory("Saved: ", fileName);
				break;
				case "load":
					Load l;
					if (l.load(fileName, moveAllCursors, userMode, types))
						jx.addToHistory("Loaded: ", fileName, " ", types);
				break;
				//#rename
				case "rename":

				break;
				case "delete":
					bool yes;
					if (! fileName.exists)
						jx.addToHistory(fileName, " not exist!");
					else {
						jx.addToHistory("Delete ", fileName, " are you sure Y/N?");
						g_window.clear;
						jx.draw;
						g_window.display;
						bool doneYN;
						do {
							while(g_window.pollEvent(event))
							{ }
							if (g_keys[Keyboard.Key.N].keyInput || g_keys[Keyboard.Key.Escape].keyInput)
								yes = false,
								doneYN = true;
							if (g_keys[Keyboard.Key.Y].keyInput)
								yes = true,
								doneYN = true;
						} while(! doneYN);
					}
					if (! yes) {
						jx.addToHistory("File deletion canceled");
						break;
					}
					try {
						remove(fileName);
					} catch(Exception e) {
						jx.addToHistory(fileName, " - some exception");
						break;
					}
					jx.addToHistory(fileName, " - deleted");
				break;
				case "clearCursors":
					g_pushers = [g_pushers[0]];
					jx.addToHistory("Cursors cleared..");
				break;
				case "t":
					userMode = UserMode.mainMode;
					g_historyMan.add("Terminal off..");
				break;
				case "converge":
					converge = ! converge;
					if (converge) {
						convergeMan.load;
						jx.addToHistory("converge on");
					} else
						jx.addToHistory("converge off");
				break;
			}

			return true;
		}

		final switch(userMode) with(UserMode) {
			case mainMode:
				if (g_keys[Keyboard.Key.T].keyInput) {
					userMode = UserMode.terminalMode;
					g_historyMan.add("Terminal on..");
					justSwitchedT = true;
				}

				if ((Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem)) &&
					g_keys[Keyboard.Key.S].keyInput) {

					auto renderTexture = new RenderTexture;

					renderTexture.create(SCREEN_W, SCREEN_H);

					renderTexture.clear;

					g_board.draw(renderTexture);

					foreach(pusher; g_pushers)
						pusher.draw(renderTexture);

					renderTexture.display;

					auto capturedTexture2 = renderTexture.getTexture;
					auto toSave = capturedTexture2.copyToImage;

					int id;
					string fileName;
					do {
						fileName = buildPath("SnapShots", format("snap%02d.png", id));
						id += 1;
					} while(fileName.exists);
					if (!toSave.saveToFile(fileName)) {
						"SnapShot not saved!".gh;
					} else {
						saveSound.playSnd;
					}
				}

				if (g_keys[Keyboard.Key.P].keyInput) {
					with(PushType) {
						if (g_pushType == noPush) {
							g_pushType = strongPush;
							g_historyMan.add("Strong push..");
						} else {
							if (g_pushType == weakPush) {
								g_pushType = noPush;
								convergeMan.load;
								g_historyMan.add("No push..");
							} else {
								g_pushType = weakPush;
								g_historyMan.add("Weak push..");
							}
						}
					}
				}

				if (g_keys[Keyboard.Key.Z].keyInput) {
					moveAllCursors = ! moveAllCursors;
					g_historyMan.add(moveAllCursors ? "Move all pushers" : "Move just main pusher");
				}
				if (g_keys[Keyboard.Key.A].keyInput) {
					g_historyMan._all = ! g_historyMan._all;
				}

				if (! moveAllCursors && g_keys[Keyboard.Key.X].keyInput) {
					bool wipe;
					foreach(i, pusher; g_pushers[1 .. $])
						if (g_pushers[0]._pos.X == pusher._pos.X &&
							g_pushers[0]._pos.Y == pusher._pos.Y) {
							import std.algorithm;

							g_pushers = g_pushers.remove(i + 1); // make allowances for [1 ..] in the for each statement
							wipe = true;
							g_historyMan.add("pusher removed");
							break;
						}
					if (! wipe) {
						g_pushers ~= new Pusher(g_pushers[0]._pos);
						g_historyMan.add("#" ~ (cast(int)g_pushers.length - 1).to!dstring ~ " pusher added");
					}
				}

				if (! moveAllCursors) {
					g_pushers[0].getKeyInfo;
					g_pushers[0].process;
					g_keyInfo._key = Keyboard.Key.KeyCount;
				} else {
					g_pushers[0].getKeyInfo;
					foreach(ref pusher; g_pushers)
						pusher.process;
					g_keyInfo._key = Keyboard.Key.KeyCount;
				}
			break;
			case terminalMode:
				jx.process; //#input
				if (g_inputJex.enterPressed) {
					jx.enterPressed = false;
					jXProcess(jx.textStr);
					jx.textStr = "";
				}
			break;
		} // switch

		if (converge == true && g_pushType == PushType.noPush && userMode != UserMode.terminalMode)
			if (timer.peek.total!"msecs" > 70) {
				convergeMan.process;
				timer.reset;
			}

		g_window.clear;

		if (userMode == UserMode.mainMode) {
			g_board.draw;

			foreach(pusher; g_pushers)
				pusher.draw;
		}

		if (userMode == UserMode.mainMode)
			g_historyMan.draw;
		else
			jx.draw;

    	g_window.display;
    }
	
	return 0;
}

auto cat(bool display) {
	import std.algorithm: find, until, sort;
	import std.conv: text;
	import std.file: dirEntries, DirEntry, SpanMode;
	import std.path: dirSeparator;
	import std.range: enumerate;
	import std.array: array, replicate;

	if (display)
		jx.addToHistory("File list from 'saves':");
	int i;
	string[] files;
	foreach(DirEntry file; dirEntries("saves", "*.{bin}", SpanMode.shallow).array.sort!"a.name < b.name") {
		files ~= file.name.idup;
		if (display) {
			auto name = file.name.find(dirSeparator)[1 .. $].until(".").array;
			jx.addToHistory(text(i++, ") ", name, " ".replicate(14 - name.length), file.size, " bytes"));
		}
	}

	return files;
}
