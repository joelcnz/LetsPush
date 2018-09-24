module io.setup;

import base;

/// Main setup struct
static struct Setup {
private:
    string _settingsFileName;
    string _current;
public:
    void setSettingsFileName(in string fileName) {
        _settingsFileName = fileName;
    }

    bool fileNameExists() {
        import std.file : exists;

        if (! exists(_settingsFileName))
            return false;
        else
            return true;
    }

    void saveSettings() {
        import std.stdio : File;
        import std.string : format;

        auto file = File(_settingsFileName, "w");
        file.writeln("[settings]");
        file.writeln(format("fileName=%s", _settingsFileName));
    }

    void loadSettings() {
        if (fileNameExists) {
            auto ini = Ini.Parse(_settingsFileName);

            _current = ini["settings"].getKey("fileName");
        }
    }

    int setup() {
        import jec;

        g_checkPoints = true;
        if (jec.setup != 0) {
            import std.stdio : writefln;

            writefln("Error function: %s, Line: %s", __FUNCTION__, __LINE__);
            return -1;
        }

        g_inputJex = new InputJex(/* position */ Vector2f(0, g_window.getSize.y - 32),
                            /* font size */ 12,
                            /* header */ "Enter `h` for help: ",
                            /* Type (oneLine, or history) */ InputType.history);
    
        g_inputJex.addToHistory(""d);


        g_mode = Mode.edit;
    	g_terminal = true;

        return 0;
    }

    void shutdown() {

    }
}