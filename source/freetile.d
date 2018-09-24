module freetile;

import base;

struct FreeTile {
    Pointi _pos;
    Tile _tile;

    this(Pointi pos, Tile tile) {
        _pos = pos;
        _tile = tile;
    }

    void process() {
        auto newPos = _pos;

        int cx = _pos.X, cy = _pos.Y;
        /*
        int px = g_pushers[0]._pos.X - g_board._dim.X / 2, py = g_pushers[0]._pos.Y - g_board._dim.Y / 2;
        if (px < 0)
            px = g_board._dim.X + px;
        if (py < 0)
            py = g_board._dim.Y + py;
        */
        int px = g_pushers[0]._pos.X, py = g_pushers[0]._pos.Y;
        //if (abs(cx - px))
        int mx, my;
        void checkMove() {
            with(g_board) {
                newPos = Pointi(_pos.X + mx, _pos.Y + my);
                newPos = warpCheckSet(newPos);
                if (getType(newPos) == TileType.gap) {
                    setTile(_pos, g_tiles[TileType.gap]);
                    setTile(newPos, _tile);
                    _pos = newPos;
                }
            }
        }
        if (px != cx) {
            if (px < cx)
                mx = -1;
            else
                mx = 1;
        }
        checkMove;
        mx = 0;
        if (py != cy) {
            if (py < cy)
                my = -1;
            else
                my = 1;
        }
        checkMove;
    }
}