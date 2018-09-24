import base;

struct Tile {
    TileType _tileType; /// 1.
    Sprite _block;
    Color _colour; /// 2.
    Layer _layer; /// 3.
    string _text; /// 4. for verse refs or verses, idk

    void setup(TileType tileType, Color colour = Color.White, string text = "", Layer layer = Layer.mid) {
        _tileType = tileType;
        _layer = layer;
        _colour = colour;
        _text = text;
        final switch(_tileType) with(TileType) {
            case gap, outOfBounds: /* ignore */ break;

            case block:
                _block = g_sprites[block];
                _colour = Color.Green;
            break;
            case blue:
                _block = g_sprites[blue];
                _colour = Color.Blue;
            break;
            case red:
                _block = g_sprites[red];
                _colour = Color.Red;
            break;
        }
    }

    auto type() {
        return _tileType;
    }

    void draw(RenderTexture renderTexture, Pointi p) {
        bool draw = true;
        switch(_tileType) with(TileType) {
            default: draw = false; break;
            case block, blue, red :
                _block.position = Vector2f(p.X, p.Y);
            break;
        }
        if (draw) {
            if (renderTexture is null)
                g_window.draw(_block);
            else
                renderTexture.draw(_block);
        }
    }
}
