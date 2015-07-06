;;; aoj-submit.el --- A client for AOJ

;;; Installation:
;;   (require 'aoj-submit)
;;   (setq aoj-id "Your ID")
;;   (setq aoj-password "Your Password")

;;; Use:
;; Make sure that the filename is "problemNO(LessonID).cpp".
;; M-x aoj-submit

;;; Code:

(require 'url)


(defcustom aoj-id nil "Your ID")
(defcustom aoj-password nil "Your Passwd")


(defvar aoj-supported-languages-alist
  '(("java" . "JAVA")
    ("cpp" . "C++")
    ("cc" . "C++")
    ("c" . "C")
    (nil . "C")))


(defun aoj-submit ()
  (interactive)
  (let ((url-request-method        "POST")
        (url-request-extra-headers `(("Content-Type" . "application/x-www-form-urlencoded")))
        (url-request-data          (aoj--payload))
        (url                       "http://judge.u-aizu.ac.jp/onlinejudge/webservice/submit"))
    (switch-to-buffer (url-retrieve-synchronously url)
      (buffer-string))
    (aoj-open)))

(defun aoj-open ()
  (interactive)
  (browse-url "http://judge.u-aizu.ac.jp/onlinejudge/status.jsp"))

(defun aoj--language ()
  (assoc-default
   (file-name-extension
    (file-name-nondirectory (buffer-file-name)))
   aoj-supported-languages-alist))


(defun aoj--problemNO ()
  (file-name-sans-extension
   (file-name-nondirectory (buffer-file-name))))


(defun aoj--lesson-p (problemNO)
  (if (not
       (string-match "\\`[0-9]+\\'" problemNO))
      t
    nil))


(defun aoj--lesson-problemNO (problemNO)
  (subseq problemNO
          (- (length problemNO) 1)
          (length problemNO)))


(defun aoj--lesson-lessonID (problemNO)
  (subseq problemNO
          0
          (- (length problemNO) 2)))


(defun aoj--payload ()
  (let ((problemNO (aoj--problemNO)))
    (if (aoj--lesson-p problemNO)
        (aoj--lesson-payload problemNO)
      (aoj--problem-payload problemNO))))


(defun aoj--problem-payload (problemNO)
  (concat "userID="     aoj-id "&"
          "password="   aoj-password "&"
          "problemNO="  problemNO "&"
          "language="   (url-hexify-string (aoj--language)) "&"
          "sourceCode=" (url-hexify-string (buffer-string))))


(defun aoj--lesson-payload (problemNO)
  (concat "userID="     aoj-id "&"
          "password="   aoj-password "&"
          "problemNO="  (aoj--lesson-problemNO problemNO) "&"
          "lessonID="   (aoj--lesson-lessonID problemNO) "&"
          "language="   (url-hexify-string (aoj--language)) "&"
          "sourceCode=" (url-hexify-string (buffer-string))))


(provide 'aoj-submit)
