civix:
    symfony:
        parameters:
            database_driver: pdo_mysql
            database_host: 127.0.0.1
            database_port:
            database_name: civix
            database_user: civix
            database_password: civix
            mailer_transport: smtp
            mailer_host: 127.0.0.1
            mailer_user:
            mailer_password:
            mailer_from: support@powerli.ne
            mailer_beta_access_recipient: beta@powerli.ne
            locale: en
            secret: secret
            domain: example.com
            hostname: vagrant.local
            scheme: http
            amazon_s3.key:
            amazon_s3.secret:
            amazon_s3.region: us-east-1
            amazon_s3.bucket: devpowerline
            amazon_s3.url: /
            amazon_sns.android_arn: arn:aws:sns:eu-west-1:863632456175:app/GCM/powerline_android_debug
            amazon_sns.ios_arn: arn:aws:sns:eu-west-1:863632456175:app/APNS/powerline_ios_debug
            recaptcha_public_key: here_is_your_public_key
            recaptcha_private_key: here_is_your_private_key
            recaptcha_secure: false
            recaptcha_locale_key: kernel.default_locale
            recaptcha_enabled: true
            cicero_login: aplotnikov
            cicero_password: aplotnikov
            android_api_key: android_api_key
            android_app: app_key
            ios_is_sanbox: true
            ios_pem_path: /path/to/certs
            ios_passphrase: passphrase
            sunlightapi_token:
            stripe_api_key: sk_test_vpedTPsiXZZ8SSwS4isZzHWw
            stripe_publishable_key: pk_test_QUgSE3ZhORW9yoDuCkMjnaA2
            rabbitmq_connections:
                default:
                    host: 'localhost'
                    port: 5672
                    user: 'guest'
                    password: 'guest'
                    vhost: '/'
                    lazy: true
            mailgun_public: public_key
            mailgun_private: private_key
            auto_invite_group_name: 'Powerline Powerusers'
            imgix.domain:  powerline-dev.imgix.net
            default_api_version: 1
            facebook_client_id: xxx
            facebook_client_secret: yyy
            slack_logger_token: 'xoxp'
