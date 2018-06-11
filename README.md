## About

If you're a front-end developer you most likely use Google Chrome Canary on a regular basis because it comes with latest and greatest dev tools and APIs.

Canary builds are however only available for Windows and Mac. There's no early (daily) dev builds available for Linux platform.

You can use Dev or Beta versions but they don't come out as often as Canary builds and you always want to stay on top of things.

Just like me. I like to have the latest Chrome build available to test things as they come out.

At first i was using raw Chromium snapshots from Google Chromium Continuous builds (mentioned here: [https://www.chromium.org/getting-involved/download-chromium/](https://www.chromium.org/getting-involved/download-chromium/)].

Those builds are the most recent snapshots of Chromium updated even more often than Canary builds on Windows (sometimes many times per hour).

But the downside is that Chromium for Linux does not update itself like Windows versions do. So it was a pain in the butt to manually check if there are new versions available, download them and get them up and running.

So I made a script to do that for me.

What the script does, it checks for new builds available, and if it finds one, Chromium package is downloaded, extracted and prepared for use.

You can also check for new versions without downloading or generate a .desktop file to, for example, put an executable to sidebar in Ubuntu (Unity).

![Chromium Downloader](https://user-images.githubusercontent.com/34814207/34446854-f313f620-ecde-11e7-911e-b884fd66c4ee.png)

## First use
If you want to run the script for the first time, you need to look through it and change directory locations to suit your needs.

Setting up also requires to place a file called "chromium-last-commit.txt" inside "app" directory. You need to place a "0" (zero) in the file. File is used to check which build is currently used and that number is compared to the latest snapshot number available so that the script can figure out if it needs to download new version.

During every package installation script uses *sudo* command because SUID helper binary is needed to turn on the sandbox on Linux (more info: [https://chromium.googlesource.com/chromium/src/+/lkcr/docs/linux_suid_sandbox_development.md](https://chromium.googlesource.com/chromium/src/+/lkcr/docs/linux_suid_sandbox_development.md)])

Step by step installation (based on the defaults from the chromium.sh file):

```bash
sudo mkdir /opt/google-chromium
sudo chown maciek:maciek /opt/google-chromium
mkdir /opt/google-chromium/app
touch /opt/google-chromium/chromium-last-commit.txt
echo 0 > /opt/google-chromium/chromium-last-commit.txt
chmod x ./chromium.sh
./chromium.sh
```

After Chromium is downloaded and installed you can create a file which will allow you to place Chromium icon in Unity launcher in Ubuntu.

```bash
./chromium.sh --create-desktop-file
cp ./chromium.desktop ~/.local/share/applications/
```

Now search for *Chromium* in the Unity search and you should see the Chromium icon.

## Command line parameters
* **--check** [Checks for new available snapshots without downloading new build if available (dry run)]

* **--create-desktop-file** [Creates chromium.desktop file with parameters specified by the user in the script. .desktop files are located in *~/.local/share/applications* directory. File is used to place Chromium icon in Ubuntu launcher (Unity)]

## Note
There is no automatic checks for update available in those Chromium builds so you need to manually launch the script or set up a cron job to do that for you.

## Feedback
Issues/Suggestions/Improvements are [welcome](https://github.com/maciejgluszek/chromium-downloader/issues)
