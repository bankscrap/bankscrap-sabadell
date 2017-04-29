require 'bankscrap'
require 'securerandom'

module Bankscrap
  module Sabadell

    class Bank < ::Bankscrap::Bank

      # Define the endpoints for the Bank API here
      BASE_ENDPOINT         = 'https://www.bancsabadell.mobi/bsmobil/api'.freeze
      LOGIN_ENDPOINT        = '/session'.freeze
      ACCOUNTS_ENDPOINT     = '/products'.freeze
      TRANSACTIONS_ENDPOINT = '/accounts/movements'.freeze

      # It can be anything (user, birthday, ID, whatever you need).
      REQUIRED_CREDENTIALS  = %i(user password login_type).freeze

      class InvalidLoginType < Exception; end

      def initialize(credentials = {})
        super do
          # loginType
          # 1 Individual
          # 2 Business
          # 3 CAL -> not supported
          # 4 Secondary card -> not supported

          @login_type = case @login_type.to_sym
            when :individual then 1
            when :business then 2
            else
              raise InvalidLoginType, "Invalid login_type: '#{@login_type}'"
          end

          add_headers('User-Agent' => 'ANDROID 6.0 Google+Nexus+6P+-+6.0.0+-+API+23+-+1440x2560 NATIVE_APP 17.2.0 STANDARD')
          add_headers('Accept' => 'application/vnd.idk.bsmobil-v1720+json')
          add_headers('Content-Type' => 'application/json; charset=utf-8')
        end
      end

      # Fetch all the accounts for the given user
      #
      # Should returns an array of Bankscrap::Account objects
      def fetch_accounts
        response = get(BASE_ENDPOINT + ACCOUNTS_ENDPOINT)
        json = JSON.parse(response)
        json['accountProduct']['accounts'].map { |data| build_account(data) }

        # TODO parse json['cardProduct'] for cards
      end

      # Fetch transactions for the given account.
      #
      # Account should be a Bankscrap::Account object
      # Should returns an array of Bankscrap::Account objects
      def fetch_transactions_for(account, start_date: Date.today - 1.month, end_date: Date.today)
        # Example if the API expects a JSON POST request
        params = {
          account: account.raw_data,
          dateFrom: format_date(start_date),
          dateTo: format_date(end_date),
          moreRequest: false
        }

        transactions = []
        loop do
          response = post(BASE_ENDPOINT + TRANSACTIONS_ENDPOINT, fields: params.to_json)
          json = JSON.parse(response)
          transactions += json['accountMovements'].map { |data| build_transaction(data, account) }

          params[:moreRequest] = true # Switch this flag after first request
          break unless json['moreElements']
        end

        transactions
      end

      private

      # First request to login
      def login
        # Example if the API expects a JSON POST request
        params = { 
          brand: "SAB",
          contract: "",
          csid: "00000000-00X0-0000-X000-000000000000",
          deviceInfo: "en-US GEO() ANDROID 6.0 Google+Nexus+6P+-+6.0.0+-+API+23+-+1440x2560 NATIVE_APP 17.2.0 STANDARD",
          geolocationData: "",
          loginType: @login_type,
          newDevice: true,
          devicePrint: "",
          password: @password,
          requestId: "SDK",
          userName: @user
        }

        post(BASE_ENDPOINT + LOGIN_ENDPOINT, fields: params.to_json)
      end

      # Build an Account object from API data
      def build_account(data)
        balance_cents = data['amount']['value'].scan(/-|\d/).join('').to_i
        balance = Money.new(balance_cents, data['amount']['currency'])

        Account.new(
          bank: self,
          id: data['number'],
          name: "#{data['description']} #{data['iban']}",
          available_balance: balance,
          balance: balance,
          iban: data['iban'],
          description: data['description'],
          raw_data: data
        )
      end

      # Build a transaction object from API data
      def build_transaction(data, account)
        amount_cents = data['amount']['value'].scan(/-|\d/).join('').to_i
        amount = Money.new(amount_cents, data['amount']['currency'])

        balance_cents = data['balance']['value'].scan(/-|\d/).join('').to_i
        balance = Money.new(balance_cents, data['balance']['currency'])

        Transaction.new(
          account: account,
          id: data['apuntNumber'],
          amount: amount,
          description: data['concept'],
          effective_date: parse_date(data['valueDate']),
          operation_date: parse_date(data['date']),
          balance: balance
        )
      end

      def format_date(date)
        date.strftime('%d-%m-%Y')
      end

      def parse_date(date_as_string)
        Date.strptime(date_as_string, '%d-%m-%Y')
      end
    end
  end
end
