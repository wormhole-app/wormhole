# flutter_close_app

Plugin to programmatically close app

## Getting Started

This plugin invokes android platform method `finishAndRemoveTask()` which closes the app and removes it from last app stack.

This has some advantages to the existing methods:

- `exit(0)` crashes the dart vm and acts as the app has crashed
- `SystemNavigator.pop()` closes the app but keeps the app in recent apps history\
eg. share intents are retransfered when the app is then reopened from recent apps.


--> so calling `finishAndRemoveTask()` is the preferred Android way to handle the intended close of the app. 


