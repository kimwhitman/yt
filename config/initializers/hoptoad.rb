HoptoadNotifier.configure do |config|
  config.api_key = {:project => 'yogatoday',            # the identifier you specified for your project in Redmine
                    :tracker => 'Bug',                  # the name of your Tracker of choice in Redmine
                    :api_key => 'ff98OWmuftW1QRxgP5iU', # the WS key you generated in Redmine
                    :category => 'Development',         # the name of a ticket category (optional.)
                   }.to_yaml

  config.host = 'pm.yogatoday.com' # the hostname your Redmine runs at
  config.port = 80                 # the port your Redmine runs at
  config.secure = false            # sends data to your server via SSL (optional.)
end
