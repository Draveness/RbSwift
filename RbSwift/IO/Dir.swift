//
//  Dir.swift
//  RbSwift
//
//  Created by draveness on 10/04/2017.
//  Copyright © 2017 draveness. All rights reserved.
//

import Foundation

public class Dir: CustomStringConvertible {
    private var _dir: UnsafeMutablePointer<DIR>?

    /// Returns the path parameter passed to dir’s constructor.
    public let path: String

    /// Returns the file descriptor used in dir.
    /// This method uses `dirfd()` function defined by POSIX 2008.
    public var fileno: Int {
        return dirfd(_dir).to_i
    }

    /// Returns the current position in dir. See also `Dir#seek(pos:)`.
    public var pos: Int {
        get {
            return telldir(_dir)
        }
        set {
            seek(newValue)
        }
    }

    /// Returns the current position in dir.
    public var tell: Int {
        return pos
    }

    /// Returns the path parameter passed to dir’s constructor.
    public var to_path: String {
        return path
    }

    /// Return a string describing this Dir object.
    public var inspect: String {
        return path
    }

    /// Return a string describing this Dir object.
    public var description: String {
        return path
    }

    /// Returns a new directory object for the named directory.
    public init?(_ path: String) {
        self.path = path
        guard let dir = opendir(path) else { return nil }
        self._dir = dir
    }

    /// Returns a new directory object for the named directory.
    ///
    /// - Parameter path: A directory path.
    /// - Returns: A new `Dir` object or nil.
    public static func new(_ path: String) -> Dir? {
        return Dir(path)
    }

    /// Returns a new directory object for the named directory.
    ///
    /// - Parameter path: A directory path.
    /// - Returns: A new `Dir` object or nil.
    public static func open(_ path: String) -> Dir? {
        return Dir(path)
    }

    /// Returns the path to the current working directory of this process as a string.
    public static var getwd: String {
        return FileManager.default.currentDirectoryPath
    }
    
    /// Returns the path to the current working directory of this process as a string.
    /// An alias to `Dir#getwd` var.
    public static var pwd: String {
        return getwd
    }
    
//    public static func glob(_ pattern: String) -> [String] {
//        return []
//    }

    /// Returns the home directory of the current user or the named user if given.
    ///
    ///     Dir.home       #=> "/Users/username"
    ///
    public static var home: String {
        return NSHomeDirectory()
    }
    
    /// Error throws when user doesn't exists.
    ///
    /// - notExists: User doesn't exists
    public enum HomeDirectory: Error {
        case notExists
    }
    
    /// Returns the home directory of the current user or the named user if given.
    ///
    ///     Dir.home()       #=> "/Users/username"
    ///     Dir.home("user") #=> "/user"
    ///
    /// - Parameter path: The name of user.
    /// - Returns: Home directory.
    /// - Throws: HomeDirectory.notExists if user doesn't exist.
    public static func home(_ user: String? = nil) throws -> String {
        if let home = NSHomeDirectoryForUser(user) { return home }
        throw HomeDirectory.notExists
    }
    
    /// Changes the current working directory of the process to the given string.
    ///
    ///     Dir.chdir("/var/spool/mail")
    ///     Dir.pwd     #=> "/var/spool/mail"
    ///
    /// - Parameter path: A new current working directory.
    /// - Returns: A bool indicates the result of `Dir#chdir(path:)`
    @discardableResult
    public static func chdir(_ path: String = "~") -> Bool {
        return FileManager.default.changeCurrentDirectoryPath(path)
    }

    /// Changes this process’s idea of the file system root.
    ///
    /// - Parameter path: A directory path.
    /// - Returns: A bool value indicates the result of `Darwin.chroot`
    /// - SeeAlso: `Darwin.chroot`.
    @discardableResult
    public static func chroot(_ path: String) -> Bool {
        return Darwin.chroot(path) == 0
    }
    
    /// Changes the current working directory of the process to the given string.
    /// Block is passed the name of the new current directory, and the block
    /// is executed with that as the current directory. The original working directory
    /// is restored when the block exits. The return value of chdir is the value of the block.
    ///
    ///     Dir.pwd         #=> "/work"
    ///     let value = Dir.chdir("/var") {
    ///         Dir.pwd     #=> "/var"
    ///         return 1
    ///     }
    ///     Dir.pwd         #=> "/work"
    ///     value   #=> 1
    ///
    /// - Parameters:
    ///   - path: A new current working directory.
    ///   - closure: A block executed in target directory.
    /// - Returns: The value of the closure.
    @discardableResult
  public static func chdir<T>(_ path: String = "~", closure: (() -> T)) -> T {
        let pwd = Dir.pwd
        Dir.chdir(path)
        let result = closure()
        Dir.chdir(pwd)
        return result
    }
    
    /// Makes a new directory named by string, with permissions specified by the optional parameter anInteger.
    ///
    ///     try Dir.mkdir("draveness")
    ///     try! Dir.mkdir("draveness/spool/mail", recursive: true)
    ///
    /// - Parameters:
    ///   - path: A new directory path.
    ///   - recursive: Whether creats intermeidate directories.
    ///   - permissions: An integer represents the posix permission.
    /// - Throws: When `FileManager#createDirectory(atPath:withIntermediateDirectories:attributes:)` throws.
    public static func mkdir(_ path: String, recursive: Bool = false, _ permissions: Int? = nil) throws {
        var attributes: [String: Any] = [:]
        if let permissions = permissions {
            attributes[FileAttributeKey.posixPermissions.rawValue] = permissions
        }
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: recursive, attributes: attributes)
    }
    
    /// Error throws when called `Dir#rmdir(path:)` method.
    ///
    /// - notEmpty: Directory is not empty.
    /// - notExists: Directory is not exists.
    public enum RemoveDirectoryError: Error {
        case notEmpty
        case cocoa(String)
    }
    
    /// Deletes the named directory.
    ///
    ///     try Dir.rmdir("/a/folder/path")
    ///
    /// - Parameter path: A directory path
    /// - Throws: `RemoveDirectoryError` if the directory isn’t empty.
    public static func rmdir(_ path: String) throws {
        if !Dir.isEmpty(path) {
            throw RemoveDirectoryError.notEmpty
        }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            throw RemoveDirectoryError.cocoa(error.localizedDescription)
        }
    }

    /// Deletes the named directory. An alias to `Dir.rmdir(path:)`.
    ///
    ///     try Dir.unlink("/a/folder/path")
    ///
    /// - Parameter path: A directory path
    /// - Throws: `RemoveDirectoryError` if the directory isn’t empty.
    public static func unlink(_ path: String) throws {
        try rmdir(path)
    }

    /// Returns true if the named file is a directory, false otherwise.
    ///
    ///     Dir.isExist("/a/folder/path/not/exists")     #=> false
    ///     Dir.isExist("/a/folder/path/exists")         #=> true
    ///
    /// - Parameter path: A file path.
    /// - Returns: A bool value indicates whether there is a directory in given path.
    public static func isExist(_ path: String) -> Bool {
        var isDirectory = false as ObjCBool
        let exist = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exist && isDirectory.boolValue
    }
    
    /// Returns true if the named file is an empty directory, false if it is
    /// not a directory or non-empty.
    ///
    ///     Dir.isEmpty("/a/empty/folder")           #=> true
    ///     Dir.isEmpty("/a/folder/not/exists")      #=> true
    ///     Dir.isEmpty("/a/folder/with/files")      #=> false
    ///
    /// - Parameter path: A directory path.
    /// - Returns: A bool value indicates the directory is not exists or is empty.
    public static func isEmpty(_ path: String) -> Bool {
        if let result = try? FileManager.default.contentsOfDirectory(atPath: path) {
            return result.isEmpty
        }
        return true
    }
    
    ///  Returns an array containing all of the filenames in the given directory. Will return an empty array
    ///  if the named directory doesn’t exist.
    ///
    /// - Parameter path: A directory path.
    /// - Returns: An array of all filenames in the given directory.
    public static func entries(_ path: String) -> [String] {
        do {
            let filenames = try FileManager.default.contentsOfDirectory(atPath: path)
            return [".", ".."] + filenames
        } catch {
            return []
        }
    }

    /// Calls the block once for each entry in the named directory, passing the filename of each
    /// entry as a parameter to the block.
    ///
    /// - Parameters:
    ///   - path: A directory path.
    ///   - closure: A closure accepts all the entries in current directory.
    public static func foreach(_ path: String, closure: (String) -> ()) {
        entries(path).each(closure)
    }

    /// Deletes the named directory.
    ///
    /// - Parameter path: A directory path.
    /// - Returns: A bool value indicates the result of `Dir.delete(path:)`
    @discardableResult
    public static func delete(_ path: String) -> Bool {
        return Darwin.rmdir(path) == 0
    }

    /// Seeks to a particular location in dir.
    ///
    /// - Parameter pos: A particular location.
    public func seek(_ pos: Int) {
        seekdir(_dir, pos)
    }

    /// Repositions dir to the first entry.
    public func rewind() {
        rewinddir(_dir)
    }
}
