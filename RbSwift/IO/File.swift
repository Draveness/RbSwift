//
//  File.swift
//  RbSwift
//
//  Created by Draveness on 10/04/2017.
//  Copyright © 2017 draveness. All rights reserved.
//

import Foundation

public class File: IO {
    /// Returns the pathname used to create file as a string. Does not normalize the name.
    public let path: String

    /// Returns the pathname used to create file as a string. Does not normalize the name.
    /// An alias to `File#path`.
    public var to_path: String {
        return path
    }

    public init(_ path: String, _ mode: String = "r") {
        self.path = path
        super.init(file: fopen(path, mode))
    }
    
    /// Returns the current umask value for this process. If the optional argument is given, 
    /// set the umask to that value and return the previous value. Umask values are subtracted 
    /// from the default permissions, so a umask of 0222 would make a file read-only for everyone.
    class var umask: Int {
        get {
            let omask = Darwin.umask(0)
            _ = Darwin.umask(omask)
            return Int(omask)
        }
        set {
            _ = Darwin.umask(mode_t(newValue))
        }
    }
    
    /// Opens the file named by filename according to the given mode and returns a new
    /// `File` object.
    ///
    /// - Parameters:
    ///   - path: A file path.
    ///   - mode: A string represents the mode to open the file.
    ///   - closure: If given, file would be closed automatically after closure executed.
    /// - Returns: A file object.
    @discardableResult
    public class func new(_ path: String, _ mode: String = "r", closure: ((File) -> ())? = nil) -> File {
        let file = File(path, mode)
        if let closure = closure {
            defer { file.close() }
            closure(file)
        }
        return file
    }
    
    /// Opens the file named by filename according to the given mode and returns a new
    /// `File` object.
    ///
    /// - Parameters:
    ///   - path: A file path.
    ///   - mode: A string represents the mode to open the file.
    ///   - closure: If given, file would be closed automatically after closure executed.
    /// - Returns: A file object.
    /// - SeeAlso: An alias to `File#new`
    @discardableResult
    public class func open(_ path: String, _ mode: String = "r", closure: ((File) -> ())? = nil) -> File {
        return new(path, mode, closure: closure)
    }
    
    /// Returns the last component of the filename given in `filename`.
    ///
    /// 	File.basename("/home/work/file.swift")		#=> "file.swift"
    ///
    /// If `suffix` is given and present at the end of `filename`, it is removed.
    ///
    /// 	File.basename("/home/work/file.swift", ".swift")    #=> "file"
    ///
    /// If `suffix` is `.*`, any extension will be removed.
    ///
    /// 	File.basename("/home/work/file.swift", ".*")        #=> "file"
    /// 	File.basename("/home/work/file.rb", ".*")           #=> "file"
    ///
    /// - Parameters:
    ///   - filename: A file path string.
    ///   - suffix: A string will be removed from the filename.
    /// - Returns: The last component with or without extension.
    public class func basename(_ filename: String, _ suffix: String = "") -> String {
        let base = filename.bridge.lastPathComponent
        if suffix == ".*" { return base.bridge.deletingPathExtension }
        let pattern = suffix + "$"
        guard base =~ pattern else { return base }
        return base.gsub(pattern, "")
    }
    
    /// Returns all components of the filename given in `filename` except the last one.
    ///
    /// 	File.dirname("/home/work/file.swift")		#=> "/home/work"
    ///
    /// - Parameter filename: A file path string.
    /// - Returns: The directory of given filename.
    public class func dirname(_ filename: String) -> String {
        return filename.bridge.deletingLastPathComponent
    }
    
    /// Returns the extension (the portion of file name in path starting from the last period).
    /// If path is a dotfile, or starts with a period, then the starting dot is not dealt 
    /// with the start of the extension.
    ///
    ///
    /// An empty string will also be returned when the period is the last character in path.
    ///
    /// - Parameter path: A file path.
    /// - Returns: A file extension of empty string.
    public class func extname(_ path: String) -> String {
        let ext = path.bridge.pathExtension
        guard ext.isEmpty else { return "." + ext }
        return ext
    }
    
    /// Converts a pathname to an absolute pathname. Relative paths are referenced from the current
    /// working directory of the process unless `dir` is given, in which case it will be used as the starting
    /// point. The given pathname may start with a "~", which expands to the process owner’s home directory 
    /// (the environment variable HOME must be set correctly).
    ///
    /// 	File.expand(path: "~/file.swift")                   #=> "/absolute/path/to/home/file.swift"
    /// 	File.expand(path: "file.swift", in: "/usr/bin")		#=> "/usr/bin/file.swift"
    ///
    /// - Parameters:
    ///   - path: A file path.
    ///   - dir: A directory path.
    /// - Returns: A absolute path.
    public class func expand(_ path: String, in dir: String? = nil) -> String {
        var filepath = Pathname(path)
        if let dir = dir {
            filepath = Pathname(dir) + filepath
            return filepath.path.bridge.standardizingPath
        }
        return File.absolutePath(filepath.path)
    }
    
    /// Converts a pathname to an absolute pathname.
    ///
    ///
    /// 	File.absolutePath("~/file.swift")		#=> Dir.home + "/file.swift"
    /// 	File.absolutePath("./file.swift")		#=> Dir.pwd + "/file.swift"
    ///
    /// - Parameter path: A files path.
    /// - Returns: A absolute path of given file path.
    public class func absolutePath(_ path: String) -> String {
        let pathname = Pathname(path)
        if pathname.isAbsolute {
            return path.bridge.standardizingPath
        }

        let expandingPath = Pathname(path.bridge.expandingTildeInPath)
        if expandingPath.isAbsolute {
            return expandingPath.path.bridge.standardizingPath
        }

        let path = URL(fileURLWithPath: pathname.path).absoluteString.from(7)!
        
        // remove trailing `/` if path is directory.
        if path.hasSuffix("/") && path.length.isPositive {
            return path.substring(to: path.length-1)
        } else {
            return path
        }
    }
    
    /// Splits the given string into a directory and a file component and returns a tuple with `(File.dirname, File.basename)`.
    ///
    ///     File.split("/home/gumby/.profile")   #=> ("/home/gumby", ".profile")
    ///
    /// - Parameter path: A file path.
    /// - Returns: A tuple with a directory and a file component.
    public class func split(_ path: String) -> (String, String) {
        return (File.dirname(path), File.basename(path))
    }
    
    /// Returns a new string formed by joining the strings using "/".
    ///
    /// 	File.join("usr", "bin", "swift")		#=> "usr/bin/swift"
    ///
    /// - Parameter paths: An array of file path.
    /// - Returns: A new file path.
    public class func join(_ paths: String...) -> String {
        var pathnames = paths.compactMap(Pathname.init)
        if pathnames.count == 1 {
            return pathnames.first!.path
        } else if pathnames.count >= 2 {
            var result = pathnames.shift()! + pathnames.shift()!
            while pathnames.count > 0 {
                result = result + pathnames.shift()!
            }
            return result.path
        }
        return ""
    }
    
    /// Returns true if stat is a regular file (not a device file, pipe, socket, etc.).
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isFile(_ path: String) -> Bool {
        return Stat(path).isFile
    }
    
    /// Returns true if the named file is a directory, and false otherwise.
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isDirectory(_ path: String) -> Bool {
        return Dir.isExist(path)
    }
    
    /// Returns true if the named file is executable.
    /// 
    ///     File.isExecutable("file.sh")
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isExecutable(_ path: String) -> Bool {
        return FileManager.default.isExecutableFile(atPath: path)
    }
    
    /// Returns true if the named file is readable.
    ///
    ///     File.isReadable("file.swift")
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isReadable(_ path: String) -> Bool {
        return FileManager.default.isReadableFile(atPath: path)
    }
    
    /// Returns true if the named file is writable.
    ///
    ///     File.isWritable("file.rb")
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isWritable(_ path: String) -> Bool {
        return FileManager.default.isWritableFile(atPath: path)
    }
    
    /// Returns true if the named file is deletable.
    ///
    ///     File.isDeletable("file.py")
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isDeletable(_ path: String) -> Bool {
        return FileManager.default.isDeletableFile(atPath: path)
    }
    
    /// Returns true if the named file exists, and false otherwise.
    ///
    ///     File.isExist("file.exs")
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isExist(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    /// Changes permission bits on the named file(s) to the bit pattern represented by `mode`.
    ///
    ///     File.chmod(0o777, "file.swift")
    ///
    /// - Parameters:
    ///   - mode: A permission bits.
    ///   - paths: An array of file path.
    /// - Returns: The number of files processed.
    @discardableResult
    public class func chmod(_ mode: Int, _ paths: String...) -> Int {
        return paths.reduce(0) {
            return $0 + Darwin.chmod($1, mode_t(mode)).to_i
        }
    }
    
    /// Returns the file size of the named file.
    ///
    ///     File.size("somefile")       #=> 1234
    ///     File.size("emptyfile")      #=> 0
    ///
    /// - Parameter path: A file path.
    /// - Returns: The size of file.
    public class func size(_ path: String) -> Int {
        return Stat(path).size
    }
    
    /// Returns the last access time for the named file as a `Date` object.
    ///
    /// - Parameter path: A file path.
    /// - Returns: The atime of file.
    public class func atime(_ path: String) -> Date {
        return Stat(path).atime
    }
    
    /// Returns the birth time for the named file.
    ///
    /// - Parameter path: A file path.
    /// - Returns: The birthtime of file.
    public class func birthtime(_ path: String) -> Date {
        return Stat(path).birthtime
    }
    
    /// Returns true if the named file is a block device.
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isBlockDev(_ path: String) -> Bool {
        return Stat(path).isBlockDev
    }
    
    /// Returns true if the named file is a character device.
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isCharDev(_ path: String) -> Bool {
        return Stat(path).isCharDev
    }
    
//    public class func chown
    
    /// Deletes the named files, returning the number of names passed as arguments.
    ///
    /// - Parameter paths: An array of file path.
    /// - Returns: The number of names passed as arguments.
    /// - Throws: `FileManager#removeItem(atPath:)`
    @discardableResult
    public class func delete(_ paths: String...) throws -> Int {
        var result = 0
        for path in paths {
            try FileManager.default.removeItem(atPath: path)
            result += 1
        }
        return result
    }
    
    /// Returns true if the named file exists and has a zero size.
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value.
    public class func isZero(_ path: String) -> Bool {
        return Stat(path).isZero
    }
    
    /// Identifies the type of the named file; the return string is one of "file", "directory", 
    /// "characterSpecial", "blockSpecial", "fifo", "link", "socket", or "unknown".
    ///
    /// - Parameter path: A file path.
    /// - Returns: A string describes the ftype.
    public class func ftype(_ path: String) -> String {
        return Stat(path).ftype
    }
}
