package sys;

import gostd.Lang.Duet;
import Exception.ExceptionTools;

class FileSystem {
    public static function exists(f) {
        var stati:Duet<gostd.Os.FileInfo,Exception> = gostd.Os.Stat(f);
        if (ExceptionTools.Is(stati.err, gostd.Os.ErrNotExist)) {
            return false;
        } else {
            return true;
        }
    }
    public static function stat(f) {
        var stati:Duet<gostd.Os.FileInfo,Exception> = gostd.Os.Stat(f);
        if (stati.err!=null){
            throw stati.err;
        } else {
            return {
                mtime:Date.fromGodate(stati.db.ModTime())
            };
        }
    }

    public static function readDirectory(f) {
        var files = gostd.Os.ReadDir(f);
        return files.db;
    }
}