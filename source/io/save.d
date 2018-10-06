module io.save;

import base;

struct Save {
    auto save(string fileName, in bool moveAllCursors, in UserMode userMode) {
        import core.stdc.stdio;
        import std.path: buildPath;
        import std.string;

        //fileName = buildPath("saves", fileName ~ ".bin");
        FILE* f;
        if ((f = fopen(fileName.toStringz, "wb")) == null) {
            jx.addToHistory("save: '", fileName, "' can't be opened");

            return false;
        }
        scope(exit)
            fclose(f);
        ubyte ver = 2;
        fwrite(&ver, 1, ubyte.sizeof, f); // 1 version

        int dx = g_board._dim.X, dy = g_board._dim.Y;
        fwrite(&dx, 1, int.sizeof, f); // 1b)
        fwrite(&dy, 1, int.sizeof, f); // 1c)
        with(g_board)
            foreach(y; 0 .. _dim.Y)
                foreach(x; 0 .. _dim.X) with(_tiles[y][x]) {
                    /+
    TileType _tileType; /// 1.
    Sprite _block;
    Color _colour; /// 2.
    Layer _layer; /// 3.
    string _text; /// 4. for verse refs or verses, idk
+/
                    fwrite(&_tileType, 1, TileType.sizeof, f); // 1) TileType _tileType;
                    fwrite(&_colour, 1, Color.sizeof, f); // 2)
                    fwrite(&_layer, 1, Layer.sizeof, f); // 3)

                    auto characters = cast(int)_text.length;
                    fwrite(&characters, 1, int.sizeof, f); // 4)
                    auto text = _text.dup;
                    fwrite(text.ptr, characters, ubyte.sizeof, f); // 5)
                }

        fwrite(&moveAllCursors, 1, moveAllCursors.sizeof, f);
        fwrite(&userMode, 1, userMode.sizeof, f);
        fwrite(&g_pushType, 1, g_pushType.sizeof, f);
        //g_pushers
        //fwrite(&, 1, .sizeof, f);
        auto count = cast(int)g_pushers.length;
        fwrite(&count, 1, count.sizeof, f);
        int x, y;
        foreach(pusher; g_pushers) {
            x = pusher._pos.X;
            y = pusher._pos.Y;
            fwrite(&x, 1, int.sizeof, f);
            fwrite(&y, 1, int.sizeof, f);
            fwrite(&pusher._mainCursor, 1, bool.sizeof, f);
        }

        return true;
    }
}
