module base;

public:
import dsfml.window;
import dsfml.graphics;
import dsfml.audio;

import jec, dini.dini, jmisc;

import std.stdio, std.conv, std.range, std.string, std.path, std.file;

import io;

import board, pusher, tile, historyman, convergeman, freetile;

Setup g_setup;

alias jx = g_inputJex;

immutable BLOCK_W = 16,
    BLOCK_H = 16;
immutable SCREEN_BLOCKS_W = 40,
    SCREEN_BLOCKS_H = 30;
immutable SCREEN_W = SCREEN_BLOCKS_W * BLOCK_W,
    SCREEN_H = SCREEN_BLOCKS_H * BLOCK_H;

enum PushType {noPush, weakPush, strongPush}
PushType g_pushType;

enum TileType {gap, block, outOfBounds, blue, red}
Sprite[TileType] g_sprites;

enum Layer {back, mid, front}

enum UserMode {mainMode, terminalMode}

Tile g_tileOutOfBounds;
//Tile[TileType] g_tiles;
Tile[] g_tiles;

Board g_board;
Pusher[] g_pushers;

struct KeyInfo {
    Keyboard.Key _key;
}
KeyInfo g_keyInfo;

HistoryMan g_historyMan;

static this() {
    g_pushType = PushType.noPush;
    g_pushers = [new Pusher(Pointi(20, 1), /* main */ true)];

    auto texture = new Texture;
    if (! texture.loadFromFile("Res/infc.png")) {
        "Couldn't load image".gh;
        return;
    }

    TileType[] types;
    with(TileType)
         types = [blue, red, block];
    int i = 0;
    foreach(x; iota(0, 3 * 16, 16)) {
        g_sprites[types[i]] = new Sprite(texture);
        with(g_sprites[types[i]])
            textureRect = IntRect(x, 96, 16, 16);
        i += 1;
    }

    g_tileOutOfBounds.setup(TileType.outOfBounds);
//    with(TileType)
//        g_tiles = [gap : tile]; //, block, outOfBounds];
    g_tiles.length = 5; //TileType.length;
    with(TileType) {
        g_tiles[gap].setup(gap);
        g_tiles[block].setup(block);
        g_tiles[outOfBounds].setup(outOfBounds);
        g_tiles[blue].setup(blue);
        g_tiles[red].setup(red);
    }

}
