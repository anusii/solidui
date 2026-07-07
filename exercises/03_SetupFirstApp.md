# Setup Your First App

With `solidui` we made it easy to get your first app up and running. `solidui` ships with an app template, a ready-to-run Pod file browser, complete with a navigation rail and a status bar.

First run the following command to activate the generator.

```bash
flutter pub global activate solidui
```

Then go to the directory you want to create the example app in and run the following command. Replace `my_pod_app` with the app name you want.

```bash
solidui create my_pod_app
```

If you are a Windows user, you also need to add the `solidui` to your environment variables before running the above command. To do that open `Powershell` and run the following commands.

```shell
$pubCacheBin = "$env:LOCALAPPDATA\Pub\Cache\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($userPath -notlike "*$pubCacheBin*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$pubCacheBin", "User")
}
```

Now go inside the newly created flutter app directory and run the following command.

```bash
cd my_pod_app/
flutter create .
```

This will initialise your porject to all platforms. After the initialisation, you need to pull all the updates from the imported packages. To do that run the following command.

```bash
flutter pub get
```

Now you are ready to compile and run the app. First run `flutter devices` to list down all the devices/platforms you have access to and compile your app into. Then run the following command to compile your app.

```bash
flutter run -d <device_name>
```

For instance, if you want to run your app on Windows, use `flutter run -d windows` command.

The app will start compiling...

Congratulations! You have successfully compiled and ran your first Flutter Solid based application.

# Setup Login

Before login into your app using your POD, you must publish a Client Identifier Document for the app. 
The above `solidui create` command will write a ready-to-deploy copy of this document, together with the web redirect helper, into the generated project's solid/ folder. You can find those two files in

```bash
my_pod_app/solid/lient-profile.jsonld
my_pod_app/solid/redirect.html
```

You must publish both files so that they are publicly reachable (HTTP 200, public, no auth). 
Easiest way to get a free hosting space is to use `Github Pages`. For a quick tutorial
see: https://www.youtube.com/watch?v=e5AwNU3Y2es