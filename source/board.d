import base;

struct Board {
    Pointi _dim;
    Tile[][] _tiles;
    RectangleShape _border;

    void setSize(int w, int h) {
        _dim = Pointi(w, h);
        _tiles.length = _dim.Y;
        foreach(y; 0 .. _dim.Y)
            _tiles[y].length = _dim.X;
    }

    void setup() {
        //_dim = Pointi(1280 / 8, 800 / 8);
        setSize(SCREEN_BLOCKS_W, SCREEN_BLOCKS_H);

        _border = new RectangleShape;
        with(_border) {
            position = Vector2f(1, 1);
            size = Vector2f(_tiles[0].length * BLOCK_W - 1, _tiles.length * BLOCK_H - 1);
            fillColor = Color(0, 0, 0, 0);
            outlineColor = Color(255, 255, 255);
            outlineThickness = 1;
        }

        // clear screen
        foreach(y; 0 .. _dim.Y)
            foreach(x; 0 .. _dim.X)
                _tiles[y][x].setup(TileType.gap);
        // Two horizontal lines
        foreach(x; 2 .. _dim.X - 3)
            _tiles[2][x].setup(TileType.block),
            _tiles[_dim.Y - 3][x].setup(TileType.block);
        // Two inner horizontal lines
        foreach(x; 10 .. _dim.X - 10)
            _tiles[10][x].setup(TileType.block),
            _tiles[_dim.Y - 10][x].setup(TileType.block);
        // Two vertical lines
        foreach(y; 2 .. _dim.Y - 3)
            _tiles[y][2].setup(TileType.block),
            _tiles[y][_dim.X - 3].setup(TileType.block);
        // Two inner vertical lines
        foreach(y; 10 .. _dim.Y - 10)
            _tiles[y][10].setup(TileType.block),
            _tiles[y][_dim.X - 10].setup(TileType.block);
        _tiles[_dim.Y - 3][_dim.X - 3].setup(TileType.block);
        _tiles[_dim.Y - 10][_dim.X - 10].setup(TileType.block);

        // Pieyells
        foreach(y; 15 .. 20)
            foreach(x; 15 .. 20)
                _tiles[y][x].setup(TileType.blue),
                _tiles[y][x+6].setup(TileType.red);
    }

    bool outOfBounds(Pointi pos) {
        if (pos.X < 0 || pos.X > _dim.X - 1 || pos.Y < 0 || pos.Y > _dim.Y - 1)
            return true;
        return false;
    }

    Tile getTile(Pointi pos) {
        if (outOfBounds(pos))
            return g_tileOutOfBounds;
        
        return _tiles[pos.Y][pos.X];
    }

    auto getType(Pointi pos) {
        if (outOfBounds(pos))
            return g_tileOutOfBounds.type;
        
        return _tiles[pos.Y][pos.X].type;
    }

    bool setTile(Pointi pos, Tile tile) {
        if (outOfBounds(pos))
            return false;
        
        _tiles[pos.Y][pos.X] = tile;
        
        return true;
    }

    auto warpCheckSet(Pointi pos) {
        if (TileType.outOfBounds == getType(pos)) {
            int mx = pos.X,
                my = pos.Y;
            if (mx == -1) pos = Pointi(SCREEN_BLOCKS_W - 1, pos.Y);
            if (mx == SCREEN_BLOCKS_W) pos = Pointi(0, pos.Y);
            if (my == -1) pos = Pointi(pos.X, SCREEN_BLOCKS_H - 1);
            if (my == SCREEN_BLOCKS_H) pos = Pointi(pos.X, 0);
        }

        return pos;
    }

    void draw(RenderTexture renderTexture = null) {
        foreach(y; 0 .. _dim.Y)
            foreach(x; 0 .. _dim.X)
                _tiles[y][x].draw(renderTexture, Pointi(x * BLOCK_W, y * BLOCK_H));
        if (renderTexture !is null)
            renderTexture.draw(_border);
        else
            g_window.draw(_border);
    }
}
