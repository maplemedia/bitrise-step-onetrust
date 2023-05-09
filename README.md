# OneTrust app scanning

Send app build for OneTrust app scanning


## How to use this Step

Can be run directly with the [bitrise CLI](https://github.com/bitrise-io/bitrise),
just `git clone` this repository, `cd` into it's folder in your Terminal/Command Line
and call `bitrise run deploy`.

*Check the `bitrise.yml` file for required inputs which have to be
added to your `.bitrise.secrets.yml` file!*

Step by step:

1. Open up your Terminal / Command Line
2. `git clone` the repository
3. `cd` into the directory of the step (the one you just `git clone`d)
5. Create a `.bitrise.secrets.yml` file in the same directory of `bitrise.yml` - the `.bitrise.secrets.yml` is a git ignored file, you can store your secrets in
6. Check the `bitrise.yml` file for any secret you should set in `.bitrise.secrets.yml`
  * Best practice is to mark these options with something like `# define these in your .bitrise.secrets.yml`, in the `app:envs` section.
7. Once you have all the required secret parameters in your `.bitrise.secrets.yml` you can just run this step with the [bitrise CLI](https://github.com/bitrise-io/bitrise): `bitrise run deploy`

An example `.bitrise.secrets.yml` file:

```
envs:
- ONE_TRUST_OAUTH_CLIENT_ID: {ID}
- ONE_TRUST_OAUTH_CLIENT_SECRET: {SECRET}
- ONE_TRUST_APPLICATION_ID: {GUID}
- ONE_TRUST_APPLICATION_PLATFORM: ANDROID
- ONE_TRUST_UPLOAD_URL: https://app.onetrust.com/integrationmanager/api/v1/webhook/{GUID}
- BITRISE_APK_PATH: ./bitrisetest.apk
```
