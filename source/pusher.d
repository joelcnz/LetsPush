import base;

struct MoveData {
    Keyboard.Key key;
    int x, y;
}

class Pusher {
    int _id;
    bool _mainCursor;
    RectangleShape _block;
    Pointi _pos;
    Keyboard.Key _up, _right, _down, _left;
    MoveData[] _moveData;

    this(Pointi pos, bool mainCur = false) {
        if (mainCur)
            _mainCursor = true;
        _pos = pos;
        _block = new RectangleShape;
        changeCursorGfx(PushType.noPush);

        _up = Keyboard.Key.Up;
        _right = Keyboard.Key.Right;
        _down = Keyboard.Key.Down;
        _left = Keyboard.Key.Left;

        alias md = MoveData;
        _moveData = [md(_up, 0,-1), md(_right, 1,0), md(_down, 0,1), md(_left, -1,0)];
        _moveData ~= _moveData[0];
        _moveData = _moveData[0] ~ _moveData;
    }

    void changeCursorGfx(PushType pushType) {
        final switch(pushType) with(PushType) {
            case noPush:
                with(_block) {
                    size = Vector2f(BLOCK_W, BLOCK_H);
                    fillColor = Color(255,255,255, 255);
                    outlineColor = fillColor;
                    outlineThickness = 0;
                }
            break;
            case strongPush, weakPush:
                with(_block) {
                    size = Vector2f(BLOCK_W, BLOCK_H);
                    fillColor = Color(255,255,255, 0);
                    outlineColor = Color(255,255,255, 255);
                    outlineThickness = 2;
                }
            break;
        }

        if (_mainCursor) {
            _block.outlineColor = Color.Red;
            _block.fillColor = Color(0,0,0,0);
            _block.outlineThickness = 2;
        }
    }

    auto getKeyInfo() {
        foreach(md; _moveData[1 .. 4 + 1])
            if (g_keys[md.key].keyInput) {
                g_keyInfo._key = md.key;
            }
    }

    void process() {
        userControl;
    }

    void userControl() {
        if (Keyboard.isKeyPressed(Keyboard.Key.LSystem) || Keyboard.isKeyPressed(Keyboard.Key.RSystem))
            return;
        foreach(md; _moveData[1 .. 4 + 1])
            if (g_keyInfo._key == md.key) {
                final switch(g_pushType) with(PushType) {
                    case noPush:
                        move(md);
                    break;
                    case strongPush:
                        doStrongPush(md);
                    break;
                    case weakPush:
                        doWeakPush(md);
                    break;
                }
            }
    }

    void doWeakPush(MoveData md) {
        with(g_board) {
            auto mdpoint = Pointi(md.x, md.y);
            auto inFrontPos = _pos + mdpoint;
            inFrontPos = warpCheckSet(inFrontPos);
            auto tile = getTile(inFrontPos);

            if (tile.type != TileType.gap) {
                auto tileOtherPos = inFrontPos + mdpoint;
                tileOtherPos = warpCheckSet(tileOtherPos);
                auto tileOtherType = getTile(tileOtherPos).type;
                
                if (tileOtherType == TileType.gap) {
                    move(md);
                    setTile(_pos, g_tiles[TileType.gap]);
                    setTile(tileOtherPos, tile);
                }
            } else {
                move(md);
            }
        }
    }

    void move(MoveData md) {
        _pos += Pointi(md.x, md.y);
        _pos = g_board.warpCheckSet(_pos);
    }

    void doStrongPush(MoveData md) {
        auto findEnd(Pointi pos) {
            auto startPos = pos;
            bool done = false;
            TileType type;

            while(! done) {
                type = g_board.getType(pos);
                if (TileType.gap != type) {
                    pos += Pointi(md.x, md.y);
                    pos = g_board.warpCheckSet(pos);
                } else
                    done = true;
                if (pos == startPos) {
                    done = true;
                }
            }

            return pos;
        }

        void moveFromEnd(Pointi pos) {
            with(g_board) {
                //gh;
                auto startPos = _pos;
                typeof(_pos) newPos;
                bool done = false;
                auto moveDir = Pointi(md.x, md.y);
                Tile tile;

                do {
                    pos = warpCheckSet(pos);
                    pos -= moveDir;
                    pos = warpCheckSet(pos);
                    tile = getTile(pos);
                    newPos = warpCheckSet(pos + moveDir);
                    setTile(newPos, tile);
                    
                    if (pos == startPos) {
                        setTile(pos, g_tiles[TileType.gap]);
                        done = true;
                    }
                } while(! done);
            }
        }

        with(g_board) {
            auto inFrontPos = _pos + Pointi(md.x, md.y);
            inFrontPos = warpCheckSet(inFrontPos);
            if (getType(inFrontPos) != TileType.gap) {
                move(md);
                moveFromEnd(findEnd(_pos));
            } else
                _pos = inFrontPos;
        }
    }

    void draw(RenderTexture renderTexture = null) {
        _block.position = Vector2f(_pos.X * BLOCK_W, _pos.Y * BLOCK_H);
        if (renderTexture !is null)
            renderTexture.draw(_block);
        else
            g_window.draw(_block);
    }
}
