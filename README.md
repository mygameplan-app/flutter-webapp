# jdarwish_dashboard_web

Web App Walk-through:

Install firebase cli:
    https://firebase.google.com/docs/cli
Use CORS for photos:
    https://firebase.google.com/docs/storage/web/download-files
Firebase Hosting info:
    https://firebase.google.com/docs/hosting
    -add additional sites on firebase hosting:
    https://firebase.google.com/docs/hosting/multisites

Deploying a new app:


What to change for every new app:
	General:
        -appId (in Constants.dart)
        -Material App title
	Assets:
	    -assets/logo.png
        -assets/icon.png
	Web:
        -favicon.png
        -icons-512.png
        -icons-192.png
    Index.html:
        -apple-mobile-web-app-title
        -description
        -title
    Manifest.json:
        -name
        -short_name
        -descriptions
    Firebase.json:
        -copy and paste the json as previously done, and change the target name to hosting name

Deploy to web:
    -Install firebase cli and connect to mygameplan

Use commands:
    flutter build web
    firebase deploy --only hosting:target_name (target_name is target in firebase.json)


