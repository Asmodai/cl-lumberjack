;;; -*- Mode: LISP; Syntax: ANSI-Common-Lisp; Package: CL-LUMBERJACK; Base: 10; Lowercase: Yes -*-
;;;
;;; logger-class.lisp --- Logger CLOS object
;;;
;;; Time-stamp: <Sunday Feb  5, 2012 05:37:05 asmodai>
;;; Revision:   5
;;;
;;; Copyright (c) 2011 Paul Ward <asmodai@gmail.com>
;;;
;;; Author:     Paul Ward <asmodai@gmail.com>
;;; Maintainer: Paul Ward <asmodai@gmail.com>
;;; Created:    14 Dec 2011 23:41:52
;;; Keywords:   
;;; URL:        not distributed yet
;;;
;;;{{{ License:
;;;
;;; This code is free software; you can redistribute it and/or modify
;;; it under the terms of the version 2.1 of the GNU Lesser General
;;; Public License as published by the Free Software Foundation, as
;;; clarified by the Franz preamble to the LGPL found in
;;; http://opensource.franz.com/preamble.html.
;;;
;;; This code is distributed in the hope that it will be useful, but
;;; without any warranty; without even the implied warranty of
;;; merchantability or fitness for a particular purpose.  See the GNU
;;; Lesser General Public License for more details.
;;;
;;; Version 2.1 of the GNU Lesser General Public License can be found
;;; at http://opensource.franz.com/license.html. If it is not present,
;;; you can access it from http://www.gnu.org/copyleft/lesser.txt
;;; (until superseded by a newer  version) or write to the Free
;;; Software Foundation, Inc., 59 Temple Place, Suite  330, Boston, MA
;;; 02111-1307  USA
;;;
;;;}}}
;;;{{{ Commentary:
;;;
;;;}}}

#-genera
(in-package #:cl-lumberjack)

(defparameter *all-known-loggers* nil
  "A list of all known logger classes.")

;;;==================================================================
;;;{{{ Logger class:

(defclass logger ()
  ((filespec
    :initarg :filespec
    :initform nil
    :reader logger-filespec)   
   (name
    :initarg :name
    :initform "unknown"
    :accessor logger-name)
   (locked
    :initform nil)))

;;;}}}
;;;==================================================================

;;;==================================================================
;;;{{{ Logger methods:

(defmethod print-object ((object logger) stream)
  (print-unreadable-object (object stream :type t :identity t)
    (format stream "~A [~A]"
            (logger-name object)
            (logger-filespec object))))

;;;
;;; TODO: Make locking better et al.
(defgeneric format-log (log fmt &rest args)
  (:method ((log logger) fmt &rest args)
    (when (null (slot-value log 'locked))
      (let ((fspec (logger-filespec log)))
        (setf (slot-value log 'locked) t)
        (ignore-errors
          (when fspec
            (ensure-directories-exist fspec)
            (with-open-file (stream fspec
                                    :direction :output
                                    :if-exists :append
                                    :if-does-not-exist :create)
              (when stream
                (format stream "~A: ~?~%" (now) fmt args)
                (force-output stream)
                (close stream)))))
        (setf (slot-value log 'locked) nil)))))

;;;}}}
;;;==================================================================

;;;==================================================================
;;;{{{ Logger functions:

(defmacro define-logger (symb name filespec)
  `(progn
     (defvar ,symb (make-instance 'logger
                      :name ,name
                      :filespec ,filespec))
     (pushnew ',symb *all-known-loggers*)
     ,symb))

;;;}}}
;;;==================================================================

;;; logger-class.lisp ends here
