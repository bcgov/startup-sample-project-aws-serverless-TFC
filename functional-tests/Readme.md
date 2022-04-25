# Sample Serverless app BDD test
## Description
Under `functional_test` folder you will find a set of scripts to run an automated test on the startup sample aws containers app. You may want to use it as a template to incorporate automated test to your app.

The app is written in groovy using the geb/spock framework. This framework makes the test easy to read and to follow.

## Run the test
As currently written, the BASEURL is read from the environment, so, when running locally.  first set this value by typing on the command line 
`export BASEURL="https://d3qkdfho08icid.cloudfront.net/"`

The find the specific address you need to log into Cloudfront after installing the application. 

To run the test, open terminal and navigate to `.../functional-test` and execute 
`./gradlew chromeTest --tests="FirstTest"`

Alternatively, you can hardcode the address in the GebConfig.groovy file

To run the test, cd to `functional-tests` folder type on terminal

  `./gradlew chromeTest --tests="FirstTest"`



When running the test in GitHub actions, set the BASEURL as a GitHub secret


## Reports
After every run, you will find two useful reports at

`startup-sample-project-aws-serverless/functional-tests/build/reports/spock`

and at 
`startup-sample-project-aws-serverless/functional-tests/build/reports/tests/chromeTest`
(there is a folder for each environment)

The information provided by both reports overlaps, however there are some details. Visually, I find the spock report more pleasant, however, the reports under test allows to view logs messages you may have `println` to terminal, very useful in debugging mode.  

## Improvement
If you have aws cli installed on your machine (an the credentials as env variables) you can type the command
`aws cloudfront list-distributions`
and with some manipulation find the BASEURL. Unfortunately, this does not work when executing the test from the GitHub actions environment due to the way the account is configured. You may ask to the ECF team to create an account without this limitation.


## Run the test using BrowserStack
When using BrowserStack, the test scripts are running locally in your machine (or in GitHub) firing a remote browser in BrowserStack, in this case on the BrowserStack cloud, and the browser is opening the containers app page stored in AWS

For this configuration you need 
- The sample serverless app installed in AWS. You also need the license plate (check `startup-sample-project-aws-serverless/Readme.md` for more information)

- An account with BrowserStack, once you have the account, you will access the values of `User Name` and `Access Key`. To run the test locally, you will need to type in terminal the following commands to add their values in your environment

  `export LICENSE_PLATE=[LICENSE PLATE]`
  
  `export BROWSERSTACK_USERNAME=[BrowserStack user name]`
  
  `export BROWSERSTACK_ACCESS_KEY=[BrowserStack Access key]`

once set, navigate to `../functional-test` and execute run the following command on your terminal

`./gradlew remoteChromeTest --tests="FirstTest"`


** Important Note **
Currently, it is not possible to use BrowserStack to test the serverless app, neither from your local machine or from GitHub. The reason is the BrowserStack servers are located outside Canada. The Enterprise Cloud Factory by default enforces geofencing of the environments. In this context, BroserStack running in a server farm outside Canada, has its connection request refused. 


## Run the test scripts on GitHub CI/CD pipeline
Currently it is not possible to run the test automatically in a CI/CD GiHub Actions Pipeline. The reason is the same as Browser Stack: GitHub server farm is located outside Canada and the AWS environment is geofenced, so the test scripts have their connection request rejected

Currently, the manually triggered action `AutomationTestUbuntu.yml` runs automatically the tests in GitHub and `browserStackTest.yml` to run the test using BrowserStack

The following secrets need to be set to run the test:

- `BROWSERSTACK_ACCESS_KEY`
- `BROWSERSTACK_USERNAME`

The following secrets need to be set to mail the test results to the account of your choice (You may comment out the section that sends the eamil in the yml script)
- `MAIL_ADDRESS`
- `MAIL_PASSWORD`
- `MAIL_SERVER`
- `MAIL_USERNAME`


## Running using other browsers
- **ChromeHeadless**: 

  The current configuration allows you to run the test locally in ChromeHeadless mode with the command

  `./gradlew chromeHeadlessTest --tests="FirstTest"`

- **Firefox**: 

  `./gradlew firefoxTest --tests="FirstTest"`

  for the headless version

  `./gradlew firefoxHeadlessTest --tests="FirstTest"`



## Reports
After every run, you will find two useful reports at

`startup-sample-project-aws-serverless/functional-tests/build/reports/spock`

and at 
`startup-sample-project-aws-serverless/functional-tests/build/reports/tests/chromeTest`
(there is a folder for each environment)

The information provided by both reports overlaps, however there are some details. Visually, I find the spock report more pleasant, however, the reports under test allows to view logs messages you may have `println` to terminal, very useful in debugging mode.  

## Useful links:

<http://www.gebish.org/manual/current>

<http://spockframework.org/>

<http://groovy-lang.org/>

<https://inviqa.com/blog/bdd-guide>

<https://github.com/SeleniumHQ/selenium/wiki>


Integrate with geb/spock
https://github.com/mudassarsyed/geb-spock-mvn-browserstack
​
Github actions integration
https://www.browserstack.com/docs/automate/selenium/github-actions#action-setup-env


Check https://github.com/renatoathaydes/spock-reports for compatibility among java, Groovy, Spock and spock-reports

Check https://github.com/AOEpeople/geb-spock-reports/blob/master/README.md for compatibility among geb-spock-reports,	spock-reports,	spock-core,	Groovy and JUnit
