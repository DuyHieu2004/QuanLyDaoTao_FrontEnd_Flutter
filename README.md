### Connect to physical device by ADB Reverse

1. Connect your physical device to your computer via USB.  
2. Open a terminal and run the following command to set up ADB reverse:
3. Make sure your .NET backend is running (listening on http://localhost:5025).
4. Open the Terminal in Android Studio (at the bottom).
5. Type this command and press Enter:

```bash
adb reverse tcp:5025 tcp:5025
```
6. Now run your Flutter app.

_Special thanks to [@NguyenHuuThinh](https://github.com/NguyenHuuThinh2410) for the assistance with the refactor._
From: 
``` bash
NguyenHuuThinh2410 <nguyenhuuthinh2410@gmail.com>
```
