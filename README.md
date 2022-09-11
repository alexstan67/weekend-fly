# Introduction

<img src="https://github.com/alexstan67/weekend-fly/blob/master/app/assets/images/plane.png" width="200" />

For General Aviation fellows, find a destination !

# Weekend Fly

## Requirements
* ruby 3.0.3
* rails 7.0.3
* bundler

## Installation
Create a .env file with following keys:
`OPENWEATHERMAP_API=`
`MAIL_USERNAME=`
`MAIL_PASSWORD=`
`MAIL_DOMAIN=`
`MAIL_SMTP_SERVER=`

`bundle install`

`yarn`

Copy and rename `config/database.yml.backup` to `config/database.yml`.
Those are the default config.
Feel free to customize `config/database.yml` following your requirements.

`rails db:create`

`rails db:migrate`

`rails db:seed`

`rake import:airports`
`rake import:countries`

## License
All rights reserved.
