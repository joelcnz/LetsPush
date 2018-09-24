//#magic number
module historyman;

import base;

struct HistoryMan {
    Text[] _txts;
    bool _all;

    void add(dstring line) {
        _txts ~= new Text;
        with(_txts[$ - 1]) {
            setFont(g_font);
            setString = line;
        }
    }

    void draw(bool all = false) {
        if (_txts.length == 0)
            return;
        if (_all) {
            float y = 0;
            int start = cast(int)_txts.length - 10;
            if (start < 0)
                start = 0;
            foreach(txt; _txts[start .. $]) {
                //#magic number
                txt.position = Vector2f(0, y * 25);
                g_window.draw(txt);
                y += 1;
            }
        } else {
            Text tmp = new Text;
            with(tmp) {
                setFont(g_font);
                position = Vector2f(0,0);
                setString = _txts[$ - 1].getString;
            }
            g_window.draw(tmp);
        }
    }
}
