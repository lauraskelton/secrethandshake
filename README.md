Secret Handshake       [![Build Status](https://travis-ci.org/lauraskelton/secrethandshake.svg?branch=master)](https://travis-ci.org/lauraskelton/secrethandshake)
===========
Hacker Schooler Detector for iOS

Each user’s phone emits an iBeacon signal that includes their userID. Each phone also scans for other signals, and if it finds that of another Hacker Schooler’s phone, it sends an alert to the scanner’s phone and downloads a profile photo, name, and batch of the nearby person.

That way, you could make sure to stop by and chat with that person at a conference or meetup.

Credits
===========
SecretHandshake was created by Laura Skelton.

Features
===========
* iBeacon Proximity Detection
* Shares userIDs over Bluetooth LE
* Sends an alert to your phone if a Hacker Schooler is detected, even if your phone is inactive.

Beta Testing
===========
So far it seems to be working well, but I definitely need beta testing help from some other Hacker School folks who wouldn’t mind giving some feedback. I have it up on TestFlight if you have an iPhone and time to test it out! http://tflig.ht/1stcVLG

OAuth Process
===========
Get an Authorization Code
------
First call to server to get a `code`, which represents that user's login credentials with the API. This is a GET request. Send the user to this url to log in and authorize your app to use their account:
`https://www.hackerschool.com/oauth/authorize?response_type=code&client_id=(my_client_id)&redirect_uri=(my_redirect_uri)`

Tricks to keep in mind: the `redirect_uri` should be the same redirect that your app registered with the API when you got your `client_id` and `client_secret`. This is the URL that will need to process the returned `code` to request an `access_token` from the API in just a minute. The things in parentheses should be replaced with your `client_id` and your `redirect_uri`.

If the user logs in and authorizes your app, the API will send a GET request to your redirect uri with a `code` parameter with the Authorization Code for that user. You'll use the `code` in the next step to request an `access_token` for that user.

GET request the API returns:
`(your-redirect-uri)?code=(some-authorization-code-for-this-user)`

Request an Access Token
------
Second call to server to get `access_token`, which you will use to sign each API request you make. Signing a request with a valid `access_token` lets you access whatever the logged-in user has permission to access. This must be a POST request. Make a POST request to this URL in the background (no need to redirect the user to this page this time). Again, the things in parentheses should be replaced with your own `client_id`, `client_secret`, `redirect_uri`, and the `code` the API just sent you for the user.

* URL: `https://www.hackerschool.com/oauth/token`

* POST Request Parameters: `grant_type=authorization_code&client_id=(my_client_id)&client_secret=(my_client_secret)&redirect_uri=(my_redirect_uri)&code=(the authorization code you just got from the GET request the API returned)`

This will return a JSON response that contains, among other things, the parameters `access_token` and `refresh_token`. There are other parameters, but these two are the most important for signing your API calls.

```json
{"access_token": "some-access-token",
"token_type": "bearer",
"expires_in": 7200,
"refresh_token": "some-refresh-token",
"scope": "public"}
```

Save the `access_token` and `refresh_token` values somewhere persistent that you will be able to reuse for that user when your app launches in the future. In iOS, `NSUserDefaults` is a good place to store them.

Using the Access Token
------
Every time you make a call to the API for that user, just sign the request with the `access_token`. You can even use a GET request to sign the call. For example: `https://www.hackerschool.com/api/v1/people/me?access_token=(your stored access token for this user)` will return a JSON string containing this user's profile info.

It's probably better instead of passing the `access_token` in a GET request, to send it in the Authorization header.

```
Authorization: Bearer (my-access-token-here)
```

In Objective-C, this would look sort of like:

```objc
NSURL *profileURL = [NSURL URLWithString:@"https://www.hackerschool.com/api/v1/people/me"];
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:profileURL];
[request setValue:[NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] objectForKey:kSHAccessTokenKey]] forHTTPHeaderField:@"Authorization"];
[NSURLConnection sendAsynchronousRequest:request
                                    queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                // handle request completion here
                           }]
```


Refreshing the Access Token
------
Eventually (after 2 hours I believe), your `access_token` will expire. Suddenly, instead of returning the JSON you were expecting, it will return JSON containing a `message` with the value `unauthorized`.

```json
{"message": "unauthorized"}
```

When this happens, it's time to try refreshing your `access_token`. Just like getting the original `access_token`, this needs to be a POST request to the `oauth/token` URL, but with slightly different POST request parameters, since we are now using the `refresh_token` to get the `access_token`, instead of using the `code` to get the `access_token`.

* URL: `https://www.hackerschool.com/oauth/token`

* POST Request Parameters: `grant_type=refresh_token&client_id=(my_client_id)&client_secret=(my_client_secret)&refresh_token=(the refresh token for this user that you saved earlier)`

If this returns any kind of error (the API will return a JSON `error` if something's not properly authorized), I just have the user log in again.

Because the login in my app redirects to the Safari browser, the user might already be logged in there, in which case they will be quickly redirected back to my app with the new `access_token` and `refresh_token` I need to sign their requests.