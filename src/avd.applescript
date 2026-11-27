set homeDir to POSIX path of (path to home folder)
set emu to homeDir & "Library/Android/sdk/emulator/emulator"
set sdkOK to do shell script "[ -x " & quoted form of emu & " ] && echo 1 || echo 0"
if sdkOK is "0" then
	display alert "Không tìm thấy Android SDK" message "Cần cài Android Studio (SDK ở ~/Library/Android/sdk) và tạo ít nhất 1 AVD."
	return
end if
set resDir to do shell script "{ echo \"$HOME/Applications/Open AVD.app\"; echo '/Applications/Open AVD.app'; mdfind 'kMDItemCFBundleIdentifier == \"com.hieule.open-avd\"'; } | while IFS= read -r a; do if [ -f \"$a/Contents/Resources/list-avds.sh\" ]; then echo \"$a/Contents/Resources/\"; break; fi; done; true"
if resDir is "" then
	display alert "Không tìm thấy Open AVD.app" message "Hãy chuyển app vào thư mục Applications rồi mở lại."
	return
end if
set helper to resDir & "list-avds.sh"
set fixer to resDir & "fix-network.sh"
set fixLabel to "🔄  Sửa mạng emulator (sau khi đổi wifi)"
set lastFile to homeDir & ".android/open-avd-last"

set rows to paragraphs of (do shell script "/bin/bash " & quoted form of helper)
if rows is {} then
	display alert "Không tìm thấy AVD nào"
	return
end if
set lastName to do shell script "cat " & quoted form of lastFile & " 2>/dev/null || true"

set names to {}
set labels to {}
set states to {}
set defaultLabel to missing value
set AppleScript's text item delimiters to "|"
repeat with r in rows
	set end of names to text item 1 of r
	set end of labels to text item 2 of r
	set end of states to text item 3 of r
	if (text item 1 of r) is lastName then set defaultLabel to text item 2 of r
end repeat
set AppleScript's text item delimiters to ""
if defaultLabel is missing value then set defaultLabel to item 1 of labels

set picked to choose from list ({fixLabel} & labels) with title "Open AVD" with prompt "Chọn emulator để mở:" default items {defaultLabel} OK button name "Mở" cancel button name "Huỷ"
if picked is false then return

if (item 1 of picked) is fixLabel then
	set fixedCount to do shell script "/bin/bash " & quoted form of fixer
	if fixedCount is "0" then
		display notification "Không có emulator nào đang chạy" with title "Open AVD"
	else
		display notification "Đã kết nối lại mạng cho " & fixedCount & " emulator" with title "Open AVD"
	end if
	return
end if

repeat with i from 1 to count labels
	if item i of labels is (item 1 of picked) then
		set avdName to item i of names
		set isRunning to item i of states
	end if
end repeat

do shell script "echo " & quoted form of avdName & " > " & quoted form of lastFile
if isRunning is "1" then
	display notification avdName & " đang chạy rồi" with title "Open AVD"
	return
end if
do shell script "nohup " & quoted form of emu & " -avd " & quoted form of avdName & " -dns-server 8.8.8.8,1.1.1.1 > /dev/null 2>&1 &"
display notification "Đang mở " & avdName & "…" with title "Open AVD"
