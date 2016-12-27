# AniManager
## Description
AniManager is an application for iOS that lets the user track and explore anime and manga. This app was created as my last project for the [iOS Developer Nanodegree by Udacity](https://www.udacity.com/course/ios-developer-nanodegree--nd003) which is supposed to be an own iOS application. 

The app is written in Swift 3 and uses the [AniList](https://anilist.co) API to get and modify data. As of now the app *requires* an AniList account but it's planned to implement a mode without login that has limited functionality in the future.

Note: This is *not* an official AniList application

## Get Started
1. Download/clone the repository
2. Create a free AniList account [here](https://anilist.co/register)
3. After registering and verifying your account, go to [your account's developer settings](https://anilist.co/settings/developer) and click on the **Create New Client** button
4. Fill in the fields *like so*...

	![](https://github.com/helmrich/AniManager/blob/master/screenshots/anilist-client-creation.png?raw=true)
  
5. The value for ```Client Redirect Uri``` should be ```AniManager://```, the value for ```Name``` should be ```AniManager```
5. Click on **Save**
6. The Client ID and Client Secret should now be filled out automatically.
7. Open the project
8. Open the ```AniListConstant``` file in ```Models/Clients/AniList/Constants/```
9. Assign your AniList Client ID and Client Secret to the corresponding constants (**Client ID**: ```clientId```, **Client Secret**: ```clientSecret```)
10. Run the app

## Current Features

### Browsing
Browse Anime and Manga with filters or search them by name.

### Lists
See your AniList account's default lists (custom lists are not supported yet).

### Series Management
Manage your lists' anime and manga (list status, watched episodes, read chapters/volumes, favourites, rating).

### Series Details
See anime/manga series details such as...

- Average rating
- Number of Episodes
- Episode duration
- Characters
- External Links (Crunchyroll, Twitter, Official Homepage, Hulu, Funimation, etc.)
- Trailer
- Genres/Tags
- Description
- Season
- Status
- Type

## Screenshots
### Authentication

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-authentication-login.png?raw=true)

### Browse

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-browse-list.png) ![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-browse-filter.png?raw=true)

### List Selection

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-animelists.png) ![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-mangalists.png?raw=true)

### List Detail

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-list-detail.png?raw=true)

### Search

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-search.png?raw=true)

### Series Details

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-series-detail-1.png) ![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-series-detail-2.png?raw=true)

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-series-detail-3.png) ![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-series-detail-4.png?raw=true)

### Character Detail

![](https://github.com/helmrich/AniManager/blob/master/screenshots/animanager-character-detail.png?raw=true)


## Plans for the Future
I'm not 100% sure if or when I'll submit the application to the App Store but there are still quite many things I want to add to or refine in the application before I consider submitting it to the App Store.

**Some of the planned additions/features are**:

- Additional rating systems (currently only ratings from 1 to 10 are available)
- Settings tab (with options to change the rating systems, title language (English, Romaji, Japanese), favourite genres and an option for WiFi-only image downloads)
- Home tab (with sections like "recommended", "new", "current season", etc.)
- Relations to connected series in the series detail
- Actors/Actresses info
- Staff info
- Countdown to new episodes and optional push notifications for new episodes/chapters



