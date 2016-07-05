//
//  PsCmd.swift
//  PsCmd
//
//  Created by hnw on 2016/07/06.
//  Copyright © 2016年 hnw. All rights reserved.
//

import Foundation
import CStringArray

public class PsCmd {
    var args: CStringArray
    var saved_cout: Int32 = -1
    var saved_cerr: Int32 = -1
    var cout_pipe: [Int32] = [-1, -1]
    var cerr_pipe: [Int32] = [-1, -1]
    var ctrl_pipe: [Int32] = [-1, -1]
    var cout_fp: UnsafeMutablePointer<FILE> = nil
    var cerr_fp: UnsafeMutablePointer<FILE> = nil
    public var cout: String = ""
    public var cerr: String = ""
    public var retval: Int32 = -1

    public init(_ _args: [String]) {
        var tmp: [String?] = _args.map { Optional<String>($0) }
        tmp.append(nil);
        args = CStringArray(tmp)
    }
    /// Replacement for FD_ZERO macro
    private func fdZero(inout set: fd_set) {
        set.fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }
    /// Replacement for FD_SET macro
    private func fdSet(fd: Int32, inout _ set: fd_set) {
        let intOffset = Int(fd / 32)
        let bitOffset = fd % 32
        let mask = 1 << bitOffset
        switch intOffset {
        case 0: set.fds_bits.0 = set.fds_bits.0 | mask
        case 1: set.fds_bits.1 = set.fds_bits.1 | mask
        case 2: set.fds_bits.2 = set.fds_bits.2 | mask
        case 3: set.fds_bits.3 = set.fds_bits.3 | mask
        case 4: set.fds_bits.4 = set.fds_bits.4 | mask
        case 5: set.fds_bits.5 = set.fds_bits.5 | mask
        case 6: set.fds_bits.6 = set.fds_bits.6 | mask
        case 7: set.fds_bits.7 = set.fds_bits.7 | mask
        case 8: set.fds_bits.8 = set.fds_bits.8 | mask
        case 9: set.fds_bits.9 = set.fds_bits.9 | mask
        case 10: set.fds_bits.10 = set.fds_bits.10 | mask
        case 11: set.fds_bits.11 = set.fds_bits.11 | mask
        case 12: set.fds_bits.12 = set.fds_bits.12 | mask
        case 13: set.fds_bits.13 = set.fds_bits.13 | mask
        case 14: set.fds_bits.14 = set.fds_bits.14 | mask
        case 15: set.fds_bits.15 = set.fds_bits.15 | mask
        case 16: set.fds_bits.16 = set.fds_bits.16 | mask
        case 17: set.fds_bits.17 = set.fds_bits.17 | mask
        case 18: set.fds_bits.18 = set.fds_bits.18 | mask
        case 19: set.fds_bits.19 = set.fds_bits.19 | mask
        case 20: set.fds_bits.20 = set.fds_bits.20 | mask
        case 21: set.fds_bits.21 = set.fds_bits.21 | mask
        case 22: set.fds_bits.22 = set.fds_bits.22 | mask
        case 23: set.fds_bits.23 = set.fds_bits.23 | mask
        case 24: set.fds_bits.24 = set.fds_bits.24 | mask
        case 25: set.fds_bits.25 = set.fds_bits.25 | mask
        case 26: set.fds_bits.26 = set.fds_bits.26 | mask
        case 27: set.fds_bits.27 = set.fds_bits.27 | mask
        case 28: set.fds_bits.28 = set.fds_bits.28 | mask
        case 29: set.fds_bits.29 = set.fds_bits.29 | mask
        case 30: set.fds_bits.30 = set.fds_bits.30 | mask
        case 31: set.fds_bits.31 = set.fds_bits.31 | mask
        default: break
        }
    }
    /// Replacement for FD_CLR macro
    func fdClr(fd: Int32, inout _ set: fd_set) {
        let intOffset = Int(fd / 32)
        let bitOffset = fd % 32
        let mask = ~(1 << bitOffset)
        switch intOffset {
        case 0: set.fds_bits.0 = set.fds_bits.0 & mask
        case 1: set.fds_bits.1 = set.fds_bits.1 & mask
        case 2: set.fds_bits.2 = set.fds_bits.2 & mask
        case 3: set.fds_bits.3 = set.fds_bits.3 & mask
        case 4: set.fds_bits.4 = set.fds_bits.4 & mask
        case 5: set.fds_bits.5 = set.fds_bits.5 & mask
        case 6: set.fds_bits.6 = set.fds_bits.6 & mask
        case 7: set.fds_bits.7 = set.fds_bits.7 & mask
        case 8: set.fds_bits.8 = set.fds_bits.8 & mask
        case 9: set.fds_bits.9 = set.fds_bits.9 & mask
        case 10: set.fds_bits.10 = set.fds_bits.10 & mask
        case 11: set.fds_bits.11 = set.fds_bits.11 & mask
        case 12: set.fds_bits.12 = set.fds_bits.12 & mask
        case 13: set.fds_bits.13 = set.fds_bits.13 & mask
        case 14: set.fds_bits.14 = set.fds_bits.14 & mask
        case 15: set.fds_bits.15 = set.fds_bits.15 & mask
        case 16: set.fds_bits.16 = set.fds_bits.16 & mask
        case 17: set.fds_bits.17 = set.fds_bits.17 & mask
        case 18: set.fds_bits.18 = set.fds_bits.18 & mask
        case 19: set.fds_bits.19 = set.fds_bits.19 & mask
        case 20: set.fds_bits.20 = set.fds_bits.20 & mask
        case 21: set.fds_bits.21 = set.fds_bits.21 & mask
        case 22: set.fds_bits.22 = set.fds_bits.22 & mask
        case 23: set.fds_bits.23 = set.fds_bits.23 & mask
        case 24: set.fds_bits.24 = set.fds_bits.24 & mask
        case 25: set.fds_bits.25 = set.fds_bits.25 & mask
        case 26: set.fds_bits.26 = set.fds_bits.26 & mask
        case 27: set.fds_bits.27 = set.fds_bits.27 & mask
        case 28: set.fds_bits.28 = set.fds_bits.28 & mask
        case 29: set.fds_bits.29 = set.fds_bits.29 & mask
        case 30: set.fds_bits.30 = set.fds_bits.30 & mask
        case 31: set.fds_bits.31 = set.fds_bits.31 & mask
        default: break
        }
    }
    /// Replacement for FD_ISSET macro
    func fdIsSet(fd: Int32, inout _ set: fd_set) -> Bool {
        let intOffset = Int(fd / 32)
        let bitOffset = fd % 32
        let mask = 1 << bitOffset
        switch intOffset {
        case 0: return set.fds_bits.0 & mask != 0
        case 1: return set.fds_bits.1 & mask != 0
        case 2: return set.fds_bits.2 & mask != 0
        case 3: return set.fds_bits.3 & mask != 0
        case 4: return set.fds_bits.4 & mask != 0
        case 5: return set.fds_bits.5 & mask != 0
        case 6: return set.fds_bits.6 & mask != 0
        case 7: return set.fds_bits.7 & mask != 0
        case 8: return set.fds_bits.8 & mask != 0
        case 9: return set.fds_bits.9 & mask != 0
        case 10: return set.fds_bits.10 & mask != 0
        case 11: return set.fds_bits.11 & mask != 0
        case 12: return set.fds_bits.12 & mask != 0
        case 13: return set.fds_bits.13 & mask != 0
        case 14: return set.fds_bits.14 & mask != 0
        case 15: return set.fds_bits.15 & mask != 0
        case 16: return set.fds_bits.16 & mask != 0
        case 17: return set.fds_bits.17 & mask != 0
        case 18: return set.fds_bits.18 & mask != 0
        case 19: return set.fds_bits.19 & mask != 0
        case 20: return set.fds_bits.20 & mask != 0
        case 21: return set.fds_bits.21 & mask != 0
        case 22: return set.fds_bits.22 & mask != 0
        case 23: return set.fds_bits.23 & mask != 0
        case 24: return set.fds_bits.24 & mask != 0
        case 25: return set.fds_bits.25 & mask != 0
        case 26: return set.fds_bits.26 & mask != 0
        case 27: return set.fds_bits.27 & mask != 0
        case 28: return set.fds_bits.28 & mask != 0
        case 29: return set.fds_bits.29 & mask != 0
        case 30: return set.fds_bits.30 & mask != 0
        case 31: return set.fds_bits.31 & mask != 0
        default: return false
        }
    }
    public func exec() {
        var thread: pthread_t = nil
        pipe(&ctrl_pipe)
        var thread_arg = [
            UnsafeMutablePointer<Void>(bitPattern: Int(ctrl_pipe[1])),
            UnsafeMutablePointer<Void>(bitPattern: args.pointers.count-1),
            UnsafeMutablePointer<Void>(args.pointers)
        ]
        saveCout()
        saveCerr()
        pthread_create(&thread, nil, ps_main_routine, &thread_arg)
        saveResult()
        withUnsafePointer(&retval) {
            pthread_join(thread, UnsafeMutablePointer<UnsafeMutablePointer<Void>>($0))
        }
    }
    private func saveCout() {
        saved_cout = dup(STDOUT_FILENO)
        if (pipe(&cout_pipe) < 0) {
            return
        }
        dup2(cout_pipe[1], STDOUT_FILENO)
        cout_fp = fdopen(cout_pipe[0], "r")
    }
    private func saveCerr() {
        saved_cerr = dup(STDERR_FILENO)
        if (pipe(&cerr_pipe) < 0) {
            return
        }
        dup2(cerr_pipe[1], STDERR_FILENO)
        cerr_fp = fdopen(cerr_pipe[0], "r")
    }
    private func restoreCout() {
        if (cout_pipe[1] >= 0) {
            if (close(cout_pipe[1]) == 0) {
                cout_pipe[1] = -1
            }
        }
        if (saved_cout >= 0) {
            dup2(saved_cout, STDOUT_FILENO)
            close(saved_cout)
            saved_cout = -1
        }
    }
    private func restoreCerr() {
        if (cerr_pipe[1] >= 0) {
            if (close(cerr_pipe[1]) == 0) {
                cerr_pipe[1] = -1
            }
        }
        if (saved_cerr >= 0) {
            dup2(saved_cerr, STDERR_FILENO)
            close(saved_cerr)
            saved_cerr = -1
        }
    }
    private func closeCtrlPipe() {
        close(ctrl_pipe[0])
        close(ctrl_pipe[1])
        ctrl_pipe[0] = -1
        ctrl_pipe[1] = -1
    }
    private func closeCoutPipe() {
        if (cout_pipe[0] >= 0) {
            close(cout_pipe[0]);
            cout_pipe[0] = -1;
        }
    }
    private func closeCerrPipe() {
        if (cerr_pipe[0] >= 0) {
            close(cerr_pipe[0]);
            cerr_pipe[0] = -1;
        }
    }
    public func saveResult() {
        var set = fd_set()
        let buffer_size = 8192
        var buffer = [Int8](count: buffer_size+1, repeatedValue: 0)
        let nfd = max(ctrl_pipe[0], cout_pipe[0], cerr_pipe[0])+1
        while (true) {
            fdZero(&set)
            if (ctrl_pipe[0] >= 0) {
                fdSet(ctrl_pipe[0], &set)
            }
            if (cout_pipe[0] >= 0) {
                fdSet(cout_pipe[0], &set)
            }
            if (cerr_pipe[0] >= 0) {
                fdSet(cerr_pipe[0], &set)
            }
            let n = select(nfd, &set, nil, nil, nil)
            if (n == 0) {
                continue
            } else if (n == -1) {
                return
            }
            if (ctrl_pipe[0] >= 0 && fdIsSet(ctrl_pipe[0], &set)) {
                closeCtrlPipe()
                restoreCout()
                restoreCerr()
            }
            if (cout_pipe[0] >= 0 && fdIsSet(cout_pipe[0], &set)) {
                let p = fgets(&buffer, Int32(buffer_size), cout_fp)
                if (p == nil) {
                    closeCoutPipe()
                } else {
                    cout = cout.stringByAppendingString(String.fromCString(buffer)!)
                }
            }
            if (cerr_pipe[0] >= 0 && fdIsSet(cerr_pipe[0], &set)) {
                let p = fgets(&buffer, Int32(buffer_size), cerr_fp)
                if (p == nil) {
                    closeCerrPipe()
                } else {
                    cerr = cerr.stringByAppendingString(String.fromCString(buffer)!)
                }
            }
            if (ctrl_pipe[0] < 0 && cout_pipe[0] < 0 && cerr_pipe[0] < 0) {
                break
            }
        }
    }
}