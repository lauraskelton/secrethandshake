Description
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

Server OAuth Handler
===========

```php

<?php
    
    /**
     * Server OAuth Handler for iOS App
     *
     * iOS App launches Safari to this page on SecretHandshake server
     * This page sends the user to the Hacker School login page to get authorization code
     * It takes the auth code and sends it back to the server to get an access token
     * It redirects the user back to the app via a custom URL scheme
     * and sends the access and refresh tokens as query parameters to the app
     * which stores them for future use.
     */
    function getAuthenticationUrl($auth_endpoint, $client_id, $redirect_uri)
    {
        $parameters = array(
                                        'response_type' => 'code',
                                        'client_id'     => $client_id,
                                        'redirect_uri'  => $redirect_uri
                                        );
        return $auth_endpoint . '?' . http_build_query($parameters, null, '&');
    }

    function getAccessToken($token_endpoint, $grant_type, array $parameters, $client_id, $client_secret)
    {
        $parameters['grant_type'] = $grant_type;
        $parameters['client_id'] = $client_id;
        $parameters['client_secret'] = $client_secret;
        
        $http_headers = array();
        
        return executeRequest($token_endpoint, $parameters, 'POST', $http_headers, 0);
    }
    
    function executeRequest($url, $parameters = array(), $http_method = 'POST', array $http_headers = null, $form_content_type = 0)
    {
        
        $postBody = http_build_query($parameters);
        $requestHttpContext["content"] = $postBody;
        $requestHttpContext["method"] = 'POST';
        
        $options = array( 'http' => $requestHttpContext );
        $context = stream_context_create( $options );
        
        $response = file_get_contents($url, false, $context);
        
        return $response;
        
    }

    $client_id = 'my-client-id';
    $client_secret = 'my-client-secret';
    $authorization_endpoint = 'my-authorization-endpoint';
    $redirect_uri = 'my-redirect-uri';
    $token_endpoint = 'my-token-endpoint';

    
    if (!isset($_GET['code']))
    {
        $auth_url = getAuthenticationUrl($authorization_endpoint, $client_id, $redirect_uri);
        header('Location: ' . $auth_url);
        die('Redirect');
    } else {
        $params = array(
                        'code' => $_GET['code'],
                        'redirect_uri' => $redirect_uri
                        );
        
        $response = getAccessToken($token_endpoint, 'authorization_code', $params, $client_id, $client_secret);
        
        $info = json_decode($response, true);
        $querystring = http_build_query($info);
        $appurl = 'secrethandshake://oauth' . '?' . $querystring;
        header('Location: ' . $appurl);
        die('Redirect');
        
    }

?>

```