//#test
module io.load;

import base;

struct Load {
    bool load(string fileName, out bool moveAllCursors, out UserMode userMode, in string[] types) {
        import core.stdc.stdio;
        import std.path: buildPath;
        import std.string;
        import std.algorithm.searching: canFind;

        bool onlyPushers = types.canFind("@onlyPushers");

        FILE* f;
        if ((f = fopen(fileName.toStringz, "rb")) == null) {
            jx.addToHistory("load: '", fileName, "' can't be opened");

            return false;
        }
        scope(exit)
            fclose(f);
        ubyte ver;
        fread(&ver, 1, ubyte.sizeof, f); // 1 version

        switch(ver) {
            default: jx.addToHistory("Unknown version - ", ver); break;
            case 1:
                int dx, dy;
                fread(&dx, 1, int.sizeof, f); // 1b)
                fread(&dy, 1, int.sizeof, f); // 1c)
                g_board.setSize(dx, dy);

                Tile tile;
                with(g_board)
                    foreach(y; 0 .. _dim.Y)
                        foreach(x; 0 .. _dim.X) with(tile) {
                            /+
            TileType _tileType; /// 1.
            Sprite _block;
            Color _colour; /// 2.
            Layer _layer; /// 3.
            string _text; /// 4. for verse refs or verses, idk
        +/
                            fread(&_tileType, 1, TileType.sizeof, f); // 1) TileType _tileType;
                            fread(&_colour, 1, Color.sizeof, f); // 2)
                            fread(&_layer, 1, Layer.sizeof, f); // 3)

                            int characters;
                            fread(&characters, 1, int.sizeof, f); // 4)
                            char[] text;
                            text.length = cast(ulong)characters;
                            fread(text.ptr, characters, char.sizeof, f); // 5)

                            with(tile) {
                                _tiles[y][x].setup(_tileType, _colour, _text, _layer);
                            }
                        }
            break;
            case 2:
                int dx, dy;
                fread(&dx, 1, int.sizeof, f); // 1b)
                fread(&dy, 1, int.sizeof, f); // 1c)
                g_board.setSize(dx, dy);

                Tile tile;
                with(g_board)
                    foreach(y; 0 .. _dim.Y)
                        foreach(x; 0 .. _dim.X) with(tile) {
                            /+
            TileType _tileType; /// 1.
            Sprite _block;
            Color _colour; /// 2.
            Layer _layer; /// 3.
            string _text; /// 4. for verse refs or verses, idk
        +/
                            fread(&_tileType, 1, TileType.sizeof, f); // 1) TileType _tileType;
                            fread(&_colour, 1, Color.sizeof, f); // 2)
                            fread(&_layer, 1, Layer.sizeof, f); // 3)

                            int characters;
                            fread(&characters, 1, int.sizeof, f); // 4)
                            char[] text;
                            text.length = cast(ulong)characters;
                            fread(text.ptr, characters, char.sizeof, f); // 5)

                            if (! onlyPushers)
                                with(tile) {
                                    _tiles[y][x].setup(_tileType, _colour, _text, _layer);
                                }
                        }
                fread(&moveAllCursors, 1, moveAllCursors.sizeof, f);
                fread(&userMode, 1, userMode.sizeof, f);
                fread(&g_pushType, 1, g_pushType.sizeof, f);
                //g_pushers
                //fwrite(&, 1, .sizeof, f);
                g_pushers.length = 0;
                int pushersCount;
                fread(&pushersCount, 1, pushersCount.sizeof, f);
                auto tmp = new Pusher(Pointi(0,0), /* main */  true);
                int x, y;
                foreach(_; 0 .. pushersCount) {
                    fread(&x, 1, int.sizeof, f);
                    fread(&y, 1, int.sizeof, f);
                    fread(&tmp._mainCursor, 1, bool.sizeof, f);
                    g_pushers ~= new Pusher(Pointi(x, y), tmp._mainCursor);
                }

            break;
        } // switch

        return true;
    }
}
