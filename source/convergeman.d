module convergeman;

import base;

struct ConvergeMan {
    FreeTile[] _freeTile;

    void load() {
        _freeTile.length = 0;
        with(g_board)
            foreach(y; 0 .. _dim.Y)
                foreach(x; 0 .. _dim.X) {
                    if (getType(Pointi(x,y)) != TileType.gap) {
                        _freeTile ~= FreeTile(Pointi(x,y), _tiles[y][x]);
                    }
                }
    }

    void process() {
        foreach(ref ft; _freeTile) {
            ft.process;
        }
    }
}