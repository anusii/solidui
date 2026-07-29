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

This will initialise your project to all platforms. After the initialisation, you need to pull all the updates from the imported packages. To do that run the following command.

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
my_pod_app/solid/client-profile.jsonld
my_pod_app/solid/redirect.html
```

You must publish both files so that they are publicly reachable (HTTP 200, public, no auth). 
Easiest way to get a free hosting space is to use `Github Pages`. For a quick tutorial
see: https://www.youtube.com/watch?v=e5AwNU3Y2es

Here're the few quick steps to get a github hosting space setup.

1. Go to your github profile page and click the `Repositories` tab.
2. Press `New` button to create a new repository.
3. Give a unique name for your repository. Choose the visibility as `Public`. Other options are optional. Press `Create repository` button.
4. In your new repository click `Add file` button and select `Create new file`
5. Add the name of the file as `index.html` and copy the following content into the file. This is a very simple HTML landing page for your hosting space.

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Page</title>
        <style>
        body { font-family: sans-serif; text-align: center; margin-top: 100px; }
        </style>
    </head>
<body>
    <h1>Hello, World!</h1>
    <p>This is a simple index.html page.</p>
</body>
</html>
``` 

6. Click `Commit changes` to save the file.
7. Now go to the `Settings` tab of your repository and click `Pages` option.
8. On the page under `Build and deployment` section select the source as `GitHub Actions`.
9. This will give you a list of options to select as your preferred GitHub Workflow.
10. Select the one called `Static HTML` by pressing the `Configure` button.
11. This will take you to the actual Workflow code. You do not need to change anything in here. Simply click `Commit changes` to save the file and initiate the workflow.
12. Now GitHub will start the workflow process to build and deploy your repository as a public hosting space. You can see this Action in progress by going to the `Actions` tab in your repository. This will take a few seconds.
13. Once finished again go to `Settings` -> `Pages`. You will now see a message that says your site is live at a custom URL. You can go to that URL to display the content of the HTML file you created before.
14. You can now use this space to publish your `client-profile.jsonld` and `redirect.html` files.
15. Please make sure to change the corresponding domain names in the `client-profile.jsonld` file and also inside the app by editing the `lib/constants/app.dart`. The specific parameters you want to change are `appClientId` and `appRedirectUris` list.

Once you done all the above, now you are ready to login to your newly created app using your POD. restart the app and click the `Login` button and follow the login process.

Congratulations! You have successfully setup the login and logged into the app using your POD.
