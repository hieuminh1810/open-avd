import os, plistlib, shutil, sys, uuid

VERSION = sys.argv[1] if len(sys.argv) > 1 else "0.0.0"  # e.g. python3 make_app.py 1.2.0

APP = os.path.expanduser("~/Applications/Open AVD.app")
STUB = "/System/Library/CoreServices/Automator Application Stub.app/Contents/MacOS/Automator Application Stub"
SCRIPT = open(os.path.join(os.path.dirname(__file__), "avd.applescript")).read()

ICON = f"{APP}/Contents/Resources/AppIcon.icns"
icon_bytes = open(ICON, "rb").read() if os.path.exists(ICON) else None
shutil.rmtree(APP, ignore_errors=True)
os.makedirs(f"{APP}/Contents/MacOS")
os.makedirs(f"{APP}/Contents/Resources")
shutil.copy(STUB, f"{APP}/Contents/MacOS/Automator Application Stub")
HERE = os.path.dirname(__file__)
if icon_bytes:
    open(ICON, "wb").write(icon_bytes)
else:
    shutil.copy(f"{HERE}/icon/AppIcon.icns", ICON)
for s in ("list-avds.sh", "fix-network.sh", "update.sh"):
    shutil.copy(f"{HERE}/{s}", f"{APP}/Contents/Resources/{s}")
    os.chmod(f"{APP}/Contents/Resources/{s}", 0o755)

info = {
    "CFBundleExecutable": "Automator Application Stub",
    "CFBundleIdentifier": "com.hieule.open-avd",
    "CFBundleName": "Open AVD",
    "CFBundleIconFile": "AppIcon",
    "CFBundlePackageType": "APPL",
    "CFBundleShortVersionString": VERSION,
    "CFBundleVersion": VERSION,
    "LSMinimumSystemVersion": "10.9",
    "LSUIElement": False,
    "NSAppleEventsUsageDescription": "Open AVD runs an AppleScript.",
}
with open(f"{APP}/Contents/Info.plist", "wb") as f:
    plistlib.dump(info, f)

U = lambda: str(uuid.uuid4()).upper()
action = {
    "AMAccepts": {"Container": "List", "Optional": True, "Types": ["com.apple.applescript.object"]},
    "AMActionVersion": "1.0.2",
    "AMApplication": ["Automator"],
    "AMParameterProperties": {"source": {}},
    "AMProvides": {"Container": "List", "Types": ["com.apple.applescript.object"]},
    "ActionBundlePath": "/System/Library/Automator/Run AppleScript.action",
    "ActionName": "Run AppleScript",
    "ActionParameters": {"source": (
        "on run {input, parameters}\ntry\n" + SCRIPT +
        "\non error errMsg number errNum\n"
        "if errNum is not -128 then display alert \"Open AVD bị lỗi\" message errMsg & \" (\" & errNum & \")\"\n"
        "end try\nreturn input\nend run\n")},
    "BundleIdentifier": "com.apple.Automator.RunScript",
    "CFBundleVersion": "1.0.2",
    "CanShowSelectedItemsWhenRun": False,
    "CanShowWhenRun": True,
    "Category": ["AMCategoryUtilities"],
    "Class Name": "RunScriptAction",
    "InputUUID": U(),
    "Keywords": ["Run"],
    "OutputUUID": U(),
    "UUID": U(),
    "UnlocalizedApplications": ["Automator"],
    "arguments": {"0": {"default value": "", "name": "source", "required": "0", "type": "0", "uuid": "0"}},
    "isViewVisible": True,
    "location": "300:300",
    "nibPath": "/System/Library/Automator/Run AppleScript.action/Contents/Resources/Base.lproj/main.nib",
}
wflow = {
    "AMApplicationBuild": "523",
    "AMApplicationVersion": "2.10",
    "AMDocumentVersion": "2",
    "actions": [{"action": action, "isViewVisible": True}],
    "connectors": {},
    "workflowMetaData": {"workflowTypeIdentifier": "com.apple.Automator.application"},
}
with open(f"{APP}/Contents/document.wflow", "wb") as f:
    plistlib.dump(wflow, f)
print(APP)
